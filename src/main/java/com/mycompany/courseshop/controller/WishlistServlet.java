package com.mycompany.courseshop.controller;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mycompany.courseshop.dao.WishlistDAO;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.stream.Collectors;

@WebServlet(name = "WishlistServlet", urlPatterns = {"/api/wishlist"})
public class WishlistServlet extends HttpServlet {

    private final WishlistDAO wishlistDAO = new WishlistDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        User user = (User) req.getSession().getAttribute("user");

        try {
            int courseId;
            String ct = req.getContentType();
            if (ct != null && ct.contains("application/json")) {
                String body = req.getReader().lines().collect(Collectors.joining());
                JsonObject json = JsonParser.parseString(body).getAsJsonObject();
                courseId = json.get("courseId").getAsInt();
            } else {
                courseId = Integer.parseInt(req.getParameter("courseId"));
            }

            boolean saved = wishlistDAO.toggle(user.getId(), courseId);
            JsonObject out = new JsonObject();
            out.addProperty("ok", true);
            out.addProperty("saved", saved);
            out.addProperty("message", saved ? "Đã lưu vào danh sách yêu thích." : "Đã bỏ khỏi danh sách yêu thích.");
            resp.getWriter().write(out.toString());
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"ok\":false,\"error\":\"Không thể cập nhật danh sách yêu thích.\"}");
        }
    }
}
