package com.mycompany.courseshop.controller;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mycompany.courseshop.dao.CertificateDAO;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.stream.Collectors;

@WebServlet(name = "LessonProgressServlet", urlPatterns = {"/api/progress"})
public class LessonProgressServlet extends HttpServlet {

    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    private final CertificateDAO certificateDAO = new CertificateDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        User user = (User) req.getSession().getAttribute("user");

        try {
            String body = req.getReader().lines().collect(Collectors.joining());
            JsonObject json = JsonParser.parseString(body).getAsJsonObject();
            int courseId = json.get("courseId").getAsInt();
            int lessonId = json.get("lessonId").getAsInt();
            boolean completed = !json.has("completed") || json.get("completed").getAsBoolean();

            if (!user.isAdmin() && !enrollmentDAO.isEnrolled(user.getId(), courseId)) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.getWriter().write("{\"error\":\"Bạn chưa đăng ký khóa học này.\"}");
                return;
            }

            int[] stats = enrollmentDAO.setLessonCompleted(user.getId(), courseId, lessonId, completed);
            int percent = stats[1] > 0 ? Math.round((stats[0] * 100f) / stats[1]) : 0;

            String certCode = null;
            if (percent == 100 && stats[1] > 0) {
                certCode = certificateDAO.issueIfNotExists(user.getId(), courseId);
            }

            JsonObject out = new JsonObject();
            out.addProperty("ok", true);
            out.addProperty("completed", completed);
            out.addProperty("done", stats[0]);
            out.addProperty("total", stats[1]);
            out.addProperty("percent", percent);
            if (certCode != null) {
                out.addProperty("certificateCode", certCode);
            }
            resp.getWriter().write(out.toString());
        } catch (SQLException | RuntimeException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            JsonObject err = new JsonObject();
            err.addProperty("error", "Không thể cập nhật tiến độ bài học.");
            resp.getWriter().write(err.toString());
        }
    }
}
