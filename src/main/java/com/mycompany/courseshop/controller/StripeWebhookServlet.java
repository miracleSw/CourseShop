package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.CartDAO;
import com.mycompany.courseshop.dao.OrderDAO;
import com.mycompany.courseshop.dao.PaymentTransactionDAO;
import com.mycompany.courseshop.model.Order;
import com.mycompany.courseshop.service.EmailService;
import com.mycompany.courseshop.service.StripeService;
import com.mycompany.courseshop.utils.CsrfUtil;
import com.stripe.exception.EventDataObjectDeserializationException;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.model.EventDataObjectDeserializer;
import com.stripe.model.PaymentIntent;
import com.stripe.model.StripeObject;
import com.stripe.model.checkout.Session;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.Map;

/**
 * Production Stripe Webhook receiver verifying Stripe-Signature (HMAC-SHA256 + timestamp tolerance)
 * via official Stripe SDK Webhook.constructEvent(). Handles completed, async_succeeded,
 * async_failed, expired, and payment_intent.payment_failed / canceled events idempotently.
 */
@WebServlet(name = "StripeWebhookServlet", urlPatterns = {"/webhooks/stripe"})
public class StripeWebhookServlet extends HttpServlet {

    private final StripeService stripeService = new StripeService();
    private final EmailService emailService = new EmailService();
    private final OrderDAO orderDAO = new OrderDAO();
    private final CartDAO cartDAO = new CartDAO();
    private final PaymentTransactionDAO txDAO = new PaymentTransactionDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        if (!stripeService.isWebhookConfigured()) {
            resp.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            resp.getWriter().write("{\"error\":\"Webhook endpoint is not configured\"}");
            return;
        }

        String sigHeader = req.getHeader("Stripe-Signature");
        if (sigHeader == null || sigHeader.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Missing Stripe-Signature header\"}");
            return;
        }

        String payload = new String(req.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
        Event event;
        try {
            event = stripeService.verifyWebhookEvent(payload, sigHeader);
        } catch (SignatureVerificationException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Invalid webhook signature\"}");
            return;
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Malformed webhook payload\"}");
            return;
        }

        try {
            StripeObject obj = deserializeEventObject(event);
            String type = event.getType();

            switch (type) {
                case "checkout.session.completed" -> {
                    if (obj instanceof Session s) handleCheckoutSessionCompleted(s);
                }
                case "checkout.session.async_payment_succeeded" -> {
                    if (obj instanceof Session s) handleCheckoutSessionPaid(s, "Webhook xác nhận thanh toán không đồng bộ thành công.");
                }
                case "checkout.session.async_payment_failed" -> {
                    if (obj instanceof Session s) handleCheckoutSessionFailed(s, "Thanh toán không đồng bộ thất bại.");
                }
                case "checkout.session.expired" -> {
                    if (obj instanceof Session s) handleCheckoutSessionExpired(s);
                }
                case "payment_intent.payment_failed" -> {
                    if (obj instanceof PaymentIntent pi) handlePaymentIntentFailed(pi);
                }
                case "payment_intent.canceled" -> {
                    if (obj instanceof PaymentIntent pi) handlePaymentIntentCanceled(pi);
                }
                default -> {
                    // Unsubscribed event types acknowledged cleanly with 200 OK
                }
            }
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write("{\"received\":true}");
        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\":\"Database error processing webhook\"}");
        }
    }

    private StripeObject deserializeEventObject(Event event) {
        EventDataObjectDeserializer deserializer = event.getDataObjectDeserializer();
        if (deserializer.getObject().isPresent()) {
            return deserializer.getObject().get();
        }
        try {
            return deserializer.deserializeUnsafe();
        } catch (EventDataObjectDeserializationException e) {
            return null;
        }
    }

    private Order resolveOrderFromSession(Session s) {
        Order order = null;
        if (s.getClientReferenceId() != null && !s.getClientReferenceId().isBlank()) {
            order = orderDAO.findByOrderCode(s.getClientReferenceId());
        }
        if (order == null && s.getMetadata() != null && s.getMetadata().containsKey("order_code")) {
            order = orderDAO.findByOrderCode(s.getMetadata().get("order_code"));
        }
        if (order == null && s.getId() != null) {
            order = orderDAO.findByStripeSessionId(s.getId());
        }
        return order;
    }

    private void handleCheckoutSessionCompleted(Session s) throws SQLException {
        if ("paid".equalsIgnoreCase(s.getPaymentStatus()) || "no_payment_required".equalsIgnoreCase(s.getPaymentStatus())) {
            handleCheckoutSessionPaid(s, "Webhook xác nhận thanh toán Stripe thành công.");
        } else {
            Order order = resolveOrderFromSession(s);
            if (order != null) {
                txDAO.log(order.getId(), "STRIPE", s.getId(), order.getTotalAmount(),
                        "INITIATED", "Phiên thanh toán đã hoàn tất nhưng đang chờ xác nhận nguồn tiền.");
            }
        }
    }

    private void handleCheckoutSessionPaid(Session s, String message) throws SQLException {
        Order order = resolveOrderFromSession(s);
        if (order == null) return;
        long amountSubtotal = s.getAmountSubtotal() != null ? s.getAmountSubtotal() : order.getSubtotal().longValue();
        long amountTotal = s.getAmountTotal() != null ? s.getAmountTotal() : order.getTotalAmount().longValue();
        long amountDiscount = (s.getTotalDetails() != null && s.getTotalDetails().getAmountDiscount() != null)
                ? s.getTotalDetails().getAmountDiscount() : 0L;
        if (!stripeService.isAmountValidForOrder(order, amountSubtotal, amountDiscount, amountTotal)) {
            txDAO.log(order.getId(), "STRIPE", s.getId(), order.getTotalAmount(),
                    "FAILED", "Số tiền xác nhận từ Stripe không khớp với giá trị đơn hàng.");
            return;
        }
        BigDecimal finalTotal = BigDecimal.valueOf(amountTotal);
        if (amountTotal != order.getTotalAmount().longValue()) {
            orderDAO.updateAmountsFromStripe(order.getId(), BigDecimal.valueOf(amountDiscount), finalTotal);
        }
        if (s.getId() != null && (order.getStripeSessionId() == null || order.getStripeSessionId().isBlank())) {
            orderDAO.updateStripeSessionId(order.getId(), s.getId());
        }
        boolean wasAlreadyPaid = "PAID".equalsIgnoreCase(order.getStatus());
        orderDAO.markOrderPaidAndEnroll(order.getId());
        cartDAO.clearByUser(order.getUserId());
        txDAO.log(order.getId(), "STRIPE", s.getId(), finalTotal, "SUCCEEDED", message);
        if (!wasAlreadyPaid) {
            String baseUrl = com.mycompany.courseshop.config.AppConfig.getAppBaseUrl();
            if (baseUrl != null && !baseUrl.isBlank()) {
                emailService.sendOrderConfirmationAsync(orderDAO.findById(order.getId()),
                        baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl);
            }
        }
    }

    private void handleCheckoutSessionFailed(Session s, String message) throws SQLException {
        Order order = resolveOrderFromSession(s);
        if (order == null || "PAID".equalsIgnoreCase(order.getStatus())) return;
        orderDAO.updateStatus(order.getId(), "FAILED");
        txDAO.log(order.getId(), "STRIPE", s.getId(), order.getTotalAmount(), "FAILED", message);
    }

    private void handleCheckoutSessionExpired(Session s) throws SQLException {
        Order order = resolveOrderFromSession(s);
        if (order == null || !"PENDING".equalsIgnoreCase(order.getStatus())) return;
        orderDAO.updateStatus(order.getId(), "CANCELLED");
        txDAO.log(order.getId(), "STRIPE", s.getId(), order.getTotalAmount(),
                "CANCELLED", "Phiên thanh toán Stripe đã hết hạn.");
    }

    private void handlePaymentIntentFailed(PaymentIntent pi) throws SQLException {
        Map<String, String> meta = pi.getMetadata();
        if (meta == null || !meta.containsKey("order_code")) return;
        Order order = orderDAO.findByOrderCode(meta.get("order_code"));
        if (order == null || "PAID".equalsIgnoreCase(order.getStatus())) return;
        orderDAO.updateStatus(order.getId(), "FAILED");
        String reason = (pi.getLastPaymentError() != null && pi.getLastPaymentError().getMessage() != null)
                ? pi.getLastPaymentError().getMessage()
                : "Giao dịch thanh toán bị từ chối.";
        txDAO.log(order.getId(), "STRIPE", pi.getId(), order.getTotalAmount(), "FAILED", reason);
    }

    private void handlePaymentIntentCanceled(PaymentIntent pi) throws SQLException {
        Map<String, String> meta = pi.getMetadata();
        if (meta == null || !meta.containsKey("order_code")) return;
        Order order = orderDAO.findByOrderCode(meta.get("order_code"));
        if (order == null || !"PENDING".equalsIgnoreCase(order.getStatus())) return;
        orderDAO.updateStatus(order.getId(), "CANCELLED");
        txDAO.log(order.getId(), "STRIPE", pi.getId(), order.getTotalAmount(),
                "CANCELLED", "Giao dịch thanh toán đã bị hủy.");
    }
}
