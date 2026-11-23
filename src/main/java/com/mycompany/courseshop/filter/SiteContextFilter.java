package com.mycompany.courseshop.filter;

import com.mycompany.courseshop.dao.CartDAO;
import com.mycompany.courseshop.dao.CouponDAO;
import com.mycompany.courseshop.dao.LearningPathDAO;
import com.mycompany.courseshop.dao.SettingsDAO;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;

/**
 * Loads live MySQL-backed site settings, navigation learning paths, active coupons,
 * and persistent user cart count for every HTML view (zero hardcoded view data).
 */
@WebFilter(filterName = "SiteContextFilter", urlPatterns = {"/*"})
public class SiteContextFilter implements Filter {

    private final SettingsDAO settingsDAO = new SettingsDAO();
    private final LearningPathDAO pathDAO = new LearningPathDAO();
    private final CouponDAO couponDAO = new CouponDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (request instanceof HttpServletRequest req) {
            String uri = req.getRequestURI();
            String ctx = req.getContextPath();
            String rel = uri.startsWith(ctx) ? uri.substring(ctx.length()) : uri;

            if (!rel.startsWith("/assets/") && !rel.startsWith("/api/") && !rel.startsWith("/webhooks/")) {
                req.setAttribute("siteSettings", settingsDAO.findAll());
                req.setAttribute("footerPaths", pathDAO.findAllSummary());
                req.setAttribute("activeCoupons", couponDAO.findAllActive());

                HttpSession session = req.getSession(false);
                User user = (session != null) ? (User) session.getAttribute("user") : null;
                int cartCount = 0;
                if (user != null) {
                    cartCount = cartDAO.countByUser(user.getId());
                } else if (session != null && session.getAttribute("cart") instanceof Map<?, ?> m) {
                    cartCount = m.size();
                }
                req.setAttribute("globalCartCount", cartCount);
            }
        }
        chain.doFilter(request, response);
    }
}
