package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.LessonDiscussion;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class DiscussionDAO {

    public List<LessonDiscussion> findTreeByLesson(int lessonId) {
        Map<Integer, LessonDiscussion> roots = new LinkedHashMap<>();
        List<LessonDiscussion> orphanReplies = new ArrayList<>();
        String sql = """
            SELECT d.*, u.full_name AS user_name, u.role AS user_role
            FROM lesson_discussions d
            JOIN users u ON u.id = d.user_id
            WHERE d.lesson_id = ?
            ORDER BY d.created_at ASC, d.id ASC
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, lessonId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LessonDiscussion d = mapRow(rs);
                    if (d.getParentId() == null) {
                        roots.put(d.getId(), d);
                    } else {
                        LessonDiscussion parent = roots.get(d.getParentId());
                        if (parent != null) {
                            parent.getReplies().add(d);
                        } else {
                            orphanReplies.add(d);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        for (LessonDiscussion r : orphanReplies) {
            LessonDiscussion parent = roots.get(r.getParentId());
            if (parent != null) parent.getReplies().add(r);
        }
        // Newest top-level questions first
        List<LessonDiscussion> ordered = new ArrayList<>(roots.values());
        java.util.Collections.reverse(ordered);
        return ordered;
    }

    public LessonDiscussion create(int lessonId, int courseId, int userId, Integer parentId, String content) throws SQLException {
        String sql = "INSERT INTO lesson_discussions (lesson_id, course_id, user_id, parent_id, content) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, lessonId);
            ps.setInt(2, courseId);
            ps.setInt(3, userId);
            if (parentId != null && parentId > 0) ps.setInt(4, parentId); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, content.trim());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return findById(con, keys.getInt(1));
                }
            }
        }
        return null;
    }

    public boolean deleteIfAllowed(int discussionId, int userId, boolean isAdmin) throws SQLException {
        String sql = isAdmin
                ? "DELETE FROM lesson_discussions WHERE id = ?"
                : "DELETE FROM lesson_discussions WHERE id = ? AND user_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, discussionId);
            if (!isAdmin) ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    private LessonDiscussion findById(Connection con, int id) throws SQLException {
        String sql = """
            SELECT d.*, u.full_name AS user_name, u.role AS user_role
            FROM lesson_discussions d
            JOIN users u ON u.id = d.user_id
            WHERE d.id = ? LIMIT 1
            """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    private LessonDiscussion mapRow(ResultSet rs) throws SQLException {
        LessonDiscussion d = new LessonDiscussion();
        d.setId(rs.getInt("id"));
        d.setLessonId(rs.getInt("lesson_id"));
        d.setCourseId(rs.getInt("course_id"));
        d.setUserId(rs.getInt("user_id"));
        int pid = rs.getInt("parent_id");
        d.setParentId(rs.wasNull() ? null : pid);
        String name = rs.getString("user_name");
        d.setUserName(name);
        d.setUserInitials(computeInitials(name));
        d.setInstructor("ADMIN".equalsIgnoreCase(rs.getString("user_role")));
        d.setContent(rs.getString("content"));
        d.setCreatedAt(rs.getTimestamp("created_at"));
        return d;
    }

    private String computeInitials(String name) {
        if (name == null || name.isBlank()) return "HV";
        String[] parts = name.trim().split("\\s+");
        if (parts.length == 1) return parts[0].substring(0, Math.min(2, parts[0].length())).toUpperCase();
        return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase();
    }
}
