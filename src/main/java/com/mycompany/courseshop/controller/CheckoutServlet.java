package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.config.AppConfig;
import com.mycompany.courseshop.dao.CartDAO;
import com.mycompany.courseshop.dao.CouponDAO;
import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.dao.OrderDAO;
import com.mycompany.courseshop.dao.PaymentTransactionDAO;
import com.mycompany.courseshop.model.Coupon;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.Order;
import com.mycompany.courseshop.model.User;
import com.mycompany.courseshop.service.StripeService;
import com.mycompany.courseshop.utils.FormatUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final CouponDAO couponDAO = new CouponDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final CartDAO cartDAO = new CartDAO();
    private final PaymentTransactionDAO txDAO = new PaymentTransactionDAO();
    private final StripeService stripeService = new StripeService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        User user = (User) session.getAttribute("user");
        cartDAO.removeOwnedItems(user.getId());
        Map<Integer, Course> cart = cartDAO.findCoursesByUser(user.getId());
        session.setAttribute("cart", cart);

        List<Course> items = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        for (Integer cid : new ArrayList<>(cart.keySet())) {
            Course fresh = courseDAO.findById(cid);
            if (fresh != null && !fresh.isFree()) {
                items.add(fresh);
                subtotal = subtotal.add(fresh.getEffectivePrice());
            } else {
                cart.remove(cid);
            }
        }

        if (items.isEmpty()) {
            session.setAttribute("flashError", "Giỏ hàng đang trống. Hãy chọn ít nhất 1 khóa học trước khi thanh toán.");
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        Coupon coupon = (Coupon) session.getAttribute("appliedCoupon");
        BigDecimal discount = BigDecimal.ZERO;
        if (coupon != null) {
            Coupon fresh = couponDAO.findByCode(coupon.getCode());
            if (fresh != null && fresh.isValidNow()) {
                coupon = fresh;
                discount = fresh.calculateDiscount(subtotal);
            } else {
                coupon = null;
                session.removeAttribute("appliedCoupon");
            }
        }
        BigDecimal total = subtotal.subtract(discount).max(BigDecimal.ZERO);

        req.setAttribute("cartItems", items);
        req.setAttribute("appliedCoupon", coupon);
        req.setAttribute("formattedSubtotal", FormatUtil.formatVndAlways(subtotal));
        req.setAttribute("formattedDiscount", FormatUtil.formatVndAlways(discount));
        req.setAttribute("formattedTotal", FormatUtil.formatVndAlways(total));
        req.setAttribute("stripeAvailable", stripeService.isConfigured());
        req.setAttribute("pageTitle", "Thanh toán đơn hàng — CourseShop");
        req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        User user = (User) session.getAttribute("user");
        cartDAO.removeOwnedItems(user.getId());
        Map<Integer, Course> cart = cartDAO.findCoursesByUser(user.getId());
        session.setAttribute("cart", cart);

        List<Course> items = new ArrayList<>();
        for (Integer cid : new ArrayList<>(cart.keySet())) {
            Course fresh = courseDAO.findById(cid);
            if (fresh != null && !fresh.isFree()) items.add(fresh);
        }
        if (items.isEmpty()) {
            session.setAttribute("flashError", "Không có khóa học hợp lệ trong giỏ hàng.");
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        Coupon coupon = (Coupon) session.getAttribute("appliedCoupon");
        if (coupon != null) {
            coupon = couponDAO.findByCode(coupon.getCode());
            if (coupon == null || !coupon.isValidNow()) coupon = null;
        }

        String method = req.getParameter("paymentMethod");
        boolean useBank = "BANK_TRANSFER".equalsIgnoreCase(method);

        if (!useBank && !stripeService.isConfigured()) {
            session.setAttribute("flashError", "Thanh toán thẻ trực tuyến hiện chưa sẵn sàng. Vui lòng chọn chuyển khoản ngân hàng hoặc thử lại sau.");
            resp.sendRedirect(req.getContextPath() + "/checkout");
            return;
        }

        String dbMethod = useBank ? "BANK_TRANSFER" : "STRIPE";

        try {
            Order order = orderDAO.createPendingOrder(user, items, coupon, dbMethod);

            if (useBank) {
                txDAO.log(order.getId(), "BANK_TRANSFER", order.getOrderCode(), order.getTotalAmount(),
                        "INITIATED", "Khởi tạo đơn chuyển khoản ngân hàng chờ xác nhận.");
                cartDAO.clearByUser(user.getId());
                cart.clear();
                session.removeAttribute("appliedCoupon");
                resp.sendRedirect(req.getContextPath() + "/payment/result?orderCode=" + order.getOrderCode());
                return;
            }

            // Real Stripe Checkout Session via official Stripe SDK — proxy-safe public base URL
            String baseUrl = resolvePublicBaseUrl(req);
            StripeService.CheckoutSessionResult res = stripeService.createCheckoutSession(order, baseUrl);
            if (res.ok()) {
                orderDAO.updateStripeSessionId(order.getId(), res.sessionId());
                txDAO.log(order.getId(), "STRIPE", res.sessionId(), order.getTotalAmount(),
                        "INITIATED", "Đã tạo phiên thanh toán Stripe Checkout.");
                resp.sendRedirect(res.checkoutUrl());
                return;
            }

            // Mark failed honestly when Stripe rejects session creation — never redirect to mock UI
            orderDAO.updateStatus(order.getId(), "FAILED");
            txDAO.log(order.getId(), "STRIPE", null, order.getTotalAmount(), "FAILED", res.errorMessage());
            session.setAttribute("flashError", res.errorMessage());
            resp.sendRedirect(req.getContextPath() + "/payment/result?orderCode=" + order.getOrderCode());
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("flashError", "Không thể khởi tạo đơn hàng lúc này. Vui lòng thử lại.");
            resp.sendRedirect(req.getContextPath() + "/checkout");
        }
    }

    private String resolvePublicBaseUrl(HttpServletRequest req) {
        String configured = AppConfig.getAppBaseUrl();
        if (configured != null && !configured.isBlank()) {
            return configured.endsWith("/") ? configured.substring(0, configured.length() - 1) : configured;
        }
        String proto = req.getHeader("X-Forwarded-Proto");
        if (proto == null || proto.isBlank()) {
            proto = req.getScheme();
        } else if (proto.contains(",")) {
            proto = proto.split(",")[0].trim();
        }
        String host = req.getHeader("X-Forwarded-Host");
        if (host != null && !host.isBlank()) {
            if (host.contains(",")) host = host.split(",")[0].trim();
            return proto + "://" + host + req.getContextPath();
        }
        int port = req.getServerPort();
        boolean defaultPort = ("http".equalsIgnoreCase(proto) && port == 80)
                || ("https".equalsIgnoreCase(proto) && port == 443);
        return proto + "://" + req.getServerName() + (defaultPort ? "" : ":" + port) + req.getContextPath();
    }
}
