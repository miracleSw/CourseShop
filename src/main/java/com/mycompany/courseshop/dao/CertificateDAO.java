package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.Certificate;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Year;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class CertificateDAO {

    private Certificate mapRow(ResultSet rs) throws SQLException {
        Certificate c = new Certificate();
        c.setId(rs.getInt("id"));
        c.setCertificateCode(rs.getString("certificate_code"));
        c.setUserId(rs.getInt("user_id"));
        c.setCourseId(rs.getInt("course_id"));
        c.setUserName(rs.getString("user_name"));
        c.setCourseTitle(rs.getString("course_title"));
        c.setCourseCode(rs.getString("course_code"));
        c.setInstructorName(rs.getString("instructor_name"));
        c.setIssuedAt(rs.getTimestamp("issued_at"));
        return c;
    }

    public String issueIfNotExists(int userId, int courseId) throws SQLException {
        String existing = findCode(userId, courseId);
        if (existing != null) return existing;

        String code = "CS-" + Year.now().getValue() + "-"
                + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        String sql = "INSERT IGNORE INTO certificates (certificate_code, user_id, course_id) VALUES (?, ?, ?)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code);
            ps.setInt(2, userId);
            ps.setInt(3, courseId);
            ps.executeUpdate();
        }
        String verified = findCode(userId, courseId);
        return verified != null ? verified : code;
    }

    public String findCode(int userId, int courseId) {
        String sql = "SELECT certificate_code FROM certificates WHERE user_id = ? AND course_id = ? LIMIT 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Certificate findByCode(String code) {
        if (code == null || code.isBlank()) return null;
        String sql = """
            SELECT ct.*, u.full_name AS user_name, co.title AS course_title,
                   co.code AS course_code, co.instructor_name
            FROM certificates ct
            JOIN users u ON u.id = ct.user_id
            JOIN courses co ON co.id = ct.course_id
            WHERE ct.certificate_code = ?
            LIMIT 1
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Certificate> findByUser(int userId) {
        List<Certificate> list = new ArrayList<>();
        String sql = """
            SELECT ct.*, u.full_name AS user_name, co.title AS course_title,
                   co.code AS course_code, co.instructor_name
            FROM certificates ct
            JOIN users u ON u.id = ct.user_id
            JOIN courses co ON co.id = ct.course_id
            WHERE ct.user_id = ?
            ORDER BY ct.issued_at DESC
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<Integer, String> findCodeMapByUser(int userId) {
        Map<Integer, String> map = new HashMap<>();
        String sql = "SELECT course_id, certificate_code FROM certificates WHERE user_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) map.put(rs.getInt("course_id"), rs.getString("certificate_code"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }
}
