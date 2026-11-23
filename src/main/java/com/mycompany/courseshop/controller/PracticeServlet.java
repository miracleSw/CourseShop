package com.mycompany.courseshop.controller;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.dao.PracticeDAO;
import com.mycompany.courseshop.model.LessonExercise;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

@WebServlet(name = "PracticeServlet", urlPatterns = {"/api/practice"})
public class PracticeServlet extends HttpServlet {

    private final PracticeDAO practiceDAO = new PracticeDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        User user = (User) req.getSession().getAttribute("user");

        try {
            String body = req.getReader().lines().collect(Collectors.joining());
            JsonObject json = JsonParser.parseString(body).getAsJsonObject();
            int exerciseId = json.get("exerciseId").getAsInt();
            String code = json.has("code") ? json.get("code").getAsString() : "";

            LessonExercise ex = practiceDAO.findById(exerciseId);
            if (ex == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("{\"ok\":false,\"error\":\"Không tìm thấy bài tập thực hành.\"}");
                return;
            }
            if (!user.isAdmin() && !enrollmentDAO.isEnrolled(user.getId(), ex.getCourseId())) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.getWriter().write("{\"ok\":false,\"error\":\"Bạn chưa đăng ký khóa học này.\"}");
                return;
            }

            if (code.trim().length() < 5) {
                JsonObject out = new JsonObject();
                out.addProperty("ok", true);
                out.addProperty("passed", false);
                out.addProperty("feedback", "Vui lòng nhập lời giải trước khi kiểm tra.");
                resp.getWriter().write(out.toString());
                return;
            }

            // Evaluate against required code tokens (case-insensitive, normalized whitespace)
            String normalized = code.toLowerCase(Locale.ROOT).replaceAll("\\s+", " ");
            List<String> missing = new ArrayList<>();
            if (ex.getExpectedTokens() != null && !ex.getExpectedTokens().isBlank()) {
                for (String rawLine : ex.getExpectedTokens().split("\\r?\\n")) {
                    String token = rawLine.trim();
                    if (token.isEmpty()) continue;
                    String needle = token.toLowerCase(Locale.ROOT).replaceAll("\\s+", " ");
                    if (!normalized.contains(needle)) {
                        missing.add(token);
                    }
                }
            }

            boolean passed = missing.isEmpty();
            String feedback = passed
                    ? "Chính xác! Lời giải của bạn đã đáp ứng đầy đủ yêu cầu bài thực hành."
                    : "Chưa đạt — lời giải đang thiếu các thành phần cần có: " + String.join(", ", missing);

            practiceDAO.saveSubmission(exerciseId, user.getId(), code, passed, feedback);

            JsonObject out = new JsonObject();
            out.addProperty("ok", true);
            out.addProperty("passed", passed);
            out.addProperty("feedback", feedback);
            JsonArray missArr = new JsonArray();
            missing.forEach(missArr::add);
            out.add("missing", missArr);
            resp.getWriter().write(out.toString());
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"ok\":false,\"error\":\"Không thể chấm bài thực hành lúc này.\"}");
        }
    }
}
