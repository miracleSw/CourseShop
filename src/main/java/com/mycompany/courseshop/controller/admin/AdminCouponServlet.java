package com.mycompany.courseshop.controller.admin;

import com.mycompany.courseshop.dao.CouponDAO;
import com.mycompany.courseshop.model.Coupon;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalTime;

@WebServlet(name = "AdminCouponServlet", urlPatterns = {"/admin/coupons"})
public class AdminCouponServlet extends HttpServlet {

    private final CouponDAO couponDAO = new CouponDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("coupons", couponDAO.findAll());
        req.setAttribute("adminNav", "coupons");
        req.setAttribute("pageTitle", "Quản lý Mã giảm giá — Admin CourseShop");
        req.getRequestDispatcher("/views/admin/coupons.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("toggle".equalsIgnoreCase(action)) {
                couponDAO.toggleStatus(Integer.parseInt(req.getParameter("id")));
                req.getSession().setAttribute("flashSuccess", "Đã cập nhật trạng thái mã giảm giá.");
            } else if ("updateStripeId".equalsIgnoreCase(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                String stripeId = req.getParameter("stripeCouponId");
                couponDAO.updateStripeCouponId(id, stripeId);
                req.getSession().setAttribute("flashSuccess", "Đã cập nhật Stripe Coupon / Promo ID.");
            } else if ("delete".equalsIgnoreCase(action)) {
                couponDAO.delete(Integer.parseInt(req.getParameter("id")));
                req.getSession().setAttribute("flashSuccess", "Đã xóa mã giảm giá.");
            } else {
                String code = req.getParameter("code");
                if (code == null || code.isBlank()) {
                    req.getSession().setAttribute("flashError", "Vui lòng nhập mã giảm giá.");
                } else {
                    Coupon c = new Coupon();
                    c.setCode(code.trim().toUpperCase());
                    c.setDiscountPercent(Math.max(1, Math.min(90, parseInt(req.getParameter("discountPercent"), 10))));
                    c.setMaxDiscount(parseDecimal(req.getParameter("maxDiscount"), 200000));
                    c.setUsageLimit(Math.max(1, parseInt(req.getParameter("usageLimit"), 100)));
                    String stripeId = req.getParameter("stripeCouponId");
                    c.setStripeCouponId((stripeId == null || stripeId.isBlank()) ? null : stripeId.trim());
                    String exp = req.getParameter("expiredAt");
                    if (exp != null && !exp.isBlank()) {
                        LocalDate d = LocalDate.parse(exp.trim());
                        c.setExpiredAt(Timestamp.valueOf(d.atTime(LocalTime.of(23, 59, 59))));
                    }
                    couponDAO.create(c);
                    req.getSession().setAttribute("flashSuccess", "Đã tạo mã giảm giá " + c.getCode() + ".");
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("flashError", "Lỗi lưu mã giảm giá (có thể trùng mã hoặc đang gắn đơn hàng): " + e.getMessage());
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", "Dữ liệu không hợp lệ: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/coupons");
    }

    private int parseInt(String raw, int def) {
        try { return Integer.parseInt(raw.trim()); } catch (Exception e) { return def; }
    }

    private BigDecimal parseDecimal(String raw, long def) {
        if (raw == null || raw.isBlank()) return BigDecimal.valueOf(def);
        try { return new BigDecimal(raw.replaceAll("[^0-9]", "")); } catch (Exception e) { return BigDecimal.valueOf(def); }
    }
}
