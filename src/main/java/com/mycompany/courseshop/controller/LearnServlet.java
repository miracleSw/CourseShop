package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.Lesson;
import com.mycompany.courseshop.model.Section;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "LearnServlet", urlPatterns = {"/learn"})
public class LearnServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        int courseId = parseInt(req.getParameter("courseId"));
        int lessonId = parseInt(req.getParameter("lessonId"));

        Course course = courseDAO.findById(courseId);
        if (course == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy khóa học.");
            return;
        }

        boolean allowed = user.isAdmin() || enrollmentDAO.isEnrolled(user.getId(), courseId);
        if (!allowed) {
            req.getSession().setAttribute("flashError", "Bạn cần đăng ký khóa học này để truy cập không gian học tập.");
            resp.sendRedirect(req.getContextPath() + "/course?slug=" + course.getSlug());
            return;
        }

        List<Section> sections = courseDAO.findSectionsWithLessons(courseId, user.getId());
        List<Lesson> flatLessons = new ArrayList<>();
        int completedCount = 0;
        for (Section s : sections) {
            for (Lesson l : s.getLessons()) {
                flatLessons.add(l);
                if (l.isCompleted()) completedCount++;
            }
        }

        Lesson activeLesson = null;
        int activeIndex = -1;
        for (int i = 0; i < flatLessons.size(); i++) {
            if (lessonId > 0 && flatLessons.get(i).getId() == lessonId) {
                activeLesson = flatLessons.get(i);
                activeIndex = i;
                break;
            }
        }
        if (activeLesson == null && !flatLessons.isEmpty()) {
            // Default to first uncompleted lesson, or lesson 0
            activeIndex = 0;
            for (int i = 0; i < flatLessons.size(); i++) {
                if (!flatLessons.get(i).isCompleted()) {
                    activeIndex = i;
                    break;
                }
            }
            activeLesson = flatLessons.get(activeIndex);
        }

        Lesson prevLesson = (activeIndex > 0) ? flatLessons.get(activeIndex - 1) : null;
        Lesson nextLesson = (activeIndex >= 0 && activeIndex < flatLessons.size() - 1) ? flatLessons.get(activeIndex + 1) : null;

        int totalLessons = flatLessons.size();
        int progressPercent = totalLessons > 0 ? Math.round((completedCount * 100f) / totalLessons) : 0;

        req.setAttribute("course", course);
        req.setAttribute("sections", sections);
        req.setAttribute("activeLesson", activeLesson);
        req.setAttribute("prevLesson", prevLesson);
        req.setAttribute("nextLesson", nextLesson);
        req.setAttribute("completedCount", completedCount);
        req.setAttribute("totalLessons", totalLessons);
        req.setAttribute("progressPercent", progressPercent);
        req.setAttribute("lessonNotes", activeLesson != null
                ? enrollmentDAO.findNotes(user.getId(), courseId, activeLesson.getId()) : List.of());
        req.setAttribute("allCourseNotes", enrollmentDAO.findNotes(user.getId(), courseId, null));
        req.setAttribute("pageTitle", (activeLesson != null ? activeLesson.getTitle() + " · " : "") + course.getTitle());

        req.getRequestDispatcher("/views/learn.jsp").forward(req, resp);
    }

    private int parseInt(String val) {
        try {
            return Integer.parseInt(val);
        } catch (Exception e) {
            return 0;
        }
    }
}
