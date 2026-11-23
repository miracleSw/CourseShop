package com.mycompany.courseshop.controller.admin;

import com.mycompany.courseshop.dao.UserDAO;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "AdminUserServlet", urlPatterns = {"/admin/users"})
public class AdminUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String q = req.getParameter("q");
        req.setAttribute("q", q == null ? "" : q.trim());
        req.setAttribute("users", userDAO.searchAll(q));
        req.setAttribute("adminNav", "users");
        req.setAttribute("pageTitle", "Quản lý Người dùng — Quản trị CourseShop");
        req.getRequestDispatcher("/views/admin/users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User current = (User) req.getSession().getAttribute("user");
        String action = req.getParameter("action");
        int targetId;
        try {
            targetId = Integer.parseInt(req.getParameter("userId"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        if (targetId == current.getId()) {
            req.getSession().setAttribute("flashError", "Không thể tự thay đổi trạng thái hoặc quyền tài khoản đang đăng nhập.");
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        try {
            if ("toggleStatus".equalsIgnoreCase(action)) {
                boolean next = "1".equals(req.getParameter("nextStatus"));
                userDAO.updateStatus(targetId, next);
                req.getSession().setAttribute("flashSuccess", next ? "Đã mở khóa tài khoản." : "Đã khóa tài khoản.");
            } else if ("toggleRole".equalsIgnoreCase(action)) {
                String nextRole = "ADMIN".equalsIgnoreCase(req.getParameter("nextRole")) ? "ADMIN" : "USER";
                userDAO.updateRole(targetId, nextRole);
                req.getSession().setAttribute("flashSuccess", "Đã cập nhật vai trò thành " + ("ADMIN".equals(nextRole) ? "Quản trị viên" : "Học viên") + ".");
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("flashError", "Lỗi cập nhật tài khoản.");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}
