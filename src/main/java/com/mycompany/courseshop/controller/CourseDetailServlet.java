package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.dao.ReviewDAO;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.Lesson;
import com.mycompany.courseshop.model.Section;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "CourseDetailServlet", urlPatterns = {"/course"})
public class CourseDetailServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String slug = req.getParameter("slug");
        String idParam = req.getParameter("id");

        Course course = null;
        if (slug != null && !slug.isBlank()) {
            course = courseDAO.findBySlug(slug);
        } else if (idParam != null && !idParam.isBlank()) {
            try {
                course = courseDAO.findById(Integer.parseInt(idParam));
            } catch (NumberFormatException ignored) {}
        }

        if (course == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy khóa học yêu cầu.");
            return;
        }

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        boolean enrolled = (user != null) && enrollmentDAO.isEnrolled(user.getId(), course.getId());

        List<Section> sections = courseDAO.findSectionsWithLessons(course.getId(), user != null ? user.getId() : null);
        Lesson firstPreview = null;
        for (Section s : sections) {
            for (Lesson l : s.getLessons()) {
                if (l.isPreview()) {
                    firstPreview = l;
                    break;
                }
            }
            if (firstPreview != null) break;
        }
        if (firstPreview == null && !sections.isEmpty() && !sections.get(0).getLessons().isEmpty()) {
            firstPreview = sections.get(0).getLessons().get(0);
        }

        @SuppressWarnings("unchecked")
        Map<Integer, Course> cart = (session != null) ? (Map<Integer, Course>) session.getAttribute("cart") : null;
        boolean inCart = cart != null && cart.containsKey(course.getId());

        req.setAttribute("course", course);
        req.setAttribute("sections", sections);
        req.setAttribute("firstPreview", firstPreview);
        req.setAttribute("enrolled", enrolled);
        req.setAttribute("inCart", inCart);
        req.setAttribute("reviews", reviewDAO.findByCourse(course.getId()));
        req.setAttribute("ratingDist", reviewDAO.getRatingDistribution(course.getId()));
        req.setAttribute("pageTitle", course.getTitle() + " — CourseShop");
        req.setAttribute("activeNav", "home");

        req.getRequestDispatcher("/views/course-detail.jsp").forward(req, resp);
    }
}
