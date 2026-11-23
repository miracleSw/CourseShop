package com.mycompany.courseshop.utils;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class FormatUtil {

    private static final Pattern YT_PATTERN = Pattern.compile(
            "(?:youtube\\.com/(?:watch\\?v=|embed/|shorts/)|youtu\\.be/)([A-Za-z0-9_-]{11})"
    );

    private FormatUtil() {
    }

    public static String formatVnd(BigDecimal amount) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return "Miễn phí";
        }
        DecimalFormatSymbols symbols = new DecimalFormatSymbols(Locale.of("vi", "VN"));
        symbols.setGroupingSeparator('.');
        DecimalFormat df = new DecimalFormat("#,##0", symbols);
        return df.format(amount) + "đ";
    }

    public static String formatVndAlways(BigDecimal amount) {
        if (amount == null) {
            return "0đ";
        }
        DecimalFormatSymbols symbols = new DecimalFormatSymbols(Locale.of("vi", "VN"));
        symbols.setGroupingSeparator('.');
        DecimalFormat df = new DecimalFormat("#,##0", symbols);
        return df.format(amount) + "đ";
    }

    public static String formatDurationHours(int totalSeconds) {
        if (totalSeconds <= 0) {
            return "0 phút";
        }
        int hours = totalSeconds / 3600;
        int minutes = (totalSeconds % 3600) / 60;
        if (hours > 0 && minutes > 0) {
            return hours + "g " + minutes + "p";
        }
        if (hours > 0) {
            return hours + " giờ";
        }
        return Math.max(1, minutes) + " phút";
    }

    public static String formatTimestamp(int seconds) {
        int s = Math.max(0, seconds);
        int h = s / 3600;
        int m = (s % 3600) / 60;
        int sec = s % 60;
        if (h > 0) {
            return String.format("%d:%02d:%02d", h, m, sec);
        }
        return String.format("%02d:%02d", m, sec);
    }

    public static String extractYoutubeId(String url) {
        if (url == null || url.isBlank()) {
            return "";
        }
        Matcher m = YT_PATTERN.matcher(url);
        if (m.find()) {
            return m.group(1);
        }
        if (url.matches("^[A-Za-z0-9_-]{11}$")) {
            return url;
        }
        return "";
    }

    public static String slugify(String input) {
        if (input == null || input.isBlank()) {
            return "item-" + System.currentTimeMillis();
        }
        String normalized = Normalizer.normalize(input, Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                .replace('đ', 'd')
                .replace('Đ', 'd')
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-+|-+$", "");
        return normalized.isEmpty() ? "item-" + System.currentTimeMillis() : normalized;
    }

    public static String maskSecret(String secret) {
        if (secret == null || secret.isBlank()) {
            return "";
        }
        String trimmed = secret.trim();
        if (trimmed.length() <= 8) {
            return "••••••••";
        }
        return trimmed.substring(0, 6) + "••••••••" + trimmed.substring(trimmed.length() - 4);
    }

    public static String levelLabel(String level) {
        if (level == null) {
            return "Người mới";
        }
        return switch (level.toUpperCase(Locale.ROOT)) {
            case "BEGINNER" -> "Người mới";
            case "INTERMEDIATE" -> "Trung cấp";
            case "ADVANCED" -> "Đi làm / Nâng cao";
            default -> level;
        };
    }
}
