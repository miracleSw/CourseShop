package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.UserDAO;
import com.mycompany.courseshop.model.User;
import com.mycompany.courseshop.utils.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (req.getSession(false) != null && req.getSession(false).getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        req.setAttribute("pageTitle", "Đăng ký tài khoản — CourseShop");
        req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        req.setAttribute("fullName", fullName);
        req.setAttribute("email", email);
        req.setAttribute("phone", phone);
        req.setAttribute("pageTitle", "Đăng ký tài khoản — CourseShop");

        if (fullName == null || fullName.trim().length() < 2) {
            req.setAttribute("error", "Vui lòng nhập họ và tên hợp lệ (tối thiểu 2 ký tự).");
            req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
            return;
        }
        if (email == null || !email.trim().matches("^[\\w.%+-]+@[\\w.-]+\\.[A-Za-z]{2,}$")) {
            req.setAttribute("error", "Địa chỉ email không đúng định dạng.");
            req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
            return;
        }
        if (password == null || password.length() < 6) {
            req.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Mật khẩu nhập lại không khớp.");
            req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
            return;
        }
        if (userDAO.findByEmail(email) != null) {
            req.setAttribute("error", "Email này đã được sử dụng. Bạn hãy đăng nhập hoặc dùng email khác.");
            req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
            return;
        }

        try {
            User created = userDAO.create(fullName, email, phone, PasswordUtil.hash(password), "USER");
            req.getSession(true).setAttribute("user", created);
            req.getSession().setAttribute("flashSuccess", "Tạo tài khoản thành công! Bạn có thể bắt đầu học miễn phí ngay.");
            resp.sendRedirect(req.getContextPath() + "/home");
        } catch (SQLException e) {
            req.setAttribute("error", "Không thể tạo tài khoản lúc này. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/views/register.jsp").forward(req, resp);
        }
    }
}
