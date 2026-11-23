package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.Quiz;
import com.mycompany.courseshop.model.QuizQuestion;
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

public class QuizDAO {

    public List<Quiz> findByCourseForUser(int courseId, Integer userId) {
        Map<Integer, Quiz> map = new LinkedHashMap<>();
        String sql = "SELECT * FROM quizzes WHERE course_id = ? ORDER BY COALESCE(section_id, 0) ASC, COALESCE(lesson_id, 0) ASC, id ASC";
        try (Connection con = DBContext.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Quiz q = mapQuiz(rs);
                        map.put(q.getId(), q);
                    }
                }
            }
            if (map.isEmpty()) return new ArrayList<>();

            String sqlQ = """
                SELECT qq.* FROM quiz_questions qq
                JOIN quizzes q ON q.id = qq.quiz_id
                WHERE q.course_id = ?
                ORDER BY qq.quiz_id ASC, qq.sort_order ASC, qq.id ASC
                """;
            try (PreparedStatement ps = con.prepareStatement(sqlQ)) {
                ps.setInt(1, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Quiz parent = map.get(rs.getInt("quiz_id"));
                        if (parent != null) {
                            parent.getQuestions().add(mapQuestion(rs));
                        }
                    }
                }
            }

            if (userId != null) {
                String sqlAtt = """
                    SELECT qa.quiz_id, MAX(qa.score_percent) AS best_score, MAX(qa.passed) AS is_passed
                    FROM quiz_attempts qa
                    JOIN quizzes q ON q.id = qa.quiz_id
                    WHERE qa.user_id = ? AND q.course_id = ?
                    GROUP BY qa.quiz_id
                    """;
                try (PreparedStatement ps = con.prepareStatement(sqlAtt)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, courseId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Quiz parent = map.get(rs.getInt("quiz_id"));
                            if (parent != null) {
                                parent.setBestScore(rs.getInt("best_score"));
                                parent.setPassed(rs.getBoolean("is_passed"));
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new ArrayList<>(map.values());
    }

    public Quiz findByIdWithQuestions(int quizId) {
        String sql = "SELECT * FROM quizzes WHERE id = ? LIMIT 1";
        try (Connection con = DBContext.getConnection()) {
            Quiz q = null;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, quizId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) q = mapQuiz(rs);
                }
            }
            if (q == null) return null;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT * FROM quiz_questions WHERE quiz_id = ? ORDER BY sort_order ASC, id ASC")) {
                ps.setInt(1, quizId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) q.getQuestions().add(mapQuestion(rs));
                }
            }
            return q;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void recordAttempt(int quizId, int userId, int scorePercent, int correctCount, int totalQuestions, boolean passed)
            throws SQLException {
        String sql = """
            INSERT INTO quiz_attempts (quiz_id, user_id, score_percent, correct_count, total_questions, passed)
            VALUES (?, ?, ?, ?, ?, ?)
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            ps.setInt(2, userId);
            ps.setInt(3, scorePercent);
            ps.setInt(4, correctCount);
            ps.setInt(5, totalQuestions);
            ps.setBoolean(6, passed);
            ps.executeUpdate();
        }
    }

    public int createQuiz(int courseId, Integer sectionId, Integer lessonId, String title, String description, int passScore)
            throws SQLException {
        String sql = "INSERT INTO quizzes (course_id, section_id, lesson_id, title, description, pass_score) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, courseId);
            if (sectionId != null && sectionId > 0) ps.setInt(2, sectionId); else ps.setNull(2, Types.INTEGER);
            if (lessonId != null && lessonId > 0) ps.setInt(3, lessonId); else ps.setNull(3, Types.INTEGER);
            ps.setString(4, title.trim());
            ps.setString(5, description == null ? "" : description.trim());
            ps.setInt(6, Math.max(10, Math.min(100, passScore)));
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return 0;
    }

    public void deleteQuiz(int quizId) throws SQLException {
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM quizzes WHERE id = ?")) {
            ps.setInt(1, quizId);
            ps.executeUpdate();
        }
    }

    public void addQuestion(QuizQuestion qq) throws SQLException {
        String sql = """
            INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, sort_order)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, qq.getQuizId());
            ps.setString(2, qq.getQuestionText().trim());
            ps.setString(3, qq.getOptionA().trim());
            ps.setString(4, qq.getOptionB().trim());
            ps.setString(5, qq.getOptionC().trim());
            ps.setString(6, qq.getOptionD().trim());
            ps.setString(7, qq.getCorrectOption().trim().toUpperCase());
            ps.setString(8, qq.getExplanation() == null ? "" : qq.getExplanation().trim());
            ps.setInt(9, qq.getSortOrder());
            ps.executeUpdate();
        }
    }

    public void deleteQuestion(int questionId) throws SQLException {
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM quiz_questions WHERE id = ?")) {
            ps.setInt(1, questionId);
            ps.executeUpdate();
        }
    }

    private Quiz mapQuiz(ResultSet rs) throws SQLException {
        Quiz q = new Quiz();
        q.setId(rs.getInt("id"));
        q.setCourseId(rs.getInt("course_id"));
        int sid = rs.getInt("section_id");
        q.setSectionId(rs.wasNull() ? null : sid);
        int lid = rs.getInt("lesson_id");
        q.setLessonId(rs.wasNull() ? null : lid);
        q.setTitle(rs.getString("title"));
        q.setDescription(rs.getString("description"));
        q.setPassScore(rs.getInt("pass_score"));
        return q;
    }

    private QuizQuestion mapQuestion(ResultSet rs) throws SQLException {
        QuizQuestion qq = new QuizQuestion();
        qq.setId(rs.getInt("id"));
        qq.setQuizId(rs.getInt("quiz_id"));
        qq.setQuestionText(rs.getString("question_text"));
        qq.setOptionA(rs.getString("option_a"));
        qq.setOptionB(rs.getString("option_b"));
        qq.setOptionC(rs.getString("option_c"));
        qq.setOptionD(rs.getString("option_d"));
        qq.setCorrectOption(rs.getString("correct_option"));
        qq.setExplanation(rs.getString("explanation"));
        qq.setSortOrder(rs.getInt("sort_order"));
        return qq;
    }
}
