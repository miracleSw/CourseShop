package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.LessonExercise;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class PracticeDAO {

    public LessonExercise findByLessonForUser(int lessonId, Integer userId) {
        String sql = "SELECT * FROM lesson_exercises WHERE lesson_id = ? LIMIT 1";
        try (Connection con = DBContext.getConnection()) {
            LessonExercise ex = null;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, lessonId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) ex = mapRow(rs);
                }
            }
            if (ex == null) return null;

            if (userId != null) {
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT submitted_code, passed, feedback FROM lesson_exercise_submissions WHERE user_id = ? AND exercise_id = ? LIMIT 1")) {
                    ps.setInt(1, userId);
                    ps.setInt(2, ex.getId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            ex.setLastSubmittedCode(rs.getString("submitted_code"));
                            ex.setPassed(rs.getBoolean("passed"));
                            ex.setLastFeedback(rs.getString("feedback"));
                        }
                    }
                }
            }
            return ex;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Map<Integer, LessonExercise> findMapByCourse(int courseId) {
        Map<Integer, LessonExercise> map = new HashMap<>();
        String sql = "SELECT * FROM lesson_exercises WHERE course_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LessonExercise ex = mapRow(rs);
                    map.put(ex.getLessonId(), ex);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    public LessonExercise findById(int exerciseId) {
        String sql = "SELECT * FROM lesson_exercises WHERE id = ? LIMIT 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, exerciseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void saveSubmission(int exerciseId, int userId, String code, boolean passed, String feedback) throws SQLException {
        String sql = """
            INSERT INTO lesson_exercise_submissions (exercise_id, user_id, submitted_code, passed, feedback)
            VALUES (?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE submitted_code = VALUES(submitted_code), passed = VALUES(passed), feedback = VALUES(feedback), updated_at = NOW()
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, exerciseId);
            ps.setInt(2, userId);
            ps.setString(3, code);
            ps.setBoolean(4, passed);
            ps.setString(5, feedback == null ? "" : feedback);
            ps.executeUpdate();
        }
    }

    public void upsertExercise(LessonExercise ex) throws SQLException {
        String sql = """
            INSERT INTO lesson_exercises (lesson_id, course_id, title, prompt_text, language, starter_code, expected_tokens, hint_text, solution_code)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
              title = VALUES(title), prompt_text = VALUES(prompt_text), language = VALUES(language),
              starter_code = VALUES(starter_code), expected_tokens = VALUES(expected_tokens),
              hint_text = VALUES(hint_text), solution_code = VALUES(solution_code)
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, ex.getLessonId());
            ps.setInt(2, ex.getCourseId());
            ps.setString(3, ex.getTitle().trim());
            ps.setString(4, ex.getPromptText().trim());
            ps.setString(5, ex.getLanguage() == null ? "html" : ex.getLanguage().trim().toLowerCase());
            ps.setString(6, ex.getStarterCode() == null ? "" : ex.getStarterCode());
            ps.setString(7, ex.getExpectedTokens() == null ? "" : ex.getExpectedTokens().trim());
            ps.setString(8, ex.getHintText() == null ? "" : ex.getHintText().trim());
            ps.setString(9, ex.getSolutionCode() == null ? "" : ex.getSolutionCode());
            ps.executeUpdate();
        }
    }

    public void deleteExerciseByLesson(int lessonId) throws SQLException {
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM lesson_exercises WHERE lesson_id = ?")) {
            ps.setInt(1, lessonId);
            ps.executeUpdate();
        }
    }

    private LessonExercise mapRow(ResultSet rs) throws SQLException {
        LessonExercise ex = new LessonExercise();
        ex.setId(rs.getInt("id"));
        ex.setLessonId(rs.getInt("lesson_id"));
        ex.setCourseId(rs.getInt("course_id"));
        ex.setTitle(rs.getString("title"));
        ex.setPromptText(rs.getString("prompt_text"));
        ex.setLanguage(rs.getString("language"));
        ex.setStarterCode(rs.getString("starter_code"));
        ex.setExpectedTokens(rs.getString("expected_tokens"));
        ex.setHintText(rs.getString("hint_text"));
        ex.setSolutionCode(rs.getString("solution_code"));
        return ex;
    }
}
