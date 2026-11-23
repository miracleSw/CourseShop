package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.CategoryDAO;
import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.dao.LearningPathDAO;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Set;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home", "/courses"})
public class HomeServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final CourseDAO courseDAO = new CourseDAO();
    private final LearningPathDAO pathDAO = new LearningPathDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("q");
        String catParam = req.getParameter("category");
        String level = req.getParameter("level");
        String type = req.getParameter("type");
        String sort = req.getParameter("sort");
        String pageParam = req.getParameter("page");

        Integer categoryId = null;
        if (catParam != null && !catParam.isBlank()) {
            try {
                categoryId = Integer.parseInt(catParam);
            } catch (NumberFormatException ignored) {}
        }

        int page = 1;
        if (pageParam != null && !pageParam.isBlank()) {
            try {
                page = Math.max(1, Integer.parseInt(pageParam));
            } catch (NumberFormatException ignored) {}
        }

        int pageSize = 8;
        int totalCourses = courseDAO.countSearch(keyword, categoryId, level, type);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalCourses / pageSize));
        if (page > totalPages) page = totalPages;

        List<Course> courses = courseDAO.search(keyword, categoryId, level, type, sort, page, pageSize);

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        Set<Integer> ownedIds = (user != null)
                ? enrollmentDAO.getEnrolledCourseIds(user.getId())
                : Collections.emptySet();

        boolean hasActiveFilter = (keyword != null && !keyword.isBlank())
                || (categoryId != null && categoryId > 0)
                || (level != null && !level.isBlank())
                || (type != null && !type.isBlank());

        req.setAttribute("categories", categoryDAO.findAllWithCounts());
        req.setAttribute("learningPaths", pathDAO.findAllWithCourses());
        req.setAttribute("courses", courses);
        req.setAttribute("ownedIds", ownedIds);
        req.setAttribute("totalCourses", totalCourses);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("hasActiveFilter", hasActiveFilter);
        req.setAttribute("filterQ", keyword == null ? "" : keyword);
        req.setAttribute("filterCategory", categoryId);
        req.setAttribute("filterLevel", level == null ? "" : level);
        req.setAttribute("filterType", type == null ? "" : type);
        req.setAttribute("filterSort", sort == null ? "" : sort);
        req.setAttribute("pageTitle", "CourseShop — Giáo trình Lập trình Thực chiến");
        req.setAttribute("activeNav", "home");

        req.getRequestDispatcher("/views/home.jsp").forward(req, resp);
    }
}
