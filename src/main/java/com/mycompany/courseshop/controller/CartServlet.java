package com.mycompany.courseshop.controller;

import com.mycompany.courseshop.dao.CartDAO;
import com.mycompany.courseshop.dao.CouponDAO;
import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.model.Coupon;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.User;
import com.mycompany.courseshop.utils.FormatUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final CouponDAO couponDAO = new CouponDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    private final CartDAO cartDAO = new CartDAO();

    @SuppressWarnings("unchecked")
    public static Map<Integer, Course> getOrCreateCart(HttpSession session) {
        Map<Integer, Course> cart = (Map<Integer, Course>) session.getAttribute("cart");
        if (cart == null) {
            cart = new LinkedHashMap<>();
            session.setAttribute("cart", cart);
        }
        return cart;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        User user = (User) session.getAttribute("user");
        Map<Integer, Course> cart;

        if (user != null) {
            cartDAO.removeOwnedItems(user.getId());
            cart = cartDAO.findCoursesByUser(user.getId());
            session.setAttribute("cart", cart);
        } else {
            cart = getOrCreateCart(session);
        }

        List<Course> items = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        for (Integer cid : new ArrayList<>(cart.keySet())) {
            Course fresh = (user != null) ? cart.get(cid) : courseDAO.findById(cid);
            if (fresh != null && !fresh.isFree() && "PUBLISHED".equals(fresh.getStatus())) {
                cart.put(cid, fresh);
                items.add(fresh);
                subtotal = subtotal.add(fresh.getEffectivePrice());
            } else {
                cart.remove(cid);
            }
        }

        Coupon appliedCoupon = (Coupon) session.getAttribute("appliedCoupon");
        BigDecimal discount = BigDecimal.ZERO;
        if (appliedCoupon != null) {
            Coupon freshCoupon = couponDAO.findByCode(appliedCoupon.getCode());
            if (freshCoupon != null && freshCoupon.isValidNow() && !items.isEmpty()) {
                session.setAttribute("appliedCoupon", freshCoupon);
                appliedCoupon = freshCoupon;
                discount = freshCoupon.calculateDiscount(subtotal);
            } else {
                session.removeAttribute("appliedCoupon");
                appliedCoupon = null;
            }
        }
        BigDecimal total = subtotal.subtract(discount).max(BigDecimal.ZERO);

        req.setAttribute("cartItems", items);
        req.setAttribute("subtotal", subtotal);
        req.setAttribute("discount", discount);
        req.setAttribute("total", total);
        req.setAttribute("formattedSubtotal", FormatUtil.formatVndAlways(subtotal));
        req.setAttribute("formattedDiscount", FormatUtil.formatVndAlways(discount));
        req.setAttribute("formattedTotal", FormatUtil.formatVndAlways(total));
        req.setAttribute("appliedCoupon", appliedCoupon);
        req.setAttribute("activeCoupons", couponDAO.findAllActive());
        req.setAttribute("globalCartCount", items.size());
        req.setAttribute("pageTitle", "Giỏ hàng — CourseShop");
        req.setAttribute("activeNav", "cart");

        req.getRequestDispatcher("/views/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        User user = (User) session.getAttribute("user");
        Map<Integer, Course> cart = (user != null)
                ? cartDAO.findCoursesByUser(user.getId())
                : getOrCreateCart(session);
        session.setAttribute("cart", cart);

        String action = req.getParameter("action");
        if (action == null) action = "add";
        boolean isAjax = "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));

        switch (action) {
            case "add" -> {
                int courseId = parseInt(req.getParameter("courseId"));
                Course course = courseDAO.findById(courseId);
                if (course == null || !"PUBLISHED".equals(course.getStatus())) {
                    respondMsg(req, resp, isAjax, false, "Không tìm thấy khóa học.", cart.size(), "/home");
                    return;
                }
                if (course.isFree()) {
                    respondMsg(req, resp, isAjax, false, "Khóa học này miễn phí — bạn có thể đăng ký học ngay!", cart.size(), "/course?slug=" + course.getSlug());
                    return;
                }
                if (user != null && enrollmentDAO.isEnrolled(user.getId(), courseId)) {
                    respondMsg(req, resp, isAjax, false, "Bạn đã sở hữu khóa học này rồi.", cart.size(), "/learn?courseId=" + courseId);
                    return;
                }
                if (cart.containsKey(courseId)) {
                    if ("1".equals(req.getParameter("buyNow"))) {
                        resp.sendRedirect(req.getContextPath() + "/checkout");
                        return;
                    }
                    respondMsg(req, resp, isAjax, true, "Khóa học đã có sẵn trong giỏ hàng.", cart.size(), "/cart");
                    return;
                }
                if (user != null) {
                    cartDAO.addItem(user.getId(), courseId);
                }
                cart.put(courseId, course);
                if ("1".equals(req.getParameter("buyNow"))) {
                    resp.sendRedirect(req.getContextPath() + "/checkout");
                    return;
                }
                String back = req.getParameter("redirect");
                String target = (back != null && back.startsWith("/")) ? back : "/cart";
                respondMsg(req, resp, isAjax, true, "Đã thêm \"" + course.getTitle() + "\" vào giỏ hàng.", cart.size(), target);
            }
            case "remove" -> {
                int courseId = parseInt(req.getParameter("courseId"));
                if (user != null) {
                    cartDAO.removeItem(user.getId(), courseId);
                }
                cart.remove(courseId);
                if (cart.isEmpty()) session.removeAttribute("appliedCoupon");
                respondMsg(req, resp, isAjax, true, "Đã xóa khóa học khỏi giỏ hàng.", cart.size(), "/cart");
            }
            case "applyCoupon" -> {
                String code = req.getParameter("couponCode");
                Coupon coupon = couponDAO.findByCode(code);
                if (coupon == null || !coupon.isValidNow()) {
                    session.setAttribute("flashError", "Mã giảm giá không hợp lệ hoặc đã hết hạn.");
                } else {
                    session.setAttribute("appliedCoupon", coupon);
                    session.setAttribute("flashSuccess", "Đã áp dụng mã " + coupon.getCode() + " (giảm " + coupon.getDiscountPercent() + "%).");
                }
                resp.sendRedirect(req.getContextPath() + "/cart");
            }
            case "removeCoupon" -> {
                session.removeAttribute("appliedCoupon");
                session.setAttribute("flashSuccess", "Đã gỡ mã giảm giá.");
                resp.sendRedirect(req.getContextPath() + "/cart");
            }
            case "clear" -> {
                if (user != null) {
                    cartDAO.clearByUser(user.getId());
                }
                cart.clear();
                session.removeAttribute("appliedCoupon");
                resp.sendRedirect(req.getContextPath() + "/cart");
            }
            default -> resp.sendRedirect(req.getContextPath() + "/cart");
        }
    }

    private void respondMsg(HttpServletRequest req, HttpServletResponse resp, boolean isAjax,
                            boolean ok, String message, int cartCount, String redirectPath) throws IOException {
        if (isAjax) {
            resp.setContentType("application/json;charset=UTF-8");
            String safeMsg = message.replace("\\", "\\\\").replace("\"", "\\\"");
            resp.getWriter().write("{\"ok\":" + ok + ",\"message\":\"" + safeMsg + "\",\"cartCount\":" + cartCount + "}");
            return;
        }
        req.getSession().setAttribute(ok ? "flashSuccess" : "flashError", message);
        resp.sendRedirect(req.getContextPath() + redirectPath);
    }

    private int parseInt(String val) {
        try {
            return Integer.parseInt(val);
        } catch (Exception e) {
            return 0;
        }
    }
}
