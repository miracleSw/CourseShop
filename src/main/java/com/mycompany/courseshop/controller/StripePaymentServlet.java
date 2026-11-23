package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.CartDAO;
import com.mycompany.courseshop.dao.OrderDAO;
import com.mycompany.courseshop.dao.PaymentTransactionDAO;
import com.mycompany.courseshop.dao.SettingsDAO;
import com.mycompany.courseshop.model.Order;
import com.mycompany.courseshop.model.User;
import com.mycompany.courseshop.service.EmailService;
import com.mycompany.courseshop.service.StripeService;
import com.mycompany.courseshop.utils.CsrfUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

/**
 * Handles real Stripe Checkout return callbacks (/payment/stripe/success, /payment/stripe/cancel)
 * and order result page (/payment/result). Transaction states are verified exclusively server-side
 * with Stripe API or Webhook — never modified from frontend parameters.
 */
@WebServlet(name = "StripePaymentServlet", urlPatterns = {"/payment/*"})
public class StripePaymentServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final CartDAO cartDAO = new CartDAO();
    private final PaymentTransactionDAO txDAO = new PaymentTransactionDAO();
    private final SettingsDAO settingsDAO = new SettingsDAO();
    private final StripeService stripeService = new StripeService();
    private final EmailService emailService = new EmailService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        User user = (User) req.getSession().getAttribute("user");

        switch (path) {
            case "/stripe/success" -> {
                String sessionId = req.getParameter("session_id");
                String orderCode = req.getParameter("orderCode");
                Order order = orderDAO.findByOrderCode(orderCode);
                if (order == null || (order.getUserId() != user.getId() && !user.isAdmin())) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn hàng.");
                    return;
                }

                // If webhook already finalized order as PAID, show success immediately
                if ("PAID".equalsIgnoreCase(order.getStatus())) {
                    clearCart(req.getSession(), user.getId());
                    resp.sendRedirect(req.getContextPath() + "/payment/result?orderCode=" + order.getOrderCode());
                    return;
                }

                // Verify session server-side against Stripe API (ensure session matches stored session ID)
                String storedSid = order.getStripeSessionId();
                String sidToVerify = (storedSid != null && !storedSid.isBlank()) ? storedSid : sessionId;
                if (sessionId != null && storedSid != null && !storedSid.isBlank() && !storedSid.equals(sessionId)) {
                    req.getSession().setAttribute("flashError", "Phiên thanh toán không khớp với đơn hàng.");
                    resp.sendRedirect(req.getContextPath() + "/payment/result?orderCode=" + order.getOrderCode());
                    return;
                }

                StripeService.SessionVerifyResult verify = stripeService.retrieveCheckoutSession(sidToVerify);
                if (verify.ok() && verify.paid() && stripeService.isAmountValidForOrder(
                        order, verify.amountSubtotal(), verify.amountDiscount(), verify.amountTotal())) {
                    try {
                        BigDecimal finalTotal = BigDecimal.valueOf(verify.amountTotal());
                        if (verify.amountTotal() != order.getTotalAmount().longValue()) {
                            orderDAO.updateAmountsFromStripe(order.getId(), BigDecimal.valueOf(verify.amountDiscount()), finalTotal);
                        }
                        orderDAO.markOrderPaidAndEnroll(order.getId());
                        txDAO.log(order.getId(), "STRIPE", sidToVerify, finalTotal,
                                "SUCCEEDED", "Xác minh phiên thanh toán Stripe thành công.");
                        clearCart(req.getSession(), user.getId());
                        Order refreshed = orderDAO.findById(order.getId());
                        emailService.sendOrderConfirmationAsync(refreshed, CsrfUtil.resolvePublicBaseUrl(req));
                        req.getSession().setAttribute("flashSuccess", "Thanh toán thành công! Khóa học đã sẵn sàng trong tài khoản của bạn.");
                    } catch (SQLException e) {
                        req.getSession().setAttribute("flashError", "Thanh toán đã xác nhận nhưng hệ thống đang đồng bộ quyền học. Vui lòng tải lại sau ít giây.");
                    }
                } else if (verify.ok() && "expired".equalsIgnoreCase(verify.status())) {
                    try {
                        orderDAO.updateStatus(order.getId(), "CANCELLED");
                        txDAO.log(order.getId(), "STRIPE", sidToVerify, order.getTotalAmount(),
                                "CANCELLED", "Phiên thanh toán đã hết hạn.");
                    } catch (SQLException ignored) {}
                    req.getSession().setAttribute("flashError", "Phiên thanh toán đã hết hạn. Bạn có thể tạo đơn mới từ giỏ hàng.");
                } else if (verify.ok() && "unpaid".equalsIgnoreCase(verify.paymentStatus())) {
                    req.getSession().setAttribute("flashSuccess", "Giao dịch đang được xử lý. Khóa học sẽ tự động mở ngay khi hoàn tất.");
                } else {
                    req.getSession().setAttribute("flashError",
                            verify.errorMessage() != null ? verify.errorMessage() : "Chưa thể xác nhận trạng thái thanh toán.");
                }
                resp.sendRedirect(req.getContextPath() + "/payment/result?orderCode=" + order.getOrderCode());
            }
            case "/stripe/cancel" -> {
                String orderCode = req.getParameter("orderCode");
                Order order = orderDAO.findByOrderCode(orderCode);
                if (order != null && order.getUserId() == user.getId() && "PENDING".equalsIgnoreCase(order.getStatus())) {
                    try {
                        orderDAO.updateStatus(order.getId(), "CANCELLED");
                        txDAO.log(order.getId(), "STRIPE", order.getStripeSessionId(),
                                order.getTotalAmount(), "CANCELLED", "Khách hàng hủy thanh toán trên cổng Stripe.");
                    } catch (SQLException ignored) {}
                }
                req.getSession().setAttribute("flashError", "Bạn đã hủy phiên thanh toán. Các khóa học vẫn được giữ trong giỏ hàng.");
                resp.sendRedirect(req.getContextPath() + "/payment/result?orderCode=" + (order != null ? order.getOrderCode() : ""));
            }
            case "/result" -> {
                String orderCode = req.getParameter("orderCode");
                Order order = orderDAO.findByOrderCode(orderCode);
                if (order == null || (order.getUserId() != user.getId() && !user.isAdmin())) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn hàng.");
                    return;
                }
                if ("PENDING".equalsIgnoreCase(order.getStatus()) && "BANK_TRANSFER".equalsIgnoreCase(order.getPaymentMethod())) {
                    String bankBin = settingsDAO.getBankBin();
                    String accNo = settingsDAO.get("bank.account_number", "").replaceAll("[^0-9A-Za-z]", "");
                    String accHolder = settingsDAO.get("bank.account_holder", "");
                    long amt = order.getTotalAmount() != null ? order.getTotalAmount().longValue() : 0L;
                    if (!bankBin.isBlank() && !accNo.isBlank() && amt > 0) {
                        String qrUrl = "https://img.vietqr.io/image/" + bankBin + "-" + accNo + "-compact2.png"
                                + "?amount=" + amt
                                + "&addInfo=" + URLEncoder.encode(order.getOrderCode(), StandardCharsets.UTF_8)
                                + "&accountName=" + URLEncoder.encode(accHolder, StandardCharsets.UTF_8);
                        req.setAttribute("vietQrUrl", qrUrl);
                    }
                }
                req.setAttribute("order", order);
                req.setAttribute("pageTitle", "Kết quả đơn hàng #" + order.getOrderCode() + " — CourseShop");
                req.getRequestDispatcher("/views/payment-result.jsp").forward(req, resp);
            }
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void clearCart(HttpSession session, int userId) {
        cartDAO.clearByUser(userId);
        if (session == null) return;
        CartServlet.getOrCreateCart(session).clear();
        session.removeAttribute("appliedCoupon");
    }
}
