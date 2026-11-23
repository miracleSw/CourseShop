package com.mycompany.courseshop.controller.admin;

import com.google.gson.Gson;
import com.mycompany.courseshop.dao.OrderDAO;
import com.mycompany.courseshop.utils.FormatUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Map;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin", "/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Map<String, Object> stats = orderDAO.getDashboardStats();
        @SuppressWarnings("unchecked")
        Map<String, Long> revSeries = (Map<String, Long>) stats.get("revenueSeries");

        req.setAttribute("stats", stats);
        req.setAttribute("formattedRevenue", FormatUtil.formatVndAlways((BigDecimal) stats.get("totalRevenue")));
        req.setAttribute("chartLabelsJson", gson.toJson(revSeries.keySet()));
        req.setAttribute("chartValuesJson", gson.toJson(revSeries.values()));
        req.setAttribute("recentOrders", orderDAO.findAll(null).stream().limit(6).toList());
        req.setAttribute("adminNav", "dashboard");
        req.setAttribute("pageTitle", "Tổng quan Quản trị — CourseShop");
        req.getRequestDispatcher("/views/admin/dashboard.jsp").forward(req, resp);
    }
}
