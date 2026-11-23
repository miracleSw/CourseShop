package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class WishlistDAO {

    public Set<Integer> getWishlistCourseIds(int userId) {
        Set<Integer> ids = new HashSet<>();
        String sql = "SELECT course_id FROM wishlists WHERE user_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt(1));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ids;
    }

    public List<Course> findCoursesByUser(int userId) {
        List<Course> list = new ArrayList<>();
        String sql = """
            SELECT co.*, cat.name AS category_name,
                   (SELECT COUNT(*) FROM lessons l WHERE l.course_id = co.id) AS lesson_count,
                   (SELECT COALESCE(SUM(l.duration_seconds), 0) FROM lessons l WHERE l.course_id = co.id) AS total_duration,
                   (SELECT COALESCE(AVG(r.rating), 0) FROM reviews r WHERE r.course_id = co.id) AS avg_rating,
                   (SELECT COUNT(*) FROM reviews r WHERE r.course_id = co.id) AS review_count,
                   (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = co.id) AS student_count
            FROM wishlists w
            JOIN courses co ON co.id = w.course_id
            LEFT JOIN categories cat ON cat.id = co.category_id
            WHERE w.user_id = ? AND co.status = 'PUBLISHED'
            ORDER BY w.created_at DESC
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(CourseDAO.mapSummaryRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Toggles course in user's wishlist. Returns true if added, false if removed.
     */
    public boolean toggle(int userId, int courseId) throws SQLException {
        try (Connection con = DBContext.getConnection()) {
            boolean exists;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT 1 FROM wishlists WHERE user_id = ? AND course_id = ? LIMIT 1")) {
                ps.setInt(1, userId);
                ps.setInt(2, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    exists = rs.next();
                }
            }
            if (exists) {
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM wishlists WHERE user_id = ? AND course_id = ?")) {
                    ps.setInt(1, userId);
                    ps.setInt(2, courseId);
                    ps.executeUpdate();
                }
                return false;
            } else {
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT IGNORE INTO wishlists (user_id, course_id) VALUES (?, ?)")) {
                    ps.setInt(1, userId);
                    ps.setInt(2, courseId);
                    ps.executeUpdate();
                }
                return true;
            }
        }
    }
}
