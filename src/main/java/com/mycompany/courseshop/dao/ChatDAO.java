package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.service.GeminiChatService;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ChatDAO {

    public List<String> findQuickPrompts(String contextType) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT prompt_text FROM chat_quick_prompts WHERE context_type = ? AND is_active = 1 ORDER BY sort_order ASC, id ASC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, contextType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString("prompt_text"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<GeminiChatService.ChatTurn> findRecentHistory(Integer userId, String sessionKey, Integer courseId, int limit) {
        List<GeminiChatService.ChatTurn> turns = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT role, content FROM chat_messages WHERE ");
        if (userId != null) {
            sql.append("user_id = ? ");
        } else {
            sql.append("user_id IS NULL AND session_key = ? ");
        }
        if (courseId != null && courseId > 0) {
            sql.append("AND course_id = ? ");
        } else {
            sql.append("AND course_id IS NULL ");
        }
        sql.append("ORDER BY id DESC LIMIT ?");

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (userId != null) {
                ps.setInt(idx++, userId);
            } else {
                ps.setString(idx++, sessionKey);
            }
            if (courseId != null && courseId > 0) {
                ps.setInt(idx++, courseId);
            }
            ps.setInt(idx, Math.max(1, limit));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    turns.add(new GeminiChatService.ChatTurn(rs.getString("role"), rs.getString("content")));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        Collections.reverse(turns);
        return turns;
    }

    public void saveMessage(Integer userId, String sessionKey, Integer courseId, Integer lessonId,
                            String role, String content, String modelUsed) {
        String sql = """
            INSERT INTO chat_messages (user_id, session_key, course_id, lesson_id, role, content, model_used)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (userId != null) ps.setInt(1, userId); else ps.setNull(1, Types.INTEGER);
            ps.setString(2, sessionKey == null ? "" : sessionKey);
            if (courseId != null && courseId > 0) ps.setInt(3, courseId); else ps.setNull(3, Types.INTEGER);
            if (lessonId != null && lessonId > 0) ps.setInt(4, lessonId); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, role);
            ps.setString(6, content == null ? "" : content);
            ps.setString(7, modelUsed == null ? "" : modelUsed);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void clearHistory(Integer userId, String sessionKey, Integer courseId) {
        StringBuilder sql = new StringBuilder("DELETE FROM chat_messages WHERE ");
        if (userId != null) {
            sql.append("user_id = ? ");
        } else {
            sql.append("user_id IS NULL AND session_key = ? ");
        }
        if (courseId != null && courseId > 0) {
            sql.append("AND course_id = ? ");
        } else {
            sql.append("AND course_id IS NULL ");
        }
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (userId != null) {
                ps.setInt(idx++, userId);
            } else {
                ps.setString(idx++, sessionKey);
            }
            if (courseId != null && courseId > 0) {
                ps.setInt(idx, courseId);
            }
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
