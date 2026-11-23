package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "EnrollFreeServlet", urlPatterns = {"/enroll-free"})
public class EnrollFreeServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        int courseId;
        try {
            courseId = Integer.parseInt(req.getParameter("courseId"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        Course course = courseDAO.findById(courseId);
        if (course == null || !course.isFree()) {
            req.getSession().setAttribute("flashError", "Khóa học này không áp dụng đăng ký miễn phí.");
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        try {
            enrollmentDAO.enrollFree(user.getId(), courseId);
            req.getSession().setAttribute("flashSuccess", "Đã đăng ký thành công khóa học \"" + course.getTitle() + "\". Bắt đầu học ngay!");
            resp.sendRedirect(req.getContextPath() + "/learn?courseId=" + courseId);
        } catch (SQLException e) {
            req.getSession().setAttribute("flashError", "Không thể đăng ký khóa học lúc này, vui lòng thử lại.");
            resp.sendRedirect(req.getContextPath() + "/course?slug=" + course.getSlug());
        }
    }
}
