package com.mycompany.courseshop.controller.admin;

import com.mycompany.courseshop.dao.CategoryDAO;
import com.mycompany.courseshop.utils.FormatUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "AdminCategoryServlet", urlPatterns = {"/admin/categories"})
public class AdminCategoryServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String editId = req.getParameter("edit");
        if (editId != null && !editId.isBlank()) {
            try {
                req.setAttribute("editCategory", categoryDAO.findById(Integer.parseInt(editId)));
            } catch (NumberFormatException ignored) {}
        }
        req.setAttribute("categories", categoryDAO.findAllWithCounts());
        req.setAttribute("adminNav", "categories");
        req.setAttribute("pageTitle", "Quản lý Danh mục — Admin CourseShop");
        req.getRequestDispatcher("/views/admin/categories.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("delete".equalsIgnoreCase(action)) {
                categoryDAO.delete(Integer.parseInt(req.getParameter("id")));
                req.getSession().setAttribute("flashSuccess", "Đã xóa danh mục.");
            } else {
                int id = 0;
                try { id = Integer.parseInt(req.getParameter("id")); } catch (Exception ignored) {}
                String name = req.getParameter("name");
                String desc = req.getParameter("description");
                if (name == null || name.isBlank()) {
                    req.getSession().setAttribute("flashError", "Tên danh mục không được để trống.");
                } else {
                    String slug = FormatUtil.slugify(name);
                    if (id > 0) {
                        categoryDAO.update(id, name, slug, desc);
                        req.getSession().setAttribute("flashSuccess", "Đã cập nhật danh mục.");
                    } else {
                        categoryDAO.create(name, slug, desc);
                        req.getSession().setAttribute("flashSuccess", "Đã thêm danh mục \"" + name.trim() + "\".");
                    }
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("flashError", "Không thể thực hiện thao tác (danh mục đang có khóa học hoặc trùng tên).");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/categories");
    }
}
