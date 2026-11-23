package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.Coupon;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CouponDAO {

    private Coupon mapRow(ResultSet rs) throws SQLException {
        Coupon c = new Coupon();
        c.setId(rs.getInt("id"));
        c.setCode(rs.getString("code"));
        c.setDiscountPercent(rs.getInt("discount_percent"));
        c.setMaxDiscount(rs.getBigDecimal("max_discount"));
        c.setUsageLimit(rs.getInt("usage_limit"));
        c.setUsedCount(rs.getInt("used_count"));
        c.setExpiredAt(rs.getTimestamp("expired_at"));
        c.setStatus(rs.getBoolean("status"));
        c.setStripeCouponId(rs.getString("stripe_coupon_id"));
        return c;
    }

    public Coupon findByCode(String code) {
        if (code == null || code.isBlank()) return null;
        String sql = "SELECT * FROM coupons WHERE UPPER(code) = UPPER(?) LIMIT 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Coupon> findAllActive() {
        List<Coupon> list = new ArrayList<>();
        String sql = "SELECT * FROM coupons WHERE status = 1 AND (expired_at IS NULL OR expired_at > NOW()) AND used_count < usage_limit ORDER BY discount_percent DESC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Coupon> findAll() {
        List<Coupon> list = new ArrayList<>();
        String sql = "SELECT * FROM coupons ORDER BY id DESC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void create(Coupon c) throws SQLException {
        String sql = """
            INSERT INTO coupons (code, discount_percent, max_discount, usage_limit, expired_at, status, stripe_coupon_id)
            VALUES (?, ?, ?, ?, ?, 1, ?)
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, c.getCode().trim().toUpperCase());
            ps.setInt(2, c.getDiscountPercent());
            ps.setBigDecimal(3, c.getMaxDiscount());
            ps.setInt(4, c.getUsageLimit());
            ps.setTimestamp(5, c.getExpiredAt());
            String stripeId = c.getStripeCouponId();
            if (stripeId != null && !stripeId.isBlank()) {
                ps.setString(6, stripeId.trim());
            } else {
                ps.setNull(6, java.sql.Types.VARCHAR);
            }
            ps.executeUpdate();
        }
    }

    public void updateStripeCouponId(int id, String stripeCouponId) throws SQLException {
        String sql = "UPDATE coupons SET stripe_coupon_id = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (stripeCouponId != null && !stripeCouponId.isBlank()) {
                ps.setString(1, stripeCouponId.trim());
            } else {
                ps.setNull(1, java.sql.Types.VARCHAR);
            }
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    public void toggleStatus(int id) throws SQLException {
        String sql = "UPDATE coupons SET status = IF(status = 1, 0, 1) WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM coupons WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}
