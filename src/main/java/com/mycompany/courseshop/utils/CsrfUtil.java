package com.mycompany.courseshop.utils;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

public final class CsrfUtil {

    public static final String SESSION_ATTR = "csrfToken";
    public static final String PARAM_NAME = "_csrf";
    public static final String HEADER_NAME = "X-CSRF-Token";

    private static final SecureRandom RNG = new SecureRandom();

    private CsrfUtil() {}

    public static String ensureToken(HttpSession session) {
        Object existing = session.getAttribute(SESSION_ATTR);
        if (existing instanceof String s && s.length() >= 32) {
            return s;
        }
        byte[] bytes = new byte[32];
        RNG.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute(SESSION_ATTR, token);
        return token;
    }

    public static boolean isValid(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;
        Object expectedObj = session.getAttribute(SESSION_ATTR);
        if (!(expectedObj instanceof String expected) || expected.isBlank()) {
            return false;
        }
        String supplied = req.getHeader(HEADER_NAME);
        if (supplied == null || supplied.isBlank()) {
            supplied = req.getParameter(PARAM_NAME);
        }
        if (supplied == null || supplied.isBlank()) {
            return false;
        }
        return MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8),
                supplied.trim().getBytes(StandardCharsets.UTF_8)
        );
    }

    public static String sha256Hex(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException("SHA-256 unavailable", e);
        }
    }

    public static String randomUrlToken(int byteLen) {
        byte[] bytes = new byte[byteLen];
        RNG.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    public static String resolvePublicBaseUrl(HttpServletRequest req) {
        String configured = com.mycompany.courseshop.config.AppConfig.getAppBaseUrl();
        if (configured != null && !configured.isBlank()) {
            return configured.endsWith("/") ? configured.substring(0, configured.length() - 1) : configured;
        }
        String forwardedProto = req.getHeader("X-Forwarded-Proto");
        String scheme = (forwardedProto != null && !forwardedProto.isBlank())
                ? forwardedProto.split(",")[0].trim() : req.getScheme();
        String forwardedHost = req.getHeader("X-Forwarded-Host");
        if (forwardedHost != null && !forwardedHost.isBlank()) {
            return scheme + "://" + forwardedHost.split(",")[0].trim() + req.getContextPath();
        }
        int port = req.getServerPort();
        boolean isDefaultPort = ("http".equalsIgnoreCase(scheme) && port == 80)
                || ("https".equalsIgnoreCase(scheme) && port == 443);
        return scheme + "://" + req.getServerName() + (isDefaultPort ? "" : ":" + port) + req.getContextPath();
    }
}
