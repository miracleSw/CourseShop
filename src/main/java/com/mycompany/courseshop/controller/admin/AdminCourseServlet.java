package com.mycompany.courseshop.controller.admin;

import com.mycompany.courseshop.config.AppConfig;
import com.mycompany.courseshop.dao.CategoryDAO;
import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.utils.FormatUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.time.Duration;
import java.util.Locale;

@WebServlet(name = "AdminCourseServlet", urlPatterns = {"/admin/courses"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 5 * 1024 * 1024, maxRequestSize = 10 * 1024 * 1024)
public class AdminCourseServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String editId = req.getParameter("edit");
        if (editId != null && !editId.isBlank()) {
            try {
                req.setAttribute("editCourse", courseDAO.findById(Integer.parseInt(editId)));
            } catch (NumberFormatException ignored) {}
        }
        req.setAttribute("courses", courseDAO.findAllForAdmin());
        req.setAttribute("categories", categoryDAO.findAllWithCounts());
        req.setAttribute("adminNav", "courses");
        req.setAttribute("pageTitle", "Quản lý Khóa học — Admin CourseShop");
        req.getRequestDispatcher("/views/admin/courses.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            try {
                courseDAO.deleteCourse(Integer.parseInt(req.getParameter("id")));
                req.getSession().setAttribute("flashSuccess", "Đã xóa khóa học thành công.");
            } catch (Exception e) {
                e.printStackTrace();
                req.getSession().setAttribute("flashError", "Không thể xóa khóa học đang có đơn hàng liên kết. Bạn hãy chuyển trạng thái sang Tạm ẩn.");
            }
            resp.sendRedirect(req.getContextPath() + "/admin/courses");
            return;
        }

        try {
            int id = parseInt(req.getParameter("id"), 0);
            Course existing = id > 0 ? courseDAO.findById(id) : null;

            Course c = new Course();
            c.setId(id);
            c.setCategoryId(parseInt(req.getParameter("categoryId"), 1));
            String title = req.getParameter("title") == null ? "" : req.getParameter("title").trim();
            String code = req.getParameter("code") == null ? "" : req.getParameter("code").trim().toUpperCase(Locale.ROOT);
            if (code.isBlank()) {
                code = "CS-" + (System.currentTimeMillis() % 10000);
            }
            c.setCode(code);
            c.setTitle(title);
            String slugInput = req.getParameter("slug");
            c.setSlug((slugInput == null || slugInput.isBlank()) ? FormatUtil.slugify(title) : FormatUtil.slugify(slugInput));
            c.setShortDesc(orEmpty(req.getParameter("shortDesc")));
            c.setDescription(orEmpty(req.getParameter("description")));
            c.setOutcomesRaw(orEmpty(req.getParameter("outcomes")));
            c.setInstructorName(orEmpty(req.getParameter("instructorName")));
            c.setPrice(parseDecimal(req.getParameter("price")));
            BigDecimal sale = parseDecimal(req.getParameter("salePrice"));
            c.setSalePrice(sale.compareTo(BigDecimal.ZERO) > 0 ? sale : null);
            c.setPro("1".equals(req.getParameter("isPro")) || c.getPrice().compareTo(BigDecimal.ZERO) > 0);
            if (!c.isPro()) {
                c.setPrice(BigDecimal.ZERO);
                c.setSalePrice(null);
            }
            String stripeProdId = req.getParameter("stripeProductId");
            c.setStripeProductId((stripeProdId == null || stripeProdId.isBlank()) ? null : stripeProdId.trim());
            c.setLevel(orDefault(req.getParameter("level"), "BEGINNER"));
            c.setFeaturedOrder(parseInt(req.getParameter("featuredOrder"), existing != null ? existing.getFeaturedOrder() : 100));
            c.setStatus(orDefault(req.getParameter("status"), "PUBLISHED"));

            String uploadedThumb = handleThumbnailUpload(req);
            if (uploadedThumb != null) {
                c.setThumbnail(uploadedThumb);
            } else {
                String thumbUrl = req.getParameter("thumbnail");
                if (thumbUrl != null && !thumbUrl.isBlank()) {
                    c.setThumbnail(thumbUrl.trim());
                } else if (existing != null) {
                    c.setThumbnail(existing.getThumbnail());
                } else {
                    c.setThumbnail(c.isPro() ? "assets/images/courses/pro-01.png" : "assets/images/courses/lab-01.png");
                }
            }

            if (id > 0) {
                courseDAO.updateCourse(c);
                req.getSession().setAttribute("flashSuccess", "Đã cập nhật khóa học \"" + c.getTitle() + "\".");
            } else {
                courseDAO.createCourse(c);
                req.getSession().setAttribute("flashSuccess", "Đã tạo khóa học mới \"" + c.getTitle() + "\".");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.getSession().setAttribute("flashError", "Không thể lưu khóa học. Vui lòng kiểm tra mã học phần không bị trùng.");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/courses");
    }

    private String handleThumbnailUpload(HttpServletRequest req) {
        try {
            Part filePart = req.getPart("thumbnailFile");
            if (filePart == null || filePart.getSize() <= 0) return null;
            String submitted = filePart.getSubmittedFileName();
            if (submitted == null || submitted.isBlank()) return null;
            String lower = submitted.toLowerCase(Locale.ROOT);
            String ext;
            String mimeType;
            if (lower.endsWith(".png")) { ext = ".png"; mimeType = "image/png"; }
            else if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) { ext = ".jpg"; mimeType = "image/jpeg"; }
            else if (lower.endsWith(".webp")) { ext = ".webp"; mimeType = "image/webp"; }
            else return null;

            String fileName = "course-" + System.currentTimeMillis() + ext;

            // Prefer persistent Supabase Storage when configured (ideal for ephemeral containers like Render)
            String supaUrl = AppConfig.getSupabaseUrl();
            String supaKey = AppConfig.getSupabaseKey();
            String supaBucket = AppConfig.getSupabaseBucket();
            if (supaUrl != null && !supaUrl.isBlank() && supaKey != null && !supaKey.isBlank()) {
                String cleanBase = supaUrl.endsWith("/") ? supaUrl.substring(0, supaUrl.length() - 1) : supaUrl;
                String objectPath = "courses/" + fileName;
                byte[] bytes = filePart.getInputStream().readAllBytes();
                HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(15)).build();
                HttpRequest uploadReq = HttpRequest.newBuilder()
                        .uri(URI.create(cleanBase + "/storage/v1/object/" + supaBucket + "/" + objectPath))
                        .timeout(Duration.ofSeconds(25))
                        .header("Authorization", "Bearer " + supaKey)
                        .header("apikey", supaKey)
                        .header("Content-Type", mimeType)
                        .header("x-upsert", "true")
                        .POST(HttpRequest.BodyPublishers.ofByteArray(bytes))
                        .build();
                HttpResponse<String> uploadResp = client.send(uploadReq, HttpResponse.BodyHandlers.ofString());
                if (uploadResp.statusCode() >= 200 && uploadResp.statusCode() < 300) {
                    return cleanBase + "/storage/v1/object/public/" + supaBucket + "/" + objectPath;
                }
            }

            // Local disk storage fallback (Tomcat webapp)
            String realDir = getServletContext().getRealPath("/assets/uploads");
            if (realDir != null) {
                Path targetDir = Path.of(realDir);
                Files.createDirectories(targetDir);
                try (InputStream in = filePart.getInputStream()) {
                    Files.copy(in, targetDir.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
                }
                return "assets/uploads/" + fileName;
            }
        } catch (Exception ignored) {}
        return null;
    }

    private int parseInt(String v, int def) {
        try { return Integer.parseInt(v); } catch (Exception e) { return def; }
    }

    private BigDecimal parseDecimal(String v) {
        if (v == null || v.isBlank()) return BigDecimal.ZERO;
        try { return new BigDecimal(v.replaceAll("[^0-9]", "")); } catch (Exception e) { return BigDecimal.ZERO; }
    }

    private String orEmpty(String v) { return v == null ? "" : v.trim(); }
    private String orDefault(String v, String def) { return (v == null || v.isBlank()) ? def : v.trim(); }
}
