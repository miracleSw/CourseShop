package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.Review;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ReviewDAO {

    public List<Review> findByCourse(int courseId) {
        List<Review> list = new ArrayList<>();
        String sql = """
            SELECT r.*, u.full_name AS user_name
            FROM reviews r
            JOIN users u ON u.id = r.user_id
            WHERE r.course_id = ?
            ORDER BY r.created_at DESC
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setId(rs.getInt("id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setUserName(rs.getString("user_name"));
                    r.setCourseId(rs.getInt("course_id"));
                    r.setRating(rs.getInt("rating"));
                    r.setComment(rs.getString("comment"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<Integer, Integer> getRatingDistribution(int courseId) {
        Map<Integer, Integer> dist = new LinkedHashMap<>();
        for (int star = 5; star >= 1; star--) {
            dist.put(star, 0);
        }
        String sql = "SELECT rating, COUNT(*) AS cnt FROM reviews WHERE course_id = ? GROUP BY rating";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    dist.put(rs.getInt("rating"), rs.getInt("cnt"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return dist;
    }

    public void upsert(int userId, int courseId, int rating, String comment) throws SQLException {
        String sql = """
            INSERT INTO reviews (user_id, course_id, rating, comment, created_at)
            VALUES (?, ?, ?, ?, NOW())
            ON DUPLICATE KEY UPDATE rating = VALUES(rating), comment = VALUES(comment), created_at = NOW()
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            ps.setInt(3, Math.max(1, Math.min(5, rating)));
            ps.setString(4, comment == null ? "" : comment.trim());
            ps.executeUpdate();
        }
    }

    public List<Review> findAllForAdmin(Integer courseId, Integer rating, String q) {
        List<Review> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT r.*, u.full_name AS user_name, u.email AS user_email,
                   co.code AS course_code, co.title AS course_title
            FROM reviews r
            JOIN users u ON u.id = r.user_id
            JOIN courses co ON co.id = r.course_id
            WHERE 1=1
            """);
        List<Object> params = new ArrayList<>();
        if (courseId != null && courseId > 0) {
            sql.append(" AND r.course_id = ? ");
            params.add(courseId);
        }
        if (rating != null && rating >= 1 && rating <= 5) {
            sql.append(" AND r.rating = ? ");
            params.add(rating);
        }
        if (q != null && !q.isBlank()) {
            sql.append(" AND (u.full_name LIKE ? OR u.email LIKE ? OR co.title LIKE ? OR r.comment LIKE ?) ");
            String like = "%" + q.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }
        sql.append(" ORDER BY r.created_at DESC ");
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setId(rs.getInt("id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setUserName(rs.getString("user_name"));
                    r.setUserEmail(rs.getString("user_email"));
                    r.setCourseId(rs.getInt("course_id"));
                    r.setCourseCode(rs.getString("course_code"));
                    r.setCourseTitle(rs.getString("course_title"));
                    r.setRating(rs.getInt("rating"));
                    r.setComment(rs.getString("comment"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void delete(int reviewId) throws SQLException {
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM reviews WHERE id = ?")) {
            ps.setInt(1, reviewId);
            ps.executeUpdate();
        }
    }
}
