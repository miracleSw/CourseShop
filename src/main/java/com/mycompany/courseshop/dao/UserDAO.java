package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.User;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setAvatar(rs.getString("avatar"));
        u.setRole(rs.getString("role"));
        u.setStatus(rs.getBoolean("status"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }

    public User findByEmailOrPhone(String emailOrPhone) {
        if (emailOrPhone == null || emailOrPhone.isBlank()) return null;
        String sql = "SELECT * FROM users WHERE email = ? OR phone = ? LIMIT 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            String v = emailOrPhone.trim();
            ps.setString(1, v);
            ps.setString(2, v);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public User findByEmail(String email) {
        if (email == null || email.isBlank()) return null;
        String sql = "SELECT * FROM users WHERE email = ? LIMIT 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public User findById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public User create(String fullName, String email, String phone, String passwordHash, String role) throws SQLException {
        String sql = "INSERT INTO users (full_name, email, phone, password_hash, role, status) VALUES (?, ?, ?, ?, ?, 1)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, fullName.trim());
            ps.setString(2, email.trim().toLowerCase());
            ps.setString(3, phone == null ? "" : phone.trim());
            ps.setString(4, passwordHash);
            ps.setString(5, role == null ? "USER" : role);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return findById(keys.getInt(1));
                }
            }
        }
        return null;
    }

    public List<User> findAll() {
        return searchAll(null);
    }

    public List<User> searchAll(String q) {
        List<User> list = new ArrayList<>();
        boolean hasQ = q != null && !q.isBlank();
        String sql = hasQ
                ? "SELECT * FROM users WHERE full_name LIKE ? OR email LIKE ? OR phone LIKE ? ORDER BY created_at DESC"
                : "SELECT * FROM users ORDER BY created_at DESC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (hasQ) {
                String like = "%" + q.trim() + "%";
                ps.setString(1, like);
                ps.setString(2, like);
                ps.setString(3, like);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void updateProfile(int userId, String fullName, String phone) throws SQLException {
        String sql = "UPDATE users SET full_name = ?, phone = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fullName.trim());
            ps.setString(2, phone == null ? "" : phone.trim());
            ps.setInt(3, userId);
            ps.executeUpdate();
        }
    }

    public void updatePassword(int userId, String passwordHash) throws SQLException {
        String sql = "UPDATE users SET password_hash = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, passwordHash);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    public void updateStatus(int userId, boolean active) throws SQLException {
        String sql = "UPDATE users SET status = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    public void updateRole(int userId, String role) throws SQLException {
        String sql = "UPDATE users SET role = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }
}
