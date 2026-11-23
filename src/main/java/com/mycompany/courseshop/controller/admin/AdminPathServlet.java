package com.mycompany.courseshop.controller.admin;

import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.dao.LearningPathDAO;
import com.mycompany.courseshop.model.LearningPath;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AdminPathServlet", urlPatterns = {"/admin/paths"})
public class AdminPathServlet extends HttpServlet {

    private final LearningPathDAO pathDAO = new LearningPathDAO();
    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String editId = req.getParameter("edit");
        if (editId != null && !editId.isBlank()) {
            try {
                LearningPath editPath = pathDAO.findById(Integer.parseInt(editId));
                req.setAttribute("editPath", editPath);
            } catch (NumberFormatException ignored) {}
        }
        req.setAttribute("paths", pathDAO.findAllWithCourses());
        req.setAttribute("allCourses", courseDAO.findAllForAdmin());
        req.setAttribute("adminNav", "paths");
        req.setAttribute("pageTitle", "Quản lý Lộ trình học — Quản trị CourseShop");
        req.getRequestDispatcher("/views/admin/paths.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("delete".equalsIgnoreCase(action)) {
                pathDAO.deletePath(Integer.parseInt(req.getParameter("id")));
                req.getSession().setAttribute("flashSuccess", "Đã xóa lộ trình học.");
            } else {
                int id = parseInt(req.getParameter("id"), 0);
                String title = req.getParameter("title");
                String summary = req.getParameter("summary");
                String targetRole = req.getParameter("targetRole");
                int sortOrder = parseInt(req.getParameter("sortOrder"), 1);

                if (title == null || title.isBlank()) {
                    req.getSession().setAttribute("flashError", "Vui lòng nhập tên lộ trình.");
                } else {
                    int pathId = id;
                    if (id > 0) {
                        pathDAO.updatePath(id, title, summary, targetRole, sortOrder);
                    } else {
                        pathId = pathDAO.createPath(title, summary, targetRole, sortOrder);
                    }
                    String[] courseIdParams = req.getParameterValues("courseIds");
                    List<Integer> cids = new ArrayList<>();
                    if (courseIdParams != null) {
                        for (String raw : courseIdParams) {
                            int cid = parseInt(raw, 0);
                            if (cid > 0) cids.add(cid);
                        }
                    }
                    if (pathId > 0) {
                        pathDAO.replacePathCourses(pathId, cids);
                    }
                    req.getSession().setAttribute("flashSuccess", id > 0 ? "Đã cập nhật lộ trình học." : "Đã tạo lộ trình học mới.");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.getSession().setAttribute("flashError", "Không thể lưu lộ trình lúc này (có thể tên lộ trình bị trùng).");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/paths");
    }

    private int parseInt(String v, int def) {
        try { return Integer.parseInt(v.trim()); } catch (Exception e) { return def; }
    }
}
