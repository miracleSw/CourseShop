package com.mycompany.courseshop.filter;

import com.mycompany.courseshop.utils.CsrfUtil;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Synchronizer Token CSRF protection for all state-changing browser requests (POST/PUT/DELETE).
 * Skips /webhooks/* which are authenticated via cryptographic gateway signatures (Stripe-Signature).
 */
@WebFilter(filterName = "CsrfFilter", urlPatterns = {"/*"})
public class CsrfFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (!(request instanceof HttpServletRequest req) || !(response instanceof HttpServletResponse resp)) {
            chain.doFilter(request, response);
            return;
        }

        String uri = req.getRequestURI();
        String ctx = req.getContextPath();
        String rel = uri.startsWith(ctx) ? uri.substring(ctx.length()) : uri;

        if (rel.startsWith("/assets/") || rel.startsWith("/webhooks/")) {
            chain.doFilter(request, response);
            return;
        }

        // Ensure every interactive page session has a valid CSRF token
        HttpSession session = req.getSession(true);
        CsrfUtil.ensureToken(session);

        String method = req.getMethod();
        boolean isMutating = "POST".equalsIgnoreCase(method)
                || "PUT".equalsIgnoreCase(method)
                || "DELETE".equalsIgnoreCase(method);

        if (isMutating) {
            // For multipart/form-data (e.g. AdminCourseServlet), token is passed via X-CSRF-Token or query _csrf
            if (!CsrfUtil.isValid(req)) {
                boolean isApi = rel.startsWith("/api/")
                        || "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
                        || (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json"));
                if (isApi) {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"ok\":false,\"error\":\"Phiên làm việc đã hết hạn. Vui lòng tải lại trang và thử lại.\"}");
                    return;
                }
                session.setAttribute("flashError", "Phiên làm việc đã hết hạn hoặc yêu cầu không hợp lệ. Vui lòng thử lại.");
                String referer = req.getHeader("Referer");
                if (referer != null && referer.startsWith(CsrfUtil.resolvePublicBaseUrl(req))) {
                    resp.sendRedirect(referer);
                } else {
                    resp.sendRedirect(ctx + "/home");
                }
                return;
            }
        }

        chain.doFilter(request, response);
    }
}
