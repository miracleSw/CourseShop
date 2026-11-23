package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.CertificateDAO;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.dao.OrderDAO;
import com.mycompany.courseshop.dao.WishlistDAO;
import com.mycompany.courseshop.model.Enrollment;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "MyCoursesServlet", urlPatterns = {"/my-courses"})
public class MyCoursesServlet extends HttpServlet {

    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final CertificateDAO certificateDAO = new CertificateDAO();
    private final WishlistDAO wishlistDAO = new WishlistDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        List<Enrollment> enrollments = enrollmentDAO.findByUserWithProgress(user.getId());
        Map<Integer, String> certMap = certificateDAO.findCodeMapByUser(user.getId());

        for (Enrollment en : enrollments) {
            String code = certMap.get(en.getCourseId());
            if (code == null && en.getProgressPercent() == 100 && en.getTotalLessons() > 0) {
                try {
                    code = certificateDAO.issueIfNotExists(user.getId(), en.getCourseId());
                } catch (Exception ignored) {}
            }
            en.setCertificateCode(code);
        }

        req.setAttribute("enrollments", enrollments);
        req.setAttribute("wishlistCourses", wishlistDAO.findCoursesByUser(user.getId()));
        req.setAttribute("certificates", certificateDAO.findByUser(user.getId()));
        req.setAttribute("orders", orderDAO.findByUser(user.getId()));
        req.setAttribute("pageTitle", "Khóa học của tôi — CourseShop");
        req.setAttribute("activeNav", "my-courses");
        req.getRequestDispatcher("/views/my-courses.jsp").forward(req, resp);
    }
}
