package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.CertificateDAO;
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

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final CertificateDAO certificateDAO = new CertificateDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User sessionUser = (User) req.getSession().getAttribute("user");
        User fresh = userDAO.findById(sessionUser.getId());
        if (fresh != null) {
            req.getSession().setAttribute("user", fresh);
            sessionUser = fresh;
        }
        req.setAttribute("certificates", certificateDAO.findByUser(sessionUser.getId()));
        req.setAttribute("pageTitle", "Hồ sơ cá nhân — CourseShop");
        req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        String action = req.getParameter("action");

        try {
            if ("updateInfo".equalsIgnoreCase(action)) {
                String fullName = req.getParameter("fullName");
                String phone = req.getParameter("phone");
                if (fullName == null || fullName.trim().length() < 2) {
                    req.getSession().setAttribute("flashError", "Họ và tên cần tối thiểu 2 ký tự.");
                } else {
                    userDAO.updateProfile(user.getId(), fullName, phone);
                    User refreshed = userDAO.findById(user.getId());
                    if (refreshed != null) req.getSession().setAttribute("user", refreshed);
                    req.getSession().setAttribute("flashSuccess", "Đã cập nhật thông tin cá nhân.");
                }
            } else if ("changePassword".equalsIgnoreCase(action)) {
                String currentPw = req.getParameter("currentPassword");
                String newPw = req.getParameter("newPassword");
                String confirmPw = req.getParameter("confirmPassword");
                User fresh = userDAO.findById(user.getId());
                if (fresh == null || !PasswordUtil.verify(currentPw, fresh.getPasswordHash())) {
                    req.getSession().setAttribute("flashError", "Mật khẩu hiện tại không chính xác.");
                } else if (newPw == null || newPw.length() < 6) {
                    req.getSession().setAttribute("flashError", "Mật khẩu mới cần tối thiểu 6 ký tự.");
                } else if (!newPw.equals(confirmPw)) {
                    req.getSession().setAttribute("flashError", "Mật khẩu xác nhận không khớp.");
                } else {
                    userDAO.updatePassword(user.getId(), PasswordUtil.hash(newPw));
                    req.getSession().setAttribute("flashSuccess", "Đổi mật khẩu thành công.");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.getSession().setAttribute("flashError", "Không thể cập nhật tài khoản lúc này. Vui lòng thử lại.");
        }
        resp.sendRedirect(req.getContextPath() + "/profile");
    }
}
