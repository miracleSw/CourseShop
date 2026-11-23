package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.dao.LearningPathDAO;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Collections;
import java.util.Set;

@WebServlet(name = "LearningPathServlet", urlPatterns = {"/paths"})
public class LearningPathServlet extends HttpServlet {

    private final LearningPathDAO pathDAO = new LearningPathDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        Set<Integer> ownedIds = (user != null)
                ? enrollmentDAO.getEnrolledCourseIds(user.getId())
                : Collections.emptySet();

        req.setAttribute("learningPaths", pathDAO.findAllWithCourses());
        req.setAttribute("ownedIds", ownedIds);
        req.setAttribute("pageTitle", "Lộ trình học tập — CourseShop");
        req.setAttribute("activeNav", "paths");
        req.getRequestDispatcher("/views/paths.jsp").forward(req, resp);
    }
}
