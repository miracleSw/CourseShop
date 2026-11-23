package com.mycompany.courseshop.service;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonSyntaxException;
import com.mycompany.courseshop.dao.CouponDAO;
import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.dao.LearningPathDAO;
import com.mycompany.courseshop.dao.SettingsDAO;
import com.mycompany.courseshop.model.Coupon;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.LearningPath;
import com.mycompany.courseshop.model.Lesson;
import com.mycompany.courseshop.model.User;
import com.mycompany.courseshop.utils.FormatUtil;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpTimeoutException;
import java.time.Duration;
import java.util.List;
import java.util.Set;

/**
 * Production Google Gemini REST API client (zero mock/hardcoded AI fallback replies).
 * Resolves GEMINI_API_KEY from Environment Variables first, handles timeouts, rate limits (429),
 * upstream 5xx, auth errors, safety blocks, and malformed responses cleanly.
 */
public class GeminiChatService {

    private static final String GEMINI_BASE = "https://generativelanguage.googleapis.com/v1beta/models/";
    private final HttpClient http = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(12))
            .build();
    private final SettingsDAO settingsDAO = new SettingsDAO();
    private final CourseDAO courseDAO = new CourseDAO();
    private final LearningPathDAO pathDAO = new LearningPathDAO();
    private final CouponDAO couponDAO = new CouponDAO();

    public record ChatTurn(String role, String text) {}

    public record ChatResponse(
            boolean ok,
            int httpStatus,
            String errorCode,
            String reply,
            String errorMessage,
            String modelUsed) {}

    public record TestResult(boolean ok, String message) {}

    public boolean isConfigured() {
        String key = settingsDAO.getGeminiApiKey();
        return key != null && !key.isBlank();
    }

    public ChatResponse chat(String userMessage, List<ChatTurn> history, User user,
                             Set<Integer> ownedIds, Integer activeCourseId, Integer activeLessonId,
                             String contextPath) {
        String apiKey = settingsDAO.getGeminiApiKey();
        String model = settingsDAO.getGeminiModel();

        if (apiKey == null || apiKey.isBlank()) {
            return new ChatResponse(false, 503, "SERVICE_UNAVAILABLE", null,
                    "Trợ lý AI hiện chưa được kích hoạt. Vui lòng quay lại sau.", model);
        }

        List<Course> catalog = courseDAO.findPublishedAll();
        String systemPrompt = buildSystemInstruction(catalog, user, ownedIds, activeCourseId, activeLessonId, contextPath);

        JsonObject payload = new JsonObject();
        JsonObject sysObj = new JsonObject();
        JsonArray sysParts = new JsonArray();
        JsonObject sysText = new JsonObject();
        sysText.addProperty("text", systemPrompt);
        sysParts.add(sysText);
        sysObj.add("parts", sysParts);
        payload.add("system_instruction", sysObj);

        JsonArray contents = new JsonArray();
        if (history != null) {
            int start = Math.max(0, history.size() - 8);
            for (int i = start; i < history.size(); i++) {
                ChatTurn turn = history.get(i);
                contents.add(buildContentObj(turn.role(), turn.text()));
            }
        }
        contents.add(buildContentObj("user", userMessage));
        payload.add("contents", contents);

        JsonObject genConfig = new JsonObject();
        genConfig.addProperty("temperature", 0.45);
        genConfig.addProperty("maxOutputTokens", 900);
        payload.add("generationConfig", genConfig);

        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(GEMINI_BASE + model + ":generateContent"))
                    .timeout(Duration.ofSeconds(25))
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .header("x-goog-api-key", apiKey.trim())
                    .POST(HttpRequest.BodyPublishers.ofString(payload.toString()))
                    .build();

            HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
            int status = resp.statusCode();

            if (status >= 200 && status < 300) {
                JsonObject json = parseJsonObject(resp.body());
                if (json == null) {
                    return new ChatResponse(false, 502, "INVALID_RESPONSE", null,
                            "Phản hồi từ trợ lý AI không hợp lệ. Vui lòng thử gửi lại câu hỏi.", model);
                }
                if (isPromptBlocked(json)) {
                    return new ChatResponse(false, 400, "CONTENT_BLOCKED", null,
                            "Nội dung câu hỏi không phù hợp với chính sách an toàn. Vui lòng diễn đạt lại.", model);
                }
                String finishReason = extractFinishReason(json);
                if ("SAFETY".equalsIgnoreCase(finishReason) || "PROHIBITED_CONTENT".equalsIgnoreCase(finishReason)) {
                    return new ChatResponse(false, 400, "CONTENT_BLOCKED", null,
                            "Phản hồi bị chặn bởi bộ lọc an toàn. Vui lòng thử câu hỏi khác.", model);
                }
                String text = extractCandidateText(json);
                if (text == null || text.isBlank()) {
                    return new ChatResponse(false, 502, "EMPTY_RESPONSE", null,
                            "Trợ lý AI chưa tạo được câu trả lời phù hợp. Vui lòng thử lại.", model);
                }
                return new ChatResponse(true, 200, null, text.trim(), null, model);
            }

            if (status == 429) {
                return new ChatResponse(false, 429, "RATE_LIMITED", null,
                        "Trợ lý AI đang nhận nhiều yêu cầu cùng lúc. Vui lòng chờ vài giây rồi thử lại.", model);
            }
            if (status == 400) {
                return new ChatResponse(false, 400, "BAD_REQUEST", null,
                        "Yêu cầu chưa hợp lệ hoặc nội dung bị từ chối. Vui lòng diễn đạt lại câu hỏi.", model);
            }
            if (status == 401 || status == 403) {
                return new ChatResponse(false, 503, "AUTH_ERROR", null,
                        "Dịch vụ trợ lý AI đang tạm gián đoạn. Vui lòng thử lại sau.", model);
            }
            if (status == 503 || status >= 500) {
                return new ChatResponse(false, 503, "UPSTREAM_OVERLOADED", null,
                        "Dịch vụ trợ lý AI đang quá tải tạm thời. Vui lòng thử lại sau ít phút.", model);
            }
            return new ChatResponse(false, 502, "UPSTREAM_ERROR", null,
                    "Không thể nhận phản hồi từ trợ lý AI lúc này. Vui lòng thử lại.", model);

        } catch (HttpTimeoutException e) {
            return new ChatResponse(false, 504, "TIMEOUT", null,
                    "Yêu cầu tới trợ lý AI quá thời gian phản hồi. Vui lòng thử gửi lại.", model);
        } catch (IOException e) {
            return new ChatResponse(false, 502, "NETWORK_ERROR", null,
                    "Không thể kết nối tới dịch vụ trợ lý AI. Vui lòng thử lại sau.", model);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return new ChatResponse(false, 503, "INTERRUPTED", null,
                    "Yêu cầu đã bị gián đoạn. Vui lòng thử lại.", model);
        }
    }

    public TestResult testConnection(String apiKey, String model) {
        if (apiKey == null || apiKey.isBlank()) {
            return new TestResult(false, "Chưa có khóa API Gemini để kiểm tra kết nối.");
        }
        String m = (model == null || model.isBlank()) ? settingsDAO.getGeminiModel() : model.trim();
        JsonObject payload = new JsonObject();
        JsonArray contents = new JsonArray();
        contents.add(buildContentObj("user", "Trả lời đúng 2 từ: OK."));
        payload.add("contents", contents);

        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(GEMINI_BASE + m + ":generateContent"))
                    .timeout(Duration.ofSeconds(15))
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .header("x-goog-api-key", apiKey.trim())
                    .POST(HttpRequest.BodyPublishers.ofString(payload.toString()))
                    .build();
            HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
            if (resp.statusCode() >= 200 && resp.statusCode() < 300) {
                JsonObject json = parseJsonObject(resp.body());
                String reply = json != null ? extractCandidateText(json) : null;
                if (reply != null && !reply.isBlank()) {
                    return new TestResult(true, "Kết nối Gemini thành công (" + m + ").");
                }
                return new TestResult(false, "Gemini phản hồi rỗng. Vui lòng kiểm tra lại model.");
            }
            if (resp.statusCode() == 429) {
                return new TestResult(false, "Khóa API hợp lệ nhưng hiện đang chạm giới hạn tần suất (429).");
            }
            JsonObject errJson = parseJsonObject(resp.body());
            String detail = extractApiError(errJson);
            return new TestResult(false, "Gemini từ chối kết nối (HTTP " + resp.statusCode() + "): " + detail);
        } catch (HttpTimeoutException e) {
            return new TestResult(false, "Kết nối tới Gemini bị quá thời gian chờ.");
        } catch (Exception e) {
            return new TestResult(false, "Không thể kết nối tới dịch vụ Gemini.");
        }
    }

    private JsonObject buildContentObj(String role, String text) {
        JsonObject obj = new JsonObject();
        obj.addProperty("role", "user".equals(role) ? "user" : "model");
        JsonArray parts = new JsonArray();
        JsonObject part = new JsonObject();
        part.addProperty("text", text);
        parts.add(part);
        obj.add("parts", parts);
        return obj;
    }

    private String buildSystemInstruction(List<Course> catalog, User user, Set<Integer> ownedIds,
                                          Integer activeCourseId, Integer activeLessonId, String contextPath) {
        StringBuilder sb = new StringBuilder();
        sb.append("Bạn là Trợ lý Học tập & Tư vấn Khóa học chính thức của CourseShop.\n");
        sb.append("Quy tắc trả lời:\n");
        sb.append("- Trả lời bằng tiếng Việt tự nhiên, ngắn gọn, thân thiện, đi thẳng vào câu hỏi của học viên.\n");
        sb.append("- Không tiết lộ thông tin kỹ thuật nội bộ hệ thống và không bịa đặt khóa học ngoài danh sách được cung cấp.\n");
        sb.append("- Khi gợi ý khóa học có thật, luôn kèm đường dẫn markdown [Tên khóa](").append(contextPath).append("/course?slug=SLUG).\n");

        if (user != null) {
            sb.append("- Học viên hiện tại: ").append(user.getFullName())
              .append(" (đã sở hữu ").append(ownedIds != null ? ownedIds.size() : 0).append(" khóa học).\n");
        }

        if (activeCourseId != null && activeCourseId > 0) {
            Course ac = courseDAO.findById(activeCourseId);
            if (ac != null) {
                sb.append("\n[NGỮ CẢNH BÀI HỌC HIỆN TẠI]\n");
                sb.append("Khóa học: ").append(ac.getCode()).append(" - ").append(ac.getTitle()).append("\n");
                if (activeLessonId != null && activeLessonId > 0) {
                    Lesson al = courseDAO.findLessonById(activeLessonId);
                    if (al != null) {
                        sb.append("Bài học: ").append(al.getTitle()).append("\n");
                        if (al.getContentText() != null && !al.getContentText().isBlank()) {
                            sb.append("Nội dung chính: ").append(al.getContentText()).append("\n");
                        }
                    }
                }
                sb.append("Ưu tiên giải thích kiến thức, ví dụ minh họa và hỗ trợ giải đáp bài học này.\n");
            }
        }

        List<Coupon> activeCoupons = couponDAO.findAllActive();
        if (!activeCoupons.isEmpty()) {
            sb.append("\n[MÃ ƯU ĐÃI ĐANG ÁP DỤNG]\n");
            for (Coupon cp : activeCoupons) {
                sb.append("- ").append(cp.getCode())
                  .append(": giảm ").append(cp.getDiscountPercent()).append("%")
                  .append(", tối đa ").append(FormatUtil.formatVndAlways(cp.getMaxDiscount()))
                  .append("\n");
            }
        }

        sb.append("\n[LỘ TRÌNH HỌC TẬP]\n");
        for (LearningPath lp : pathDAO.findAllWithCourses()) {
            sb.append("- ").append(lp.getTitle()).append(" (").append(lp.getTargetRole()).append("): ")
              .append(lp.getSummary()).append("\n");
        }

        sb.append("\n[DANH SÁCH KHÓA HỌC HIỆN CÓ]\n");
        for (Course c : catalog) {
            sb.append("- [").append(c.getCode()).append("] ").append(c.getTitle())
              .append(" | slug=").append(c.getSlug())
              .append(" | ").append(c.isPro() ? "PRO" : "MIỄN PHÍ")
              .append(" | Học phí: ").append(c.getFormattedEffectivePrice())
              .append(c.isHasDiscount() ? " (gốc " + c.getFormattedPrice() + ", -" + c.getDiscountPercent() + "%)" : "")
              .append(" | Trình độ: ").append(c.getLevelLabel())
              .append(" | ").append(c.getLessonCount()).append(" bài (").append(c.getFormattedDuration()).append(")")
              .append(ownedIds != null && ownedIds.contains(c.getId()) ? " [ĐÃ SỞ HỮU]" : "")
              .append("\n");
        }
        return sb.toString();
    }

    private JsonObject parseJsonObject(String raw) {
        if (raw == null || raw.isBlank()) return null;
        try {
            var el = JsonParser.parseString(raw);
            return el.isJsonObject() ? el.getAsJsonObject() : null;
        } catch (JsonSyntaxException e) {
            return null;
        }
    }

    private boolean isPromptBlocked(JsonObject json) {
        if (json.has("promptFeedback") && json.get("promptFeedback").isJsonObject()) {
            JsonObject fb = json.getAsJsonObject("promptFeedback");
            return fb.has("blockReason") && !fb.get("blockReason").isJsonNull()
                    && !fb.get("blockReason").getAsString().isBlank();
        }
        return false;
    }

    private String extractFinishReason(JsonObject json) {
        if (json.has("candidates") && json.get("candidates").isJsonArray()) {
            JsonArray arr = json.getAsJsonArray("candidates");
            if (!arr.isEmpty() && arr.get(0).isJsonObject()) {
                JsonObject c0 = arr.get(0).getAsJsonObject();
                if (c0.has("finishReason") && !c0.get("finishReason").isJsonNull()) {
                    return c0.get("finishReason").getAsString();
                }
            }
        }
        return "";
    }

    private String extractCandidateText(JsonObject json) {
        if (!json.has("candidates") || !json.get("candidates").isJsonArray()) return null;
        JsonArray candidates = json.getAsJsonArray("candidates");
        if (candidates.isEmpty()) return null;
        JsonObject first = candidates.get(0).getAsJsonObject();
        if (!first.has("content") || !first.get("content").isJsonObject()) return null;
        JsonObject content = first.getAsJsonObject("content");
        if (!content.has("parts") || !content.get("parts").isJsonArray()) return null;
        StringBuilder sb = new StringBuilder();
        for (var el : content.getAsJsonArray("parts")) {
            if (el.isJsonObject() && el.getAsJsonObject().has("text")) {
                sb.append(el.getAsJsonObject().get("text").getAsString());
            }
        }
        return sb.toString();
    }

    private String extractApiError(JsonObject json) {
        if (json != null && json.has("error") && json.get("error").isJsonObject()) {
            JsonObject err = json.getAsJsonObject("error");
            if (err.has("message") && !err.get("message").isJsonNull()) {
                return err.get("message").getAsString();
            }
        }
        return "Lỗi không xác định";
    }
}
