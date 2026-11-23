package com.mycompany.courseshop.controller;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mycompany.courseshop.dao.ChatDAO;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.model.User;
import com.mycompany.courseshop.service.GeminiChatService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@WebServlet(name = "ChatServlet", urlPatterns = {"/api/chat"})
public class ChatServlet extends HttpServlet {

    private final GeminiChatService chatService = new GeminiChatService();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    private final ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession(true);
        User user = (User) session.getAttribute("user");
        Integer userId = user != null ? user.getId() : null;
        Integer courseId = parseNullableInt(req.getParameter("courseId"));
        String contextType = (courseId != null && courseId > 0) ? "LEARN" : "STOREFRONT";

        List<String> prompts = chatDAO.findQuickPrompts(contextType);
        List<GeminiChatService.ChatTurn> history = chatDAO.findRecentHistory(userId, session.getId(), courseId, 20);
        boolean available = chatService.isConfigured();

        JsonObject out = new JsonObject();
        out.addProperty("ok", true);
        out.addProperty("available", available);
        out.addProperty("statusText", available ? "Sẵn sàng hỗ trợ" : "Hiện tạm ngưng");

        JsonArray promptArr = new JsonArray();
        for (String p : prompts) promptArr.add(p);
        out.add("quickPrompts", promptArr);

        JsonArray msgArr = new JsonArray();
        for (GeminiChatService.ChatTurn t : history) {
            JsonObject m = new JsonObject();
            m.addProperty("role", t.role());
            m.addProperty("text", t.text());
            msgArr.add(m);
        }
        out.add("messages", msgArr);
        resp.getWriter().write(out.toString());
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            User user = (User) session.getAttribute("user");
            Integer userId = user != null ? user.getId() : null;
            Integer courseId = parseNullableInt(req.getParameter("courseId"));
            chatDAO.clearHistory(userId, session.getId(), courseId);
        }
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write("{\"ok\":true}");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession(true);
        User user = (User) session.getAttribute("user");
        Integer userId = user != null ? user.getId() : null;

        try {
            String body = req.getReader().lines().collect(Collectors.joining());
            JsonObject reqJson = JsonParser.parseString(body).getAsJsonObject();

            Integer courseId = (reqJson.has("courseId") && !reqJson.get("courseId").isJsonNull())
                    ? reqJson.get("courseId").getAsInt() : null;
            Integer lessonId = (reqJson.has("lessonId") && !reqJson.get("lessonId").isJsonNull())
                    ? reqJson.get("lessonId").getAsInt() : null;

            if (reqJson.has("action") && "reset".equalsIgnoreCase(reqJson.get("action").getAsString())) {
                chatDAO.clearHistory(userId, session.getId(), courseId);
                resp.getWriter().write("{\"ok\":true}");
                return;
            }

            String message = reqJson.has("message") && !reqJson.get("message").isJsonNull()
                    ? reqJson.get("message").getAsString().trim() : "";
            if (message.isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("{\"ok\":false,\"code\":\"EMPTY_INPUT\",\"error\":\"Vui lòng nhập câu hỏi.\"}");
                return;
            }
            if (message.length() > 1500) {
                message = message.substring(0, 1500);
            }

            List<GeminiChatService.ChatTurn> history = chatDAO.findRecentHistory(userId, session.getId(), courseId, 12);
            Set<Integer> ownedIds = (user != null)
                    ? enrollmentDAO.getEnrolledCourseIds(user.getId())
                    : Collections.emptySet();

            GeminiChatService.ChatResponse aiRes = chatService.chat(
                    message, history, user, ownedIds, courseId, lessonId, req.getContextPath());

            if (!aiRes.ok()) {
                resp.setStatus(aiRes.httpStatus());
                JsonObject err = new JsonObject();
                err.addProperty("ok", false);
                err.addProperty("code", aiRes.errorCode());
                err.addProperty("error", aiRes.errorMessage());
                resp.getWriter().write(err.toString());
                return;
            }

            // Persist genuine Gemini exchange into MySQL
            chatDAO.saveMessage(userId, session.getId(), courseId, lessonId, "user", message, "");
            chatDAO.saveMessage(userId, session.getId(), courseId, lessonId, "model", aiRes.reply(), aiRes.modelUsed());

            JsonObject out = new JsonObject();
            out.addProperty("ok", true);
            out.addProperty("available", true);
            out.addProperty("statusText", "Sẵn sàng hỗ trợ");
            out.addProperty("reply", aiRes.reply());
            resp.getWriter().write(out.toString());
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject err = new JsonObject();
            err.addProperty("ok", false);
            err.addProperty("code", "INTERNAL_ERROR");
            err.addProperty("error", "Trợ lý AI đang tạm gián đoạn. Vui lòng thử lại sau.");
            resp.getWriter().write(err.toString());
        }
    }

    private Integer parseNullableInt(String raw) {
        if (raw == null || raw.isBlank() || "null".equalsIgnoreCase(raw)) return null;
        try {
            int val = Integer.parseInt(raw.trim());
            return val > 0 ? val : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
