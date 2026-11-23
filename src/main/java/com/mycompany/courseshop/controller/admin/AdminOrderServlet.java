package com.mycompany.courseshop.controller.admin;

import com.mycompany.courseshop.dao.OrderDAO;
import com.mycompany.courseshop.dao.PaymentTransactionDAO;
import com.mycompany.courseshop.model.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/admin/orders"})
public class AdminOrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final PaymentTransactionDAO txDAO = new PaymentTransactionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String status = req.getParameter("status");
        req.setAttribute("orders", orderDAO.findAll(status));
        req.setAttribute("statusFilter", status == null ? "" : status);
        req.setAttribute("adminNav", "orders");
        req.setAttribute("pageTitle", "Quản lý Đơn hàng — Admin CourseShop");
        req.getRequestDispatcher("/views/admin/orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        int orderId;
        try {
            orderId = Integer.parseInt(req.getParameter("orderId"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        try {
            Order order = orderDAO.findById(orderId);
            if ("approve".equalsIgnoreCase(action)) {
                orderDAO.markOrderPaidAndEnroll(orderId);
                if (order != null) {
                    txDAO.log(orderId, order.getPaymentMethod(), order.getOrderCode(), order.getTotalAmount(),
                            "SUCCEEDED", "Quản trị viên xác nhận duyệt đơn & kích hoạt khóa học.");
                }
                req.getSession().setAttribute("flashSuccess", "Đã duyệt đơn hàng và tự động cấp quyền học cho học viên.");
            } else if ("cancel".equalsIgnoreCase(action)) {
                orderDAO.updateStatus(orderId, "CANCELLED");
                if (order != null) {
                    txDAO.log(orderId, order.getPaymentMethod(), order.getOrderCode(), order.getTotalAmount(),
                            "CANCELLED", "Quản trị viên hủy đơn hàng.");
                }
                req.getSession().setAttribute("flashSuccess", "Đã hủy đơn hàng.");
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("flashError", "Lỗi cập nhật đơn hàng: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/orders");
    }
}
