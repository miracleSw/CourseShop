package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.dao.ReviewDAO;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ReviewServlet", urlPatterns = {"/review"})
public class ReviewServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        int courseId = parseInt(req.getParameter("courseId"), 0);
        int rating = parseInt(req.getParameter("rating"), 5);
        String comment = req.getParameter("comment");

        Course course = courseDAO.findById(courseId);
        if (course == null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        if (!user.isAdmin() && !enrollmentDAO.isEnrolled(user.getId(), courseId)) {
            req.getSession().setAttribute("flashError", "Chỉ học viên đã đăng ký khóa học mới có thể viết đánh giá.");
            resp.sendRedirect(req.getContextPath() + "/course?slug=" + course.getSlug() + "#reviews");
            return;
        }

        if (comment == null || comment.trim().length() < 5) {
            req.getSession().setAttribute("flashError", "Vui lòng nhập nhận xét tối thiểu 5 ký tự.");
            resp.sendRedirect(req.getContextPath() + "/course?slug=" + course.getSlug() + "#reviews");
            return;
        }

        try {
            reviewDAO.upsert(user.getId(), courseId, rating, comment);
            req.getSession().setAttribute("flashSuccess", "Cảm ơn bạn đã gửi đánh giá cho khóa học!");
        } catch (SQLException e) {
            req.getSession().setAttribute("flashError", "Không thể lưu đánh giá lúc này.");
        }
        resp.sendRedirect(req.getContextPath() + "/course?slug=" + course.getSlug() + "#reviews");
    }

    private int parseInt(String v, int def) {
        try {
            return Integer.parseInt(v);
        } catch (Exception e) {
            return def;
        }
    }
}
