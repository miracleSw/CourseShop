package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;

public class CartDAO {

    public Map<Integer, Course> findCoursesByUser(int userId) {
        Map<Integer, Course> cart = new LinkedHashMap<>();
        String sql = """
            SELECT co.*, cat.name AS category_name,
                   (SELECT COUNT(*) FROM lessons l WHERE l.course_id = co.id) AS lesson_count,
                   (SELECT COALESCE(SUM(l.duration_seconds), 0) FROM lessons l WHERE l.course_id = co.id) AS total_duration,
                   (SELECT COALESCE(AVG(r.rating), 0) FROM reviews r WHERE r.course_id = co.id) AS avg_rating,
                   (SELECT COUNT(*) FROM reviews r WHERE r.course_id = co.id) AS review_count,
                   (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = co.id) AS student_count
            FROM cart_items ci
            JOIN courses co ON co.id = ci.course_id
            LEFT JOIN categories cat ON cat.id = co.category_id
            WHERE ci.user_id = ?
              AND co.status = 'PUBLISHED'
              AND co.is_pro = 1
              AND NOT EXISTS (
                  SELECT 1 FROM enrollments en
                  WHERE en.user_id = ci.user_id AND en.course_id = ci.course_id
              )
            ORDER BY ci.added_at ASC, ci.id ASC
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Course c = CourseDAO.mapSummaryRow(rs);
                    cart.put(c.getId(), c);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cart;
    }

    public void addItem(int userId, int courseId) {
        String sql = "INSERT IGNORE INTO cart_items (user_id, course_id, added_at) VALUES (?, ?, NOW())";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void removeItem(int userId, int courseId) {
        String sql = "DELETE FROM cart_items WHERE user_id = ? AND course_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void removeOwnedItems(int userId) {
        String sql = """
            DELETE ci FROM cart_items ci
            JOIN enrollments e ON e.user_id = ci.user_id AND e.course_id = ci.course_id
            WHERE ci.user_id = ?
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void clearByUser(int userId) {
        String sql = "DELETE FROM cart_items WHERE user_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void mergeGuestCart(int userId, Collection<Integer> guestCourseIds) {
        if (guestCourseIds == null || guestCourseIds.isEmpty()) return;
        String sql = "INSERT IGNORE INTO cart_items (user_id, course_id, added_at) VALUES (?, ?, NOW())";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (Integer cid : guestCourseIds) {
                if (cid != null && cid > 0) {
                    ps.setInt(1, userId);
                    ps.setInt(2, cid);
                    ps.addBatch();
                }
            }
            ps.executeBatch();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        removeOwnedItems(userId);
    }

    public int countByUser(int userId) {
        String sql = """
            SELECT COUNT(*)
            FROM cart_items ci
            JOIN courses co ON co.id = ci.course_id
            WHERE ci.user_id = ?
              AND co.status = 'PUBLISHED'
              AND co.is_pro = 1
              AND NOT EXISTS (
                  SELECT 1 FROM enrollments en
                  WHERE en.user_id = ci.user_id AND en.course_id = ci.course_id
              )
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
