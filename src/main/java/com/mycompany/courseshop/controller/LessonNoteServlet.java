package com.mycompany.courseshop.controller;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.model.LessonNote;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.stream.Collectors;

@WebServlet(name = "LessonNoteServlet", urlPatterns = {"/api/notes"})
public class LessonNoteServlet extends HttpServlet {

    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        User user = (User) req.getSession().getAttribute("user");

        try {
            String body = req.getReader().lines().collect(Collectors.joining());
            JsonObject json = JsonParser.parseString(body).getAsJsonObject();
            String action = json.has("action") ? json.get("action").getAsString() : "add";

            if ("delete".equalsIgnoreCase(action)) {
                int noteId = json.get("noteId").getAsInt();
                boolean removed = enrollmentDAO.deleteNote(noteId, user.getId());
                JsonObject out = new JsonObject();
                out.addProperty("ok", removed);
                resp.getWriter().write(out.toString());
                return;
            }

            int courseId = json.get("courseId").getAsInt();
            int lessonId = json.get("lessonId").getAsInt();
            int timestampSeconds = json.has("timestampSeconds") ? json.get("timestampSeconds").getAsInt() : 0;
            String noteText = json.has("noteText") ? json.get("noteText").getAsString() : "";

            if (noteText.isBlank()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("{\"error\":\"Vui lòng nhập nội dung ghi chú.\"}");
                return;
            }
            if (!user.isAdmin() && !enrollmentDAO.isEnrolled(user.getId(), courseId)) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.getWriter().write("{\"error\":\"Bạn chưa đăng ký khóa học này.\"}");
                return;
            }

            LessonNote saved = enrollmentDAO.addNote(user.getId(), courseId, lessonId, timestampSeconds, noteText);
            JsonObject out = new JsonObject();
            out.addProperty("ok", saved != null);
            if (saved != null) {
                JsonObject noteJson = new JsonObject();
                noteJson.addProperty("id", saved.getId());
                noteJson.addProperty("lessonId", saved.getLessonId());
                noteJson.addProperty("timestampSeconds", saved.getTimestampSeconds());
                noteJson.addProperty("formattedTimestamp", saved.getFormattedTimestamp());
                noteJson.addProperty("noteText", saved.getNoteText());
                out.add("note", noteJson);
            }
            resp.getWriter().write(out.toString());
        } catch (SQLException | RuntimeException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Không thể lưu ghi chú lúc này.\"}");
        }
    }
}
