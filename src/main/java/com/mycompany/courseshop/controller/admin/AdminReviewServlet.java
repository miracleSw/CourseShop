package com.mycompany.courseshop.controller.admin;

import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "AdminReviewServlet", urlPatterns = {"/admin/reviews"})
public class AdminReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer courseId = parseNullableInt(req.getParameter("courseId"));
        Integer rating = parseNullableInt(req.getParameter("rating"));
        String q = req.getParameter("q");

        req.setAttribute("reviews", reviewDAO.findAllForAdmin(courseId, rating, q));
        req.setAttribute("courses", courseDAO.findAllForAdmin());
        req.setAttribute("filterCourseId", courseId);
        req.setAttribute("filterRating", rating);
        req.setAttribute("q", q == null ? "" : q.trim());
        req.setAttribute("adminNav", "reviews");
        req.setAttribute("pageTitle", "Kiểm duyệt Đánh giá — Quản trị CourseShop");
        req.getRequestDispatcher("/views/admin/reviews.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                reviewDAO.delete(id);
                req.getSession().setAttribute("flashSuccess", "Đã xóa đánh giá.");
            } catch (SQLException | NumberFormatException e) {
                e.printStackTrace();
                req.getSession().setAttribute("flashError", "Không thể xóa đánh giá lúc này.");
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/reviews");
    }

    private Integer parseNullableInt(String raw) {
        if (raw == null || raw.isBlank()) return null;
        try { return Integer.parseInt(raw.trim()); } catch (NumberFormatException e) { return null; }
    }
}
