package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.utils.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class PaymentTransactionDAO {

    public void log(int orderId, String gateway, String transactionRef, BigDecimal amount, String status, String message) {
        String sql = """
            INSERT INTO payment_transactions (order_id, gateway, transaction_ref, amount, status, message)
            VALUES (?, ?, ?, ?, ?, ?)
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, gateway == null ? "" : gateway);
            ps.setString(3, transactionRef);
            ps.setBigDecimal(4, amount == null ? BigDecimal.ZERO : amount);
            ps.setString(5, status);
            String safeMsg = message == null ? "" : (message.length() > 390 ? message.substring(0, 390) : message);
            ps.setString(6, safeMsg);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
