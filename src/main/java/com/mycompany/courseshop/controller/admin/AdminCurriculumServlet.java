package com.mycompany.courseshop.controller.admin;

import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.Lesson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "AdminCurriculumServlet", urlPatterns = {"/admin/curriculum"})
public class AdminCurriculumServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int courseId = parseInt(req.getParameter("courseId"), 0);
        Course course = courseDAO.findById(courseId);
        if (course == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/courses");
            return;
        }
        req.setAttribute("course", course);
        req.setAttribute("sections", courseDAO.findSectionsWithLessons(courseId, null));
        req.setAttribute("adminNav", "courses");
        req.setAttribute("pageTitle", "Giáo trình: " + course.getCode() + " — Admin CourseShop");
        req.getRequestDispatcher("/views/admin/curriculum.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int courseId = parseInt(req.getParameter("courseId"), 0);
        String action = req.getParameter("action");

        try {
            switch (action == null ? "" : action) {
                case "addSection" -> {
                    String title = req.getParameter("title");
                    int sort = parseInt(req.getParameter("sortOrder"), 1);
                    if (title != null && !title.isBlank()) {
                        courseDAO.createSection(courseId, title, sort);
                        req.getSession().setAttribute("flashSuccess", "Đã thêm chương mới.");
                    }
                }
                case "deleteSection" -> {
                    courseDAO.deleteSection(parseInt(req.getParameter("sectionId"), 0));
                    req.getSession().setAttribute("flashSuccess", "Đã xóa chương và các bài học bên trong.");
                }
                case "addLesson" -> {
                    Lesson l = new Lesson();
                    l.setCourseId(courseId);
                    l.setSectionId(parseInt(req.getParameter("sectionId"), 0));
                    l.setTitle(req.getParameter("title") == null ? "" : req.getParameter("title").trim());
                    l.setVideoUrl(req.getParameter("videoUrl"));
                    l.setDurationSeconds(parseInt(req.getParameter("durationMinutes"), 10) * 60);
                    l.setContentText(req.getParameter("contentText"));
                    l.setPreview("1".equals(req.getParameter("isPreview")));
                    l.setSortOrder(parseInt(req.getParameter("sortOrder"), 1));
                    if (!l.getTitle().isBlank() && l.getSectionId() > 0) {
                        courseDAO.createLesson(l);
                        req.getSession().setAttribute("flashSuccess", "Đã thêm bài học \"" + l.getTitle() + "\".");
                    }
                }
                case "deleteLesson" -> {
                    courseDAO.deleteLesson(parseInt(req.getParameter("lessonId"), 0));
                    req.getSession().setAttribute("flashSuccess", "Đã xóa bài học.");
                }
                default -> {}
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("flashError", "Lỗi thao tác giáo trình: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/curriculum?courseId=" + courseId);
    }

    private int parseInt(String v, int def) {
        try { return Integer.parseInt(v); } catch (Exception e) { return def; }
    }
}
