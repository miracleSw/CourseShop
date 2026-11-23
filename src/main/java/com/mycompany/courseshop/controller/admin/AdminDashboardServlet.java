package com.mycompany.courseshop.controller.admin;

import com.google.gson.Gson;
import com.mycompany.courseshop.dao.OrderDAO;
import com.mycompany.courseshop.model.Order;
import com.mycompany.courseshop.model.OrderItem;
import com.mycompany.courseshop.utils.FormatUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin", "/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String fromDate = cleanDate(req.getParameter("from"));
        String toDate = cleanDate(req.getParameter("to"));

        if ("csv".equalsIgnoreCase(req.getParameter("export"))) {
            exportOrdersCsv(resp, fromDate, toDate);
            return;
        }

        Map<String, Object> stats = orderDAO.getDashboardStats(fromDate, toDate);
        @SuppressWarnings("unchecked")
        Map<String, Long> revSeries = (Map<String, Long>) stats.get("revenueSeries");

        req.setAttribute("stats", stats);
        req.setAttribute("fromDate", fromDate);
        req.setAttribute("toDate", toDate);
        req.setAttribute("formattedRevenue", FormatUtil.formatVndAlways((BigDecimal) stats.get("totalRevenue")));
        req.setAttribute("chartLabelsJson", gson.toJson(revSeries.keySet()));
        req.setAttribute("chartValuesJson", gson.toJson(revSeries.values()));
        req.setAttribute("recentOrders", orderDAO.findAllFiltered(null, null, fromDate, toDate).stream().limit(8).toList());
        req.setAttribute("adminNav", "dashboard");
        req.setAttribute("pageTitle", "Tổng quan Quản trị — CourseShop");
        req.getRequestDispatcher("/views/admin/dashboard.jsp").forward(req, resp);
    }

    private void exportOrdersCsv(HttpServletResponse resp, String fromDate, String toDate) throws IOException {
        List<Order> orders = orderDAO.findAllFiltered(null, null, fromDate, toDate);
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        String suffix = (fromDate.isEmpty() && toDate.isEmpty()) ? "all" : (fromDate + "_" + toDate);
        resp.setHeader("Content-Disposition", "attachment; filename=\"bao-cao-doanh-thu-" + suffix + ".csv\"");

        SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        PrintWriter out = resp.getWriter();
        // UTF-8 BOM so Microsoft Excel displays Vietnamese diacritics properly
        out.write('\uFEFF');
        out.println("Ma don hang,Hoc vien,Email,Khoa hoc,Phuong thuc,Tam tinh (VND),Giam gia (VND),Tong thanh toan (VND),Trang thai,Ngay tao,Ngay thanh toan");

        for (Order o : orders) {
            String courses = o.getItems() == null ? ""
                    : o.getItems().stream().map(OrderItem::getCourseCode).collect(Collectors.joining(" | "));
            out.printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s%n",
                    csv(o.getOrderCode()),
                    csv(o.getUserName()),
                    csv(o.getUserEmail()),
                    csv(courses),
                    csv(o.getPaymentMethodLabel()),
                    o.getSubtotal() != null ? o.getSubtotal().toPlainString() : "0",
                    o.getDiscountAmount() != null ? o.getDiscountAmount().toPlainString() : "0",
                    o.getTotalAmount() != null ? o.getTotalAmount().toPlainString() : "0",
                    csv(o.getStatusLabel()),
                    csv(o.getCreatedAt() != null ? fmt.format(o.getCreatedAt()) : ""),
                    csv(o.getPaidAt() != null ? fmt.format(o.getPaidAt()) : ""));
        }
        out.flush();
    }

    private String csv(String v) {
        if (v == null) return "\"\"";
        return "\"" + v.replace("\"", "\"\"") + "\"";
    }

    private String cleanDate(String raw) {
        if (raw == null) return "";
        String t = raw.trim();
        return t.matches("\\d{4}-\\d{2}-\\d{2}") ? t : "";
    }
}
