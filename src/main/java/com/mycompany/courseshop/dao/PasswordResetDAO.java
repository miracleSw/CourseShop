package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.utils.CsrfUtil;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

public class PasswordResetDAO {

    /**
     * Generates a fresh 32-byte URL-safe token, persists its SHA-256 hash (30 min TTL),
     * invalidates any previous unused tokens for the user, and returns the raw token for email delivery.
     */
    public String createToken(int userId) throws SQLException {
        String rawToken = CsrfUtil.randomUrlToken(32);
        String tokenHash = CsrfUtil.sha256Hex(rawToken);
        Timestamp expiresAt = Timestamp.from(Instant.now().plus(30, ChronoUnit.MINUTES));

        try (Connection con = DBContext.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM password_reset_tokens WHERE user_id = ? AND used_at IS NULL")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO password_reset_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)")) {
                ps.setInt(1, userId);
                ps.setString(2, tokenHash);
                ps.setTimestamp(3, expiresAt);
                ps.executeUpdate();
            }
        }
        return rawToken;
    }

    public Integer findValidUserIdByToken(String rawToken) {
        if (rawToken == null || rawToken.isBlank()) return null;
        String tokenHash = CsrfUtil.sha256Hex(rawToken.trim());
        String sql = "SELECT user_id FROM password_reset_tokens WHERE token_hash = ? AND used_at IS NULL AND expires_at > NOW() LIMIT 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("user_id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void markUsed(String rawToken) throws SQLException {
        if (rawToken == null || rawToken.isBlank()) return;
        String tokenHash = CsrfUtil.sha256Hex(rawToken.trim());
        String sql = "UPDATE password_reset_tokens SET used_at = NOW() WHERE token_hash = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            ps.executeUpdate();
        }
    }
}
