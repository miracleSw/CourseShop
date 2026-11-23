package com.mycompany.courseshop.dao;

import com.mycompany.courseshop.model.Category;
import com.mycompany.courseshop.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    public List<Category> findAllWithCounts() {
        List<Category> list = new ArrayList<>();
        String sql = """
            SELECT c.id, c.name, c.slug, c.description,
                   COUNT(co.id) AS course_count
            FROM categories c
            LEFT JOIN courses co ON co.category_id = c.id AND co.status = 'PUBLISHED'
            GROUP BY c.id, c.name, c.slug, c.description
            ORDER BY c.id ASC
            """;
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setSlug(rs.getString("slug"));
                c.setDescription(rs.getString("description"));
                c.setCourseCount(rs.getInt("course_count"));
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Category findById(int id) {
        String sql = "SELECT * FROM categories WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Category c = new Category();
                    c.setId(rs.getInt("id"));
                    c.setName(rs.getString("name"));
                    c.setSlug(rs.getString("slug"));
                    c.setDescription(rs.getString("description"));
                    return c;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void create(String name, String slug, String description) throws SQLException {
        String sql = "INSERT INTO categories (name, slug, description) VALUES (?, ?, ?)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            ps.setString(2, slug.trim());
            ps.setString(3, description == null ? "" : description.trim());
            ps.executeUpdate();
        }
    }

    public void update(int id, String name, String slug, String description) throws SQLException {
        String sql = "UPDATE categories SET name = ?, slug = ?, description = ? WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            ps.setString(2, slug.trim());
            ps.setString(3, description == null ? "" : description.trim());
            ps.setInt(4, id);
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM categories WHERE id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}
