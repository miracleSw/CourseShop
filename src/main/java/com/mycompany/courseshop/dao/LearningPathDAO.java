package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.LearningPath;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class LearningPathDAO {

    public List<LearningPath> findAllSummary() {
        List<LearningPath> list = new ArrayList<>();
        String sql = "SELECT id, title, slug, sort_order FROM learning_paths ORDER BY sort_order ASC, id ASC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LearningPath lp = new LearningPath();
                lp.setId(rs.getInt("id"));
                lp.setCode(String.format("%02d", rs.getInt("sort_order")));
                lp.setTitle(rs.getString("title"));
                lp.setSlug(rs.getString("slug"));
                lp.setSortOrder(rs.getInt("sort_order"));
                list.add(lp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<LearningPath> findAllWithCourses() {
        Map<Integer, LearningPath> map = new LinkedHashMap<>();
        String sqlPaths = "SELECT * FROM learning_paths ORDER BY sort_order ASC, id ASC";
        try (Connection con = DBContext.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(sqlPaths);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LearningPath lp = new LearningPath();
                    lp.setId(rs.getInt("id"));
                    lp.setCode(String.format("%02d", rs.getInt("sort_order")));
                    lp.setTitle(rs.getString("title"));
                    lp.setSlug(rs.getString("slug"));
                    lp.setSummary(rs.getString("summary"));
                    lp.setTargetRole(rs.getString("target_role"));
                    lp.setIcon(rs.getString("icon"));
                    lp.setSortOrder(rs.getInt("sort_order"));
                    map.put(lp.getId(), lp);
                }
            }

            if (map.isEmpty()) return new ArrayList<>();

            String sqlCourses = """
                SELECT lpc.path_id, co.*, cat.name AS category_name,
                       (SELECT COUNT(*) FROM lessons l WHERE l.course_id = co.id) AS lesson_count,
                       (SELECT COALESCE(SUM(l.duration_seconds), 0) FROM lessons l WHERE l.course_id = co.id) AS total_duration,
                       (SELECT COALESCE(AVG(r.rating), 0) FROM reviews r WHERE r.course_id = co.id) AS avg_rating,
                       (SELECT COUNT(*) FROM reviews r WHERE r.course_id = co.id) AS review_count,
                       (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = co.id) AS student_count
                FROM learning_path_courses lpc
                JOIN courses co ON co.id = lpc.course_id
                LEFT JOIN categories cat ON cat.id = co.category_id
                WHERE co.status = 'PUBLISHED'
                ORDER BY lpc.path_id ASC, lpc.step_order ASC
                """;
            try (PreparedStatement ps = con.prepareStatement(sqlCourses);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LearningPath lp = map.get(rs.getInt("path_id"));
                    if (lp != null) {
                        lp.getCourses().add(CourseDAO.mapSummaryRow(rs));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new ArrayList<>(map.values());
    }
}
