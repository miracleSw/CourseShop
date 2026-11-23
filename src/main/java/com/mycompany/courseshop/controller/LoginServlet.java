package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.CartDAO;
import com.mycompany.courseshop.dao.UserDAO;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.User;
import com.mycompany.courseshop.utils.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        req.setAttribute("pageTitle", "Đăng nhập — CourseShop");
        req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String identifier = req.getParameter("identifier");
        String password = req.getParameter("password");

        if (identifier == null || identifier.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ email/số điện thoại và mật khẩu.");
            req.setAttribute("identifier", identifier);
            req.setAttribute("pageTitle", "Đăng nhập — CourseShop");
            req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.findByEmailOrPhone(identifier.trim());
        if (user == null || !PasswordUtil.verify(password, user.getPasswordHash())) {
            req.setAttribute("error", "Email/số điện thoại hoặc mật khẩu chưa chính xác.");
            req.setAttribute("identifier", identifier);
            req.setAttribute("pageTitle", "Đăng nhập — CourseShop");
            req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
            return;
        }

        if (!user.isStatus()) {
            req.setAttribute("error", "Tài khoản này đang bị tạm khóa. Vui lòng liên hệ quản trị viên.");
            req.setAttribute("identifier", identifier);
            req.setAttribute("pageTitle", "Đăng nhập — CourseShop");
            req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);
        // Merge any guest session cart items into MySQL cart_items and reload persisted cart
        @SuppressWarnings("unchecked")
        Map<Integer, Course> guestCart = (Map<Integer, Course>) session.getAttribute("cart");
        if (guestCart != null && !guestCart.isEmpty()) {
            cartDAO.mergeGuestCart(user.getId(), guestCart.keySet());
        } else {
            cartDAO.removeOwnedItems(user.getId());
        }
        session.setAttribute("cart", cartDAO.findCoursesByUser(user.getId()));
        session.setAttribute("flashSuccess", "Chào mừng " + user.getShortName() + " quay trở lại CourseShop!");

        String redirect = (String) session.getAttribute("redirectAfterLogin");
        if (redirect != null && !redirect.isBlank()) {
            session.removeAttribute("redirectAfterLogin");
            resp.sendRedirect(redirect);
            return;
        }
        if (user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }
}
