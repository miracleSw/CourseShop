package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.PasswordResetDAO;
import com.mycompany.courseshop.dao.UserDAO;
import com.mycompany.courseshop.utils.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/reset-password"})
public class ResetPasswordServlet extends HttpServlet {

    private final PasswordResetDAO resetDAO = new PasswordResetDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");
        Integer userId = resetDAO.findValidUserIdByToken(token);
        req.setAttribute("token", token);
        req.setAttribute("tokenValid", userId != null);
        req.setAttribute("pageTitle", "Đặt lại mật khẩu — CourseShop");
        req.getRequestDispatcher("/views/reset-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirmPassword");

        Integer userId = resetDAO.findValidUserIdByToken(token);
        if (userId == null) {
            req.setAttribute("tokenValid", false);
            req.setAttribute("pageTitle", "Đặt lại mật khẩu — CourseShop");
            req.getRequestDispatcher("/views/reset-password.jsp").forward(req, resp);
            return;
        }

        if (password == null || password.length() < 6) {
            req.setAttribute("token", token);
            req.setAttribute("tokenValid", true);
            req.setAttribute("error", "Mật khẩu mới phải có ít nhất 6 ký tự.");
            req.setAttribute("pageTitle", "Đặt lại mật khẩu — CourseShop");
            req.getRequestDispatcher("/views/reset-password.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(confirm)) {
            req.setAttribute("token", token);
            req.setAttribute("tokenValid", true);
            req.setAttribute("error", "Mật khẩu nhập lại không khớp.");
            req.setAttribute("pageTitle", "Đặt lại mật khẩu — CourseShop");
            req.getRequestDispatcher("/views/reset-password.jsp").forward(req, resp);
            return;
        }

        try {
            userDAO.updatePassword(userId, PasswordUtil.hash(password));
            resetDAO.markUsed(token);
            req.getSession(true).setAttribute("flashSuccess", "Đặt lại mật khẩu thành công! Bạn có thể đăng nhập bằng mật khẩu mới.");
            resp.sendRedirect(req.getContextPath() + "/login");
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("token", token);
            req.setAttribute("tokenValid", true);
            req.setAttribute("error", "Không thể cập nhật mật khẩu lúc này. Vui lòng thử lại.");
            req.setAttribute("pageTitle", "Đặt lại mật khẩu — CourseShop");
            req.getRequestDispatcher("/views/reset-password.jsp").forward(req, resp);
        }
    }
}
