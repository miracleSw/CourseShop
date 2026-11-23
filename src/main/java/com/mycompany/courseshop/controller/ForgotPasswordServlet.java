package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.PasswordResetDAO;
import com.mycompany.courseshop.dao.UserDAO;
import com.mycompany.courseshop.model.User;
import com.mycompany.courseshop.service.EmailService;
import com.mycompany.courseshop.utils.CsrfUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final PasswordResetDAO resetDAO = new PasswordResetDAO();
    private final EmailService emailService = new EmailService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("emailConfigured", emailService.isConfigured());
        req.setAttribute("pageTitle", "Quên mật khẩu — CourseShop");
        req.getRequestDispatcher("/views/forgot-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        req.setAttribute("email", email);
        req.setAttribute("emailConfigured", emailService.isConfigured());
        req.setAttribute("pageTitle", "Quên mật khẩu — CourseShop");

        if (email == null || !email.trim().contains("@")) {
            req.setAttribute("error", "Vui lòng nhập địa chỉ email hợp lệ.");
            req.getRequestDispatcher("/views/forgot-password.jsp").forward(req, resp);
            return;
        }

        if (!emailService.isConfigured()) {
            req.setAttribute("error", "Tính năng gửi email khôi phục hiện tạm ngưng. Vui lòng liên hệ bộ phận hỗ trợ để được đặt lại mật khẩu.");
            req.getRequestDispatcher("/views/forgot-password.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.findByEmail(email.trim());
        if (user != null && user.isStatus()) {
            try {
                String rawToken = resetDAO.createToken(user.getId());
                String baseUrl = CsrfUtil.resolvePublicBaseUrl(req);
                String resetUrl = baseUrl + "/reset-password?token=" + URLEncoder.encode(rawToken, StandardCharsets.UTF_8);
                EmailService.SendResult result = emailService.sendPasswordResetEmail(user, resetUrl);
                if (!result.ok()) {
                    req.setAttribute("error", "Không thể gửi email khôi phục lúc này. Vui lòng thử lại sau ít phút.");
                    req.getRequestDispatcher("/views/forgot-password.jsp").forward(req, resp);
                    return;
                }
            } catch (Exception e) {
                e.printStackTrace();
                req.setAttribute("error", "Không thể xử lý yêu cầu lúc này. Vui lòng thử lại sau.");
                req.getRequestDispatcher("/views/forgot-password.jsp").forward(req, resp);
                return;
            }
        }

        // Always show uniform neutral confirmation to prevent email enumeration
        req.setAttribute("sent", true);
        req.getRequestDispatcher("/views/forgot-password.jsp").forward(req, resp);
    }
}
