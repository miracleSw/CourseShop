package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.Enrollment;
import com.mycompany.courseshop.model.LessonNote;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class EnrollmentDAO {

    public boolean isEnrolled(int userId, int courseId) {
        String sql = "SELECT 1 FROM enrollments WHERE user_id = ? AND course_id = ? LIMIT 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Set<Integer> getEnrolledCourseIds(int userId) {
        Set<Integer> ids = new HashSet<>();
        String sql = "SELECT course_id FROM enrollments WHERE user_id = ?";
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

    public void enrollFree(int userId, int courseId) throws SQLException {
        String sql = "INSERT IGNORE INTO enrollments (user_id, course_id, order_id, enrolled_at) VALUES (?, ?, NULL, NOW())";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            ps.executeUpdate();
        }
    }

    public List<Enrollment> findByUserWithProgress(int userId) {
        List<Enrollment> list = new ArrayList<>();
        String sql = """
            SELECT e.id AS enroll_id, e.user_id, e.course_id, e.order_id, e.enrolled_at,
                   co.*, cat.name AS category_name,
                   (SELECT COUNT(*) FROM lessons l WHERE l.course_id = co.id) AS lesson_count,
                   (SELECT COALESCE(SUM(l.duration_seconds), 0) FROM lessons l WHERE l.course_id = co.id) AS total_duration,
                   (SELECT COALESCE(AVG(r.rating), 0) FROM reviews r WHERE r.course_id = co.id) AS avg_rating,
                   (SELECT COUNT(*) FROM reviews r WHERE r.course_id = co.id) AS review_count,
                   (SELECT COUNT(*) FROM enrollments e2 WHERE e2.course_id = co.id) AS student_count,
                   (SELECT COUNT(*) FROM lesson_progress lp WHERE lp.user_id = e.user_id AND lp.course_id = co.id AND lp.is_completed = 1) AS completed_lessons
            FROM enrollments e
            JOIN courses co ON co.id = e.course_id
            LEFT JOIN categories cat ON cat.id = co.category_id
            WHERE e.user_id = ?
            ORDER BY e.enrolled_at DESC
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Enrollment en = new Enrollment();
                    en.setId(rs.getInt("enroll_id"));
                    en.setUserId(rs.getInt("user_id"));
                    en.setCourseId(rs.getInt("course_id"));
                    int oid = rs.getInt("order_id");
                    en.setOrderId(rs.wasNull() ? null : oid);
                    en.setEnrolledAt(rs.getTimestamp("enrolled_at"));
                    Course c = CourseDAO.mapSummaryRow(rs);
                    en.setCourse(c);
                    en.setTotalLessons(c.getLessonCount());
                    en.setCompletedLessons(rs.getInt("completed_lessons"));
                    list.add(en);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int[] setLessonCompleted(int userId, int courseId, int lessonId, boolean completed) throws SQLException {
        String sql = """
            INSERT INTO lesson_progress (user_id, lesson_id, course_id, is_completed, completed_at)
            VALUES (?, ?, ?, ?, NOW())
            ON DUPLICATE KEY UPDATE is_completed = VALUES(is_completed), completed_at = NOW()
            """;
        try (Connection con = DBContext.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, lessonId);
                ps.setInt(3, courseId);
                ps.setBoolean(4, completed);
                ps.executeUpdate();
            }
            int done = 0, total = 0;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM lesson_progress WHERE user_id = ? AND course_id = ? AND is_completed = 1")) {
                ps.setInt(1, userId);
                ps.setInt(2, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) done = rs.getInt(1);
                }
            }
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM lessons WHERE course_id = ?")) {
                ps.setInt(1, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) total = rs.getInt(1);
                }
            }
            return new int[]{done, total};
        }
    }

    public List<LessonNote> findNotes(int userId, int courseId, Integer lessonId) {
        List<LessonNote> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT n.*, l.title AS lesson_title
            FROM lesson_notes n
            JOIN lessons l ON l.id = n.lesson_id
            WHERE n.user_id = ? AND n.course_id = ?
            """);
        if (lessonId != null && lessonId > 0) {
            sql.append(" AND n.lesson_id = ? ");
        }
        sql.append(" ORDER BY n.timestamp_seconds ASC, n.created_at DESC ");
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            ps.setInt(1, userId);
            ps.setInt(2, courseId);
            if (lessonId != null && lessonId > 0) ps.setInt(3, lessonId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LessonNote n = new LessonNote();
                    n.setId(rs.getInt("id"));
                    n.setUserId(rs.getInt("user_id"));
                    n.setLessonId(rs.getInt("lesson_id"));
                    n.setCourseId(rs.getInt("course_id"));
                    n.setLessonTitle(rs.getString("lesson_title"));
                    n.setTimestampSeconds(rs.getInt("timestamp_seconds"));
                    n.setNoteText(rs.getString("note_text"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    n.setUpdatedAt(rs.getTimestamp("updated_at"));
                    list.add(n);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public LessonNote addNote(int userId, int courseId, int lessonId, int timestampSeconds, String noteText) throws SQLException {
        String sql = "INSERT INTO lesson_notes (user_id, lesson_id, course_id, timestamp_seconds, note_text) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setInt(2, lessonId);
            ps.setInt(3, courseId);
            ps.setInt(4, Math.max(0, timestampSeconds));
            ps.setString(5, noteText.trim());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    LessonNote n = new LessonNote();
                    n.setId(keys.getInt(1));
                    n.setUserId(userId);
                    n.setCourseId(courseId);
                    n.setLessonId(lessonId);
                    n.setTimestampSeconds(Math.max(0, timestampSeconds));
                    n.setNoteText(noteText.trim());
                    return n;
                }
            }
        }
        return null;
    }

    public boolean deleteNote(int noteId, int userId) throws SQLException {
        String sql = "DELETE FROM lesson_notes WHERE id = ? AND user_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, noteId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }
}
