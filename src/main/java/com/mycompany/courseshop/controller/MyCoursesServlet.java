package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.dao.OrderDAO;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "MyCoursesServlet", urlPatterns = {"/my-courses"})
public class MyCoursesServlet extends HttpServlet {

    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        req.setAttribute("enrollments", enrollmentDAO.findByUserWithProgress(user.getId()));
        req.setAttribute("orders", orderDAO.findByUser(user.getId()));
        req.setAttribute("pageTitle", "Khóa học của tôi — CourseShop");
        req.setAttribute("activeNav", "my-courses");
        req.getRequestDispatcher("/views/my-courses.jsp").forward(req, resp);
    }
}
