package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.Coupon;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.Order;
import com.mycompany.courseshop.model.OrderItem;
import com.mycompany.courseshop.model.User;
import com.mycompany.courseshop.utils.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;

public class OrderDAO {

    private Order mapOrder(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setId(rs.getInt("id"));
        o.setOrderCode(rs.getString("order_code"));
        o.setUserId(rs.getInt("user_id"));
        o.setUserName(rs.getString("user_name"));
        o.setUserEmail(rs.getString("user_email"));
        int cid = rs.getInt("coupon_id");
        o.setCouponId(rs.wasNull() ? null : cid);
        o.setCouponCode(rs.getString("coupon_code"));
        o.setStripeCouponId(rs.getString("stripe_coupon_id"));
        o.setSubtotal(rs.getBigDecimal("subtotal"));
        o.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        o.setTotalAmount(rs.getBigDecimal("total_amount"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setStripeSessionId(rs.getString("stripe_session_id"));
        o.setStatus(rs.getString("status"));
        o.setCreatedAt(rs.getTimestamp("created_at"));
        o.setPaidAt(rs.getTimestamp("paid_at"));
        return o;
    }

    public Order createPendingOrder(User user, List<Course> courses, Coupon coupon, String paymentMethod) throws SQLException {
        BigDecimal subtotal = BigDecimal.ZERO;
        for (Course c : courses) {
            subtotal = subtotal.add(c.getEffectivePrice());
        }
        BigDecimal discount = (coupon != null && coupon.isValidNow())
                ? coupon.calculateDiscount(subtotal) : BigDecimal.ZERO;
        BigDecimal total = subtotal.subtract(discount).max(BigDecimal.ZERO);

        String code = "CS" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyMMddHHmm"))
                + ThreadLocalRandom.current().nextInt(100, 999);

        try (Connection con = DBContext.getConnection()) {
            con.setAutoCommit(false);
            try {
                int orderId;
                String sqlOrder = """
                    INSERT INTO orders
                    (order_code, user_id, coupon_id, subtotal, discount_amount, total_amount, payment_method, status)
                    VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')
                    """;
                try (PreparedStatement ps = con.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, code);
                    ps.setInt(2, user.getId());
                    if (coupon != null && coupon.isValidNow() && discount.compareTo(BigDecimal.ZERO) > 0) {
                        ps.setInt(3, coupon.getId());
                    } else {
                        ps.setNull(3, Types.INTEGER);
                    }
                    ps.setBigDecimal(4, subtotal);
                    ps.setBigDecimal(5, discount);
                    ps.setBigDecimal(6, total);
                    ps.setString(7, paymentMethod);
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) throw new SQLException("Failed to obtain generated order ID");
                        orderId = keys.getInt(1);
                    }
                }

                String sqlItem = "INSERT INTO order_items (order_id, course_id, unit_price) VALUES (?, ?, ?)";
                try (PreparedStatement ps = con.prepareStatement(sqlItem)) {
                    for (Course c : courses) {
                        ps.setInt(1, orderId);
                        ps.setInt(2, c.getId());
                        ps.setBigDecimal(3, c.getEffectivePrice());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }

                con.commit();
                return findById(orderId);
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            }
        }
    }

    public void updateStripeSessionId(int orderId, String sessionId) throws SQLException {
        String sql = "UPDATE orders SET stripe_session_id = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, sessionId);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }
    }

    /**
     * Atomically marks an order PAID, grants course enrollments, and increments coupon usage.
     * Safe to invoke idempotently (no duplicate enrollments or double coupon increments).
     */
    public boolean markOrderPaidAndEnroll(int orderId) throws SQLException {
        try (Connection con = DBContext.getConnection()) {
            con.setAutoCommit(false);
            try {
                int userId;
                Integer couponId = null;
                String currentStatus;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT user_id, coupon_id, status FROM orders WHERE id = ? FOR UPDATE")) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            return false;
                        }
                        userId = rs.getInt("user_id");
                        int cid = rs.getInt("coupon_id");
                        if (!rs.wasNull()) couponId = cid;
                        currentStatus = rs.getString("status");
                    }
                }

                if ("PAID".equalsIgnoreCase(currentStatus)) {
                    con.commit();
                    return true;
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE orders SET status = 'PAID', paid_at = NOW() WHERE id = ?")) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                }

                String sqlEnroll = """
                    INSERT IGNORE INTO enrollments (user_id, course_id, order_id, enrolled_at)
                    SELECT ?, oi.course_id, ?, NOW()
                    FROM order_items oi
                    WHERE oi.order_id = ?
                    """;
                try (PreparedStatement ps = con.prepareStatement(sqlEnroll)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, orderId);
                    ps.setInt(3, orderId);
                    ps.executeUpdate();
                }

                if (couponId != null) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE coupons SET used_count = used_count + 1 WHERE id = ?")) {
                        ps.setInt(1, couponId);
                        ps.executeUpdate();
                    }
                }

                con.commit();
                return true;
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            }
        }
    }

    public void updateStatus(int orderId, String status) throws SQLException {
        String sql = "UPDATE orders SET status = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }
    }

    public void updateAmountsFromStripe(int orderId, BigDecimal discountAmount, BigDecimal totalAmount) throws SQLException {
        String sql = "UPDATE orders SET discount_amount = ?, total_amount = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBigDecimal(1, discountAmount == null ? BigDecimal.ZERO : discountAmount);
            ps.setBigDecimal(2, totalAmount == null ? BigDecimal.ZERO : totalAmount);
            ps.setInt(3, orderId);
            ps.executeUpdate();
        }
    }

    public Order findById(int orderId) {
        String sql = """
            SELECT o.*, u.full_name AS user_name, u.email AS user_email,
                   cp.code AS coupon_code, cp.stripe_coupon_id AS stripe_coupon_id
            FROM orders o
            JOIN users u ON u.id = o.user_id
            LEFT JOIN coupons cp ON cp.id = o.coupon_id
            WHERE o.id = ?
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order o = mapOrder(rs);
                    o.setItems(findItems(con, o.getId()));
                    return o;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Order findByOrderCode(String orderCode) {
        if (orderCode == null || orderCode.isBlank()) return null;
        String sql = """
            SELECT o.*, u.full_name AS user_name, u.email AS user_email,
                   cp.code AS coupon_code, cp.stripe_coupon_id AS stripe_coupon_id
            FROM orders o
            JOIN users u ON u.id = o.user_id
            LEFT JOIN coupons cp ON cp.id = o.coupon_id
            WHERE o.order_code = ?
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, orderCode.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order o = mapOrder(rs);
                    o.setItems(findItems(con, o.getId()));
                    return o;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Order findByStripeSessionId(String sessionId) {
        if (sessionId == null || sessionId.isBlank()) return null;
        String sql = """
            SELECT o.*, u.full_name AS user_name, u.email AS user_email,
                   cp.code AS coupon_code, cp.stripe_coupon_id AS stripe_coupon_id
            FROM orders o
            JOIN users u ON u.id = o.user_id
            LEFT JOIN coupons cp ON cp.id = o.coupon_id
            WHERE o.stripe_session_id = ?
            LIMIT 1
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, sessionId.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order o = mapOrder(rs);
                    o.setItems(findItems(con, o.getId()));
                    return o;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Order> findByUser(int userId) {
        List<Order> list = new ArrayList<>();
        String sql = """
            SELECT o.*, u.full_name AS user_name, u.email AS user_email,
                   cp.code AS coupon_code, cp.stripe_coupon_id AS stripe_coupon_id
            FROM orders o
            JOIN users u ON u.id = o.user_id
            LEFT JOIN coupons cp ON cp.id = o.coupon_id
            WHERE o.user_id = ?
            ORDER BY o.created_at DESC
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapOrder(rs);
                    o.setItems(findItems(con, o.getId()));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Order> findAll(String statusFilter) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT o.*, u.full_name AS user_name, u.email AS user_email,
                   cp.code AS coupon_code, cp.stripe_coupon_id AS stripe_coupon_id
            FROM orders o
            JOIN users u ON u.id = o.user_id
            LEFT JOIN coupons cp ON cp.id = o.coupon_id
            """);
        if (statusFilter != null && !statusFilter.isBlank()) {
            sql.append(" WHERE o.status = ? ");
        }
        sql.append(" ORDER BY o.created_at DESC ");
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            if (statusFilter != null && !statusFilter.isBlank()) {
                ps.setString(1, statusFilter.trim().toUpperCase());
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapOrder(rs);
                    o.setItems(findItems(con, o.getId()));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<OrderItem> findItems(Connection con, int orderId) throws SQLException {
        List<OrderItem> items = new ArrayList<>();
        String sql = """
            SELECT oi.*, co.title AS course_title, co.slug AS course_slug, co.code AS course_code,
                   co.thumbnail AS course_thumbnail, co.stripe_product_id AS course_stripe_product_id
            FROM order_items oi
            JOIN courses co ON co.id = oi.course_id
            WHERE oi.order_id = ?
            """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem it = new OrderItem();
                    it.setId(rs.getInt("id"));
                    it.setOrderId(rs.getInt("order_id"));
                    it.setCourseId(rs.getInt("course_id"));
                    it.setCourseTitle(rs.getString("course_title"));
                    it.setCourseSlug(rs.getString("course_slug"));
                    it.setCourseCode(rs.getString("course_code"));
                    it.setCourseThumbnail(rs.getString("course_thumbnail"));
                    it.setStripeProductId(rs.getString("course_stripe_product_id"));
                    it.setUnitPrice(rs.getBigDecimal("unit_price"));
                    items.add(it);
                }
            }
        }
        return items;
    }

    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("totalRevenue", BigDecimal.ZERO);
        stats.put("paidOrders", 0);
        stats.put("pendingOrders", 0);
        stats.put("totalUsers", 0);
        stats.put("totalCourses", 0);
        stats.put("totalEnrollments", 0);

        try (Connection con = DBContext.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COALESCE(SUM(total_amount),0), COUNT(*) FROM orders WHERE status = 'PAID'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalRevenue", rs.getBigDecimal(1));
                    stats.put("paidOrders", rs.getInt(2));
                }
            }
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM orders WHERE status = 'PENDING'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("pendingOrders", rs.getInt(1));
            }
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM users WHERE role = 'USER'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("totalUsers", rs.getInt(1));
            }
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM courses");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("totalCourses", rs.getInt(1));
            }
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM enrollments");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("totalEnrollments", rs.getInt(1));
            }

            // Revenue grouped by date (last 7 paid days)
            Map<String, Long> chartData = new LinkedHashMap<>();
            String sqlChart = """
                SELECT DATE_FORMAT(COALESCE(paid_at, created_at), '%d/%m') AS d,
                       COALESCE(SUM(total_amount), 0) AS rev
                FROM orders
                WHERE status = 'PAID'
                GROUP BY DATE(COALESCE(paid_at, created_at)), d
                ORDER BY DATE(COALESCE(paid_at, created_at)) ASC
                LIMIT 10
                """;
            try (PreparedStatement ps = con.prepareStatement(sqlChart);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    chartData.put(rs.getString("d"), rs.getLong("rev"));
                }
            }
            stats.put("revenueSeries", chartData);

            // Top courses by enrollments
            List<Map<String, Object>> topCourses = new ArrayList<>();
            String sqlTop = """
                SELECT co.id, co.code, co.title, co.is_pro,
                       COUNT(e.id) AS enroll_cnt,
                       COALESCE((SELECT SUM(oi.unit_price) FROM order_items oi JOIN orders o ON o.id = oi.order_id WHERE oi.course_id = co.id AND o.status = 'PAID'), 0) AS rev
                FROM courses co
                LEFT JOIN enrollments e ON e.course_id = co.id
                GROUP BY co.id, co.code, co.title, co.is_pro
                ORDER BY rev DESC, enroll_cnt DESC
                LIMIT 5
                """;
            try (PreparedStatement ps = con.prepareStatement(sqlTop);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("code", rs.getString("code"));
                    row.put("title", rs.getString("title"));
                    row.put("pro", rs.getBoolean("is_pro"));
                    row.put("enrollments", rs.getInt("enroll_cnt"));
                    row.put("revenue", rs.getBigDecimal("rev"));
                    topCourses.add(row);
                }
            }
            stats.put("topCourses", topCourses);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
}
