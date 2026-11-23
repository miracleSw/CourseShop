package com.mycompany.courseshop.service;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.mycompany.courseshop.dao.SettingsDAO;
import com.mycompany.courseshop.model.Order;
import com.mycompany.courseshop.model.OrderItem;
import com.mycompany.courseshop.model.User;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.concurrent.CompletableFuture;

/**
 * Transactional email sender using Resend REST API (JDK 21 HttpClient, zero extra JARs).
 * Supports password reset links and automated paid-order confirmations.
 */
public class EmailService {

    private static final String RESEND_ENDPOINT = "https://api.resend.com/emails";

    private final SettingsDAO settingsDAO = new SettingsDAO();
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    public record SendResult(boolean ok, String message) {}

    public boolean isConfigured() {
        String key = settingsDAO.getResendApiKey();
        return key != null && !key.isBlank();
    }

    public SendResult sendHtml(String toEmail, String subject, String htmlBody) {
        String apiKey = settingsDAO.getResendApiKey();
        if (apiKey == null || apiKey.isBlank()) {
            return new SendResult(false, "Dịch vụ gửi email tự động chưa được kích hoạt.");
        }
        if (toEmail == null || toEmail.isBlank()) {
            return new SendResult(false, "Địa chỉ email người nhận không hợp lệ.");
        }
        String from = settingsDAO.getMailFrom();
        if (from == null || from.isBlank()) {
            from = "CourseShop <onboarding@resend.dev>";
        }

        JsonObject payload = new JsonObject();
        payload.addProperty("from", from);
        JsonArray toArr = new JsonArray();
        toArr.add(toEmail.trim());
        payload.add("to", toArr);
        payload.addProperty("subject", subject);
        payload.addProperty("html", htmlBody);

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(RESEND_ENDPOINT))
                    .timeout(Duration.ofSeconds(15))
                    .header("Authorization", "Bearer " + apiKey.trim())
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .POST(HttpRequest.BodyPublishers.ofString(payload.toString()))
                    .build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                return new SendResult(true, "Đã gửi email thành công tới " + toEmail + ".");
            }
            System.err.println("[EmailService] Resend HTTP " + response.statusCode() + ": " + response.body());
            return new SendResult(false, "Không thể gửi email lúc này (mã phản hồi " + response.statusCode() + ").");
        } catch (Exception e) {
            System.err.println("[EmailService] Send failed: " + e.getMessage());
            return new SendResult(false, "Không thể kết nối tới máy chủ gửi thư.");
        }
    }

    public SendResult sendPasswordResetEmail(User user, String resetUrl) {
        String siteName = settingsDAO.get("site.name", "CourseShop");
        String html = """
            <div style="font-family:Arial,Helvetica,sans-serif;max-width:560px;margin:0 auto;padding:24px;color:#16181D;background:#FAF8F3;border:1px solid #D6D1C4;border-radius:10px;">
              <h2 style="margin:0 0 12px;color:#23469E;">Đặt lại mật khẩu %s</h2>
              <p style="margin:0 0 12px;line-height:1.6;">Xin chào <strong>%s</strong>,</p>
              <p style="margin:0 0 20px;line-height:1.6;">Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn. Nhấn vào nút bên dưới để tạo mật khẩu mới (liên kết có hiệu lực trong 30 phút):</p>
              <p style="margin:0 0 22px;">
                <a href="%s" style="display:inline-block;padding:12px 22px;background:#23469E;color:#FFFFFF;text-decoration:none;border-radius:6px;font-weight:bold;">Đặt lại mật khẩu</a>
              </p>
              <p style="margin:0;font-size:13px;color:#4A4E57;line-height:1.5;">Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này — mật khẩu hiện tại của bạn vẫn an toàn.</p>
            </div>
            """.formatted(escapeHtml(siteName), escapeHtml(user.getFullName()), escapeHtml(resetUrl));
        return sendHtml(user.getEmail(), "[" + siteName + "] Yêu cầu đặt lại mật khẩu", html);
    }

    public void sendOrderConfirmationAsync(Order order, String baseUrl) {
        if (order == null || order.getUserEmail() == null || order.getUserEmail().isBlank() || !isConfigured()) {
            return;
        }
        CompletableFuture.runAsync(() -> {
            String siteName = settingsDAO.get("site.name", "CourseShop");
            StringBuilder rows = new StringBuilder();
            if (order.getItems() != null) {
                for (OrderItem it : order.getItems()) {
                    rows.append("<tr><td style=\"padding:8px 0;border-bottom:1px solid #E5E0D5;\"><strong>")
                        .append(escapeHtml(it.getCourseTitle()))
                        .append("</strong></td><td style=\"padding:8px 0;border-bottom:1px solid #E5E0D5;text-align:right;font-family:monospace;\">")
                        .append(escapeHtml(it.getFormattedPrice()))
                        .append("</td></tr>");
                }
            }
            String learnUrl = baseUrl + "/my-courses";
            String html = """
                <div style="font-family:Arial,Helvetica,sans-serif;max-width:580px;margin:0 auto;padding:24px;color:#16181D;background:#FAF8F3;border:1px solid #D6D1C4;border-radius:10px;">
                  <h2 style="margin:0 0 10px;color:#15803D;">Xác nhận thanh toán thành công</h2>
                  <p style="margin:0 0 14px;line-height:1.6;">Xin chào <strong>%s</strong>, đơn hàng <strong>#%s</strong> của bạn đã được xác nhận và các khóa học đã sẵn sàng trong tài khoản.</p>
                  <table style="width:100%%;border-collapse:collapse;margin:14px 0;">%s</table>
                  <p style="margin:12px 0 20px;font-size:16px;"><strong>Tổng thanh toán: <span style="color:#B45309;">%s</span></strong></p>
                  <p style="margin:0 0 20px;">
                    <a href="%s" style="display:inline-block;padding:12px 22px;background:#23469E;color:#FFFFFF;text-decoration:none;border-radius:6px;font-weight:bold;">Vào học ngay</a>
                  </p>
                  <p style="margin:0;font-size:12.5px;color:#4A4E57;">Cảm ơn bạn đã đồng hành cùng %s.</p>
                </div>
                """.formatted(
                    escapeHtml(order.getUserName()),
                    escapeHtml(order.getOrderCode()),
                    rows.toString(),
                    escapeHtml(order.getFormattedTotal()),
                    escapeHtml(learnUrl),
                    escapeHtml(siteName)
            );
            sendHtml(order.getUserEmail(), "[" + siteName + "] Xác nhận đơn hàng #" + order.getOrderCode(), html);
        });
    }

    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
