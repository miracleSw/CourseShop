package com.mycompany.courseshop.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Sliding-window IP rate limiter protecting /login, /forgot-password, /reset-password, and /api/chat.
 */
@WebFilter(filterName = "RateLimitFilter", urlPatterns = {
    "/login", "/forgot-password", "/reset-password", "/api/chat"
})
public class RateLimitFilter implements Filter {

    private static final ConcurrentHashMap<String, Deque<Long>> BUCKETS = new ConcurrentHashMap<>();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (!(request instanceof HttpServletRequest req) || !(response instanceof HttpServletResponse resp)) {
            chain.doFilter(request, response);
            return;
        }

        if (!"POST".equalsIgnoreCase(req.getMethod())) {
            chain.doFilter(request, response);
            return;
        }

        String path = req.getServletPath();
        int maxRequests;
        long windowMs;
        String errorMessage;

        if ("/api/chat".equals(path)) {
            maxRequests = 15;
            windowMs = 60_000L; // 15 messages / minute
            errorMessage = "Bạn đang gửi câu hỏi quá nhanh. Vui lòng chờ một lát rồi tiếp tục.";
        } else if ("/forgot-password".equals(path) || "/reset-password".equals(path)) {
            maxRequests = 5;
            windowMs = 15 * 60_000L; // 5 requests / 15 minutes
            errorMessage = "Bạn đã yêu cầu đặt lại mật khẩu quá nhiều lần. Vui lòng thử lại sau 15 phút.";
        } else {
            maxRequests = 10;
            windowMs = 5 * 60_000L; // 10 login attempts / 5 minutes
            errorMessage = "Bạn đã thử đăng nhập quá nhiều lần. Vui lòng chờ vài phút rồi thử lại.";
        }

        String clientIp = extractClientIp(req);
        String key = path + "|" + clientIp;
        if (!allowRequest(key, maxRequests, windowMs)) {
            if ("/api/chat".equals(path)) {
                resp.setStatus(429);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"ok\":false,\"code\":\"RATE_LIMITED\",\"error\":\"" + errorMessage + "\"}");
                return;
            }
            req.getSession(true).setAttribute("flashError", errorMessage);
            resp.sendRedirect(req.getContextPath() + path);
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean allowRequest(String key, int maxRequests, long windowMs) {
        long now = System.currentTimeMillis();
        Deque<Long> q = BUCKETS.computeIfAbsent(key, k -> new ArrayDeque<>());
        synchronized (q) {
            while (!q.isEmpty() && now - q.peekFirst() > windowMs) {
                q.pollFirst();
            }
            if (q.size() >= maxRequests) {
                return false;
            }
            q.addLast(now);
            return true;
        }
    }

    private String extractClientIp(HttpServletRequest req) {
        String xff = req.getHeader("X-Forwarded-For");
        if (xff != null && !xff.isBlank()) {
            return xff.split(",")[0].trim();
        }
        String ip = req.getRemoteAddr();
        return ip != null ? ip : "unknown";
    }
}
