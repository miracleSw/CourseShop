package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.Lesson;
import com.mycompany.courseshop.model.Section;
import com.mycompany.courseshop.utils.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class CourseDAO {

    private static final String BASE_SELECT = """
        SELECT co.*, cat.name AS category_name,
               (SELECT COUNT(*) FROM lessons l WHERE l.course_id = co.id) AS lesson_count,
               (SELECT COALESCE(SUM(l.duration_seconds), 0) FROM lessons l WHERE l.course_id = co.id) AS total_duration,
               (SELECT COALESCE(AVG(r.rating), 0) FROM reviews r WHERE r.course_id = co.id) AS avg_rating,
               (SELECT COUNT(*) FROM reviews r WHERE r.course_id = co.id) AS review_count,
               (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = co.id) AS student_count
        FROM courses co
        LEFT JOIN categories cat ON cat.id = co.category_id
        """;

    public static Course mapSummaryRow(ResultSet rs) throws SQLException {
        Course c = new Course();
        c.setId(rs.getInt("id"));
        c.setCategoryId(rs.getInt("category_id"));
        c.setCategoryName(rs.getString("category_name"));
        c.setCode(rs.getString("code"));
        c.setTitle(rs.getString("title"));
        c.setSlug(rs.getString("slug"));
        c.setShortDesc(rs.getString("short_desc"));
        c.setDescription(rs.getString("description"));
        c.setOutcomesRaw(rs.getString("outcomes_text"));
        c.setInstructorName(rs.getString("instructor_name"));
        c.setThumbnail(rs.getString("thumbnail"));
        c.setPrice(rs.getBigDecimal("price"));
        c.setSalePrice(rs.getBigDecimal("sale_price"));
        c.setPro(rs.getBoolean("is_pro"));
        c.setStripeProductId(rs.getString("stripe_product_id"));
        c.setLevel(rs.getString("level"));
        c.setFeaturedOrder(rs.getInt("featured_order"));
        c.setStatus(rs.getString("status"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setLessonCount(rs.getInt("lesson_count"));
        c.setTotalDurationSeconds(rs.getInt("total_duration"));
        c.setAvgRating(Math.round(rs.getDouble("avg_rating") * 10.0) / 10.0);
        c.setReviewCount(rs.getInt("review_count"));
        c.setStudentCount(rs.getInt("student_count"));
        return c;
    }

    public List<Course> search(String keyword, Integer categoryId, String level, String type,
                               String sort, int page, int pageSize) {
        List<Course> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT).append(" WHERE co.status = 'PUBLISHED' ");
        List<Object> params = new ArrayList<>();
        appendFilterClauses(sql, params, keyword, categoryId, level, type);

        String orderBy = switch (sort == null ? "" : sort) {
            case "price_asc" -> " ORDER BY COALESCE(NULLIF(co.sale_price, 0), co.price) ASC, co.id DESC ";
            case "price_desc" -> " ORDER BY COALESCE(NULLIF(co.sale_price, 0), co.price) DESC, co.id DESC ";
            case "popular" -> " ORDER BY student_count DESC, avg_rating DESC, co.id DESC ";
            default -> " ORDER BY co.featured_order ASC, co.id ASC ";
        };
        sql.append(orderBy).append(" LIMIT ? OFFSET ? ");
        params.add(pageSize);
        params.add(Math.max(0, (page - 1) * pageSize));

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapSummaryRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countSearch(String keyword, Integer categoryId, String level, String type) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM courses co WHERE co.status = 'PUBLISHED' ");
        List<Object> params = new ArrayList<>();
        appendFilterClauses(sql, params, keyword, categoryId, level, type);
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private void appendFilterClauses(StringBuilder sql, List<Object> params,
                                     String keyword, Integer categoryId, String level, String type) {
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (co.title LIKE ? OR co.short_desc LIKE ? OR co.instructor_name LIKE ? OR co.code LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND co.category_id = ? ");
            params.add(categoryId);
        }
        if (level != null && !level.isBlank()) {
            sql.append(" AND co.level = ? ");
            params.add(level.trim().toUpperCase());
        }
        if ("free".equalsIgnoreCase(type)) {
            sql.append(" AND co.is_pro = 0 ");
        } else if ("pro".equalsIgnoreCase(type)) {
            sql.append(" AND co.is_pro = 1 ");
        }
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof Integer val) ps.setInt(i + 1, val);
            else ps.setString(i + 1, String.valueOf(p));
        }
    }

    public Course findById(int id) {
        String sql = BASE_SELECT + " WHERE co.id = ? LIMIT 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapSummaryRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Course findBySlug(String slug) {
        if (slug == null || slug.isBlank()) return null;
        String sql = BASE_SELECT + " WHERE co.slug = ? LIMIT 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, slug.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapSummaryRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Course> findAllForAdmin() {
        return findAllForAdmin(null);
    }

    public List<Course> findAllForAdmin(String q) {
        List<Course> list = new ArrayList<>();
        boolean hasQ = q != null && !q.isBlank();
        String sql = hasQ
                ? BASE_SELECT + " WHERE co.code LIKE ? OR co.title LIKE ? OR co.instructor_name LIKE ? OR cat.name LIKE ? ORDER BY co.created_at DESC, co.id DESC"
                : BASE_SELECT + " ORDER BY co.created_at DESC, co.id DESC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (hasQ) {
                String like = "%" + q.trim() + "%";
                ps.setString(1, like);
                ps.setString(2, like);
                ps.setString(3, like);
                ps.setString(4, like);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapSummaryRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Course> findPublishedAll() {
        List<Course> list = new ArrayList<>();
        String sql = BASE_SELECT + " WHERE co.status = 'PUBLISHED' ORDER BY co.is_pro DESC, co.id ASC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapSummaryRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Section> findSectionsWithLessons(int courseId, Integer userId) {
        Map<Integer, Section> map = new LinkedHashMap<>();
        Set<Integer> completedIds = new HashSet<>();

        try (Connection con = DBContext.getConnection()) {
            if (userId != null) {
                String sqlProg = "SELECT lesson_id FROM lesson_progress WHERE user_id = ? AND course_id = ? AND is_completed = 1";
                try (PreparedStatement ps = con.prepareStatement(sqlProg)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, courseId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) completedIds.add(rs.getInt(1));
                    }
                }
            }

            String sqlSec = "SELECT * FROM sections WHERE course_id = ? ORDER BY sort_order ASC, id ASC";
            try (PreparedStatement ps = con.prepareStatement(sqlSec)) {
                ps.setInt(1, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Section s = new Section();
                        s.setId(rs.getInt("id"));
                        s.setCourseId(rs.getInt("course_id"));
                        s.setTitle(rs.getString("title"));
                        s.setSortOrder(rs.getInt("sort_order"));
                        map.put(s.getId(), s);
                    }
                }
            }

            String sqlLessons = "SELECT * FROM lessons WHERE course_id = ? ORDER BY sort_order ASC, id ASC";
            try (PreparedStatement ps = con.prepareStatement(sqlLessons)) {
                ps.setInt(1, courseId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Lesson l = new Lesson();
                        l.setId(rs.getInt("id"));
                        l.setSectionId(rs.getInt("section_id"));
                        l.setCourseId(rs.getInt("course_id"));
                        l.setTitle(rs.getString("title"));
                        l.setVideoUrl(rs.getString("video_url"));
                        l.setDurationSeconds(rs.getInt("duration_seconds"));
                        l.setContentText(rs.getString("content_text"));
                        l.setPreview(rs.getBoolean("is_preview"));
                        l.setSortOrder(rs.getInt("sort_order"));
                        l.setCompleted(completedIds.contains(l.getId()));
                        Section sec = map.get(l.getSectionId());
                        if (sec != null) sec.getLessons().add(l);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new ArrayList<>(map.values());
    }

    public Lesson findLessonById(int lessonId) {
        String sql = "SELECT * FROM lessons WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, lessonId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Lesson l = new Lesson();
                    l.setId(rs.getInt("id"));
                    l.setSectionId(rs.getInt("section_id"));
                    l.setCourseId(rs.getInt("course_id"));
                    l.setTitle(rs.getString("title"));
                    l.setVideoUrl(rs.getString("video_url"));
                    l.setDurationSeconds(rs.getInt("duration_seconds"));
                    l.setContentText(rs.getString("content_text"));
                    l.setPreview(rs.getBoolean("is_preview"));
                    l.setSortOrder(rs.getInt("sort_order"));
                    return l;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public int createCourse(Course c) throws SQLException {
        String sql = """
            INSERT INTO courses
            (category_id, code, title, slug, short_desc, description, outcomes_text,
             instructor_name, thumbnail, price, sale_price, is_pro, stripe_product_id, level, featured_order, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, c.getCategoryId());
            ps.setString(2, c.getCode());
            ps.setString(3, c.getTitle());
            ps.setString(4, c.getSlug());
            ps.setString(5, c.getShortDesc());
            ps.setString(6, c.getDescription());
            ps.setString(7, c.getOutcomesRaw());
            ps.setString(8, c.getInstructorName());
            ps.setString(9, c.getThumbnail());
            ps.setBigDecimal(10, c.getPrice() == null ? BigDecimal.ZERO : c.getPrice());
            if (c.getSalePrice() != null && c.getSalePrice().compareTo(BigDecimal.ZERO) > 0) {
                ps.setBigDecimal(11, c.getSalePrice());
            } else {
                ps.setNull(11, java.sql.Types.DECIMAL);
            }
            ps.setBoolean(12, c.isPro());
            if (c.getStripeProductId() != null && !c.getStripeProductId().isBlank()) {
                ps.setString(13, c.getStripeProductId().trim());
            } else {
                ps.setNull(13, java.sql.Types.VARCHAR);
            }
            ps.setString(14, c.getLevel());
            ps.setInt(15, c.getFeaturedOrder());
            ps.setString(16, c.getStatus());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return 0;
    }

    public void updateCourse(Course c) throws SQLException {
        String sql = """
            UPDATE courses
            SET category_id = ?, code = ?, title = ?, slug = ?, short_desc = ?,
                description = ?, outcomes_text = ?, instructor_name = ?, thumbnail = ?,
                price = ?, sale_price = ?, is_pro = ?, stripe_product_id = ?, level = ?, featured_order = ?, status = ?
            WHERE id = ?
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, c.getCategoryId());
            ps.setString(2, c.getCode());
            ps.setString(3, c.getTitle());
            ps.setString(4, c.getSlug());
            ps.setString(5, c.getShortDesc());
            ps.setString(6, c.getDescription());
            ps.setString(7, c.getOutcomesRaw());
            ps.setString(8, c.getInstructorName());
            ps.setString(9, c.getThumbnail());
            ps.setBigDecimal(10, c.getPrice() == null ? BigDecimal.ZERO : c.getPrice());
            if (c.getSalePrice() != null && c.getSalePrice().compareTo(BigDecimal.ZERO) > 0) {
                ps.setBigDecimal(11, c.getSalePrice());
            } else {
                ps.setNull(11, java.sql.Types.DECIMAL);
            }
            ps.setBoolean(12, c.isPro());
            if (c.getStripeProductId() != null && !c.getStripeProductId().isBlank()) {
                ps.setString(13, c.getStripeProductId().trim());
            } else {
                ps.setNull(13, java.sql.Types.VARCHAR);
            }
            ps.setString(14, c.getLevel());
            ps.setInt(15, c.getFeaturedOrder());
            ps.setString(16, c.getStatus());
            ps.setInt(17, c.getId());
            ps.executeUpdate();
        }
    }

    public void deleteCourse(int id) throws SQLException {
        String sql = "DELETE FROM courses WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    public void createSection(int courseId, String title, int sortOrder) throws SQLException {
        String sql = "INSERT INTO sections (course_id, title, sort_order) VALUES (?, ?, ?)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            ps.setString(2, title.trim());
            ps.setInt(3, sortOrder);
            ps.executeUpdate();
        }
    }

    public void updateSection(int sectionId, String title, int sortOrder) throws SQLException {
        String sql = "UPDATE sections SET title = ?, sort_order = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, title.trim());
            ps.setInt(2, sortOrder);
            ps.setInt(3, sectionId);
            ps.executeUpdate();
        }
    }

    public void deleteSection(int sectionId) throws SQLException {
        String sql = "DELETE FROM sections WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, sectionId);
            ps.executeUpdate();
        }
    }

    public void createLesson(Lesson l) throws SQLException {
        String sql = """
            INSERT INTO lessons (section_id, course_id, title, video_url, duration_seconds, content_text, is_preview, sort_order)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, l.getSectionId());
            ps.setInt(2, l.getCourseId());
            ps.setString(3, l.getTitle().trim());
            ps.setString(4, l.getVideoUrl() == null ? "" : l.getVideoUrl().trim());
            ps.setInt(5, Math.max(60, l.getDurationSeconds()));
            ps.setString(6, l.getContentText() == null ? "" : l.getContentText().trim());
            ps.setBoolean(7, l.isPreview());
            ps.setInt(8, l.getSortOrder());
            ps.executeUpdate();
        }
    }

    public void updateLesson(Lesson l) throws SQLException {
        String sql = """
            UPDATE lessons
            SET title = ?, video_url = ?, duration_seconds = ?, content_text = ?, is_preview = ?, sort_order = ?
            WHERE id = ?
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, l.getTitle().trim());
            ps.setString(2, l.getVideoUrl() == null ? "" : l.getVideoUrl().trim());
            ps.setInt(3, Math.max(60, l.getDurationSeconds()));
            ps.setString(4, l.getContentText() == null ? "" : l.getContentText().trim());
            ps.setBoolean(5, l.isPreview());
            ps.setInt(6, l.getSortOrder());
            ps.setInt(7, l.getId());
            ps.executeUpdate();
        }
    }

    public void deleteLesson(int lessonId) throws SQLException {
        String sql = "DELETE FROM lessons WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, lessonId);
            ps.executeUpdate();
        }
    }
}
