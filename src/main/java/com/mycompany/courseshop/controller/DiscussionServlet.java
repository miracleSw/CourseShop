package com.mycompany.courseshop.controller;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mycompany.courseshop.dao.DiscussionDAO;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.model.LessonDiscussion;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "DiscussionServlet", urlPatterns = {"/api/discussions"})
public class DiscussionServlet extends HttpServlet {

    private final DiscussionDAO discussionDAO = new DiscussionDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        User user = (User) req.getSession().getAttribute("user");
        int lessonId = parseInt(req.getParameter("lessonId"));
        int courseId = parseInt(req.getParameter("courseId"));

        if (!user.isAdmin() && !enrollmentDAO.isEnrolled(user.getId(), courseId)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.getWriter().write("{\"ok\":false,\"error\":\"Bạn chưa đăng ký khóa học này.\"}");
            return;
        }

        List<LessonDiscussion> items = discussionDAO.findTreeByLesson(lessonId);
        JsonObject out = new JsonObject();
        out.addProperty("ok", true);
        JsonArray arr = new JsonArray();
        for (LessonDiscussion d : items) {
            arr.add(toJson(d, user));
        }
        out.add("items", arr);
        resp.getWriter().write(out.toString());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        User user = (User) req.getSession().getAttribute("user");

        try {
            String body = req.getReader().lines().collect(Collectors.joining());
            JsonObject json = JsonParser.parseString(body).getAsJsonObject();
            String action = json.has("action") ? json.get("action").getAsString() : "add";

            if ("delete".equalsIgnoreCase(action)) {
                int id = json.get("discussionId").getAsInt();
                boolean deleted = discussionDAO.deleteIfAllowed(id, user.getId(), user.isAdmin());
                JsonObject out = new JsonObject();
                out.addProperty("ok", deleted);
                if (!deleted) out.addProperty("error", "Bạn không có quyền xóa bình luận này.");
                resp.getWriter().write(out.toString());
                return;
            }

            int courseId = json.get("courseId").getAsInt();
            int lessonId = json.get("lessonId").getAsInt();
            Integer parentId = (json.has("parentId") && !json.get("parentId").isJsonNull())
                    ? json.get("parentId").getAsInt() : null;
            String content = json.has("content") ? json.get("content").getAsString().trim() : "";

            if (!user.isAdmin() && !enrollmentDAO.isEnrolled(user.getId(), courseId)) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.getWriter().write("{\"ok\":false,\"error\":\"Bạn chưa đăng ký khóa học này.\"}");
                return;
            }
            if (content.length() < 3) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("{\"ok\":false,\"error\":\"Nội dung thảo luận cần tối thiểu 3 ký tự.\"}");
                return;
            }
            if (content.length() > 2000) {
                content = content.substring(0, 2000);
            }

            LessonDiscussion created = discussionDAO.create(lessonId, courseId, user.getId(), parentId, content);
            JsonObject out = new JsonObject();
            out.addProperty("ok", created != null);
            if (created != null) {
                out.add("item", toJson(created, user));
            }
            resp.getWriter().write(out.toString());
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"ok\":false,\"error\":\"Không thể gửi thảo luận lúc này.\"}");
        }
    }

    private JsonObject toJson(LessonDiscussion d, User current) {
        SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        JsonObject o = new JsonObject();
        o.addProperty("id", d.getId());
        o.addProperty("parentId", d.getParentId());
        o.addProperty("userId", d.getUserId());
        o.addProperty("userName", d.getUserName());
        o.addProperty("userInitials", d.getUserInitials());
        o.addProperty("instructor", d.isInstructor());
        o.addProperty("content", d.getContent());
        o.addProperty("createdAt", d.getCreatedAt() != null ? fmt.format(d.getCreatedAt()) : "Vừa xong");
        o.addProperty("canDelete", current != null && (current.isAdmin() || current.getId() == d.getUserId()));
        JsonArray replies = new JsonArray();
        for (LessonDiscussion r : d.getReplies()) {
            replies.add(toJson(r, current));
        }
        o.add("replies", replies);
        return o;
    }

    private int parseInt(String v) {
        try { return Integer.parseInt(v); } catch (Exception e) { return 0; }
    }
}
