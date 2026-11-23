package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.config.AppConfig;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class SettingsDAO {

    public Map<String, String> findAll() {
        Map<String, String> map = new HashMap<>();
        String sql = "SELECT setting_key, setting_value FROM app_settings";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("setting_key"), rs.getString("setting_value"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    public String get(String key, String fallback) {
        String sql = "SELECT setting_value FROM app_settings WHERE setting_key = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String val = rs.getString(1);
                    if (val != null && !val.isBlank()) {
                        return val.trim();
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return fallback;
    }

    public void upsert(String key, String value) throws SQLException {
        String sql = """
            INSERT INTO app_settings (setting_key, setting_value, updated_at)
            VALUES (?, ?, NOW())
            ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), updated_at = NOW()
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, key);
            ps.setString(2, value == null ? "" : value.trim());
            ps.executeUpdate();
        }
    }

    /**
     * Secret resolution follows 12-Factor precedence:
     * 1) Environment Variable (STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET, GEMINI_API_KEY)
     * 2) config.properties (local untracked file)
     * 3) Database app_settings (Admin override when ENV is unset)
     */
    public String getStripeSecretKey() {
        String envOrProp = AppConfig.getStripeSecretKey();
        if (envOrProp != null && !envOrProp.isBlank()) return envOrProp;
        return get("stripe.secret_key", "");
    }

    public String getStripePublishableKey() {
        String envOrProp = AppConfig.getStripePublishableKey();
        if (envOrProp != null && !envOrProp.isBlank()) return envOrProp;
        return get("stripe.publishable_key", "");
    }

    public String getStripeWebhookSecret() {
        String envOrProp = AppConfig.getStripeWebhookSecret();
        if (envOrProp != null && !envOrProp.isBlank()) return envOrProp;
        return get("stripe.webhook_secret", "");
    }

    public String getGeminiApiKey() {
        String envOrProp = AppConfig.getGeminiApiKey();
        if (envOrProp != null && !envOrProp.isBlank()) return envOrProp;
        return get("gemini.api_key", "");
    }

    public String getGeminiModel() {
        String fromDb = get("gemini.model", "");
        if (fromDb != null && !fromDb.isBlank()) return fromDb;
        return AppConfig.getGeminiModel();
    }
}
