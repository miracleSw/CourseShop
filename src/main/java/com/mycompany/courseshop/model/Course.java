package com.mycompany.courseshop.model;

import com.mycompany.courseshop.utils.FormatUtil;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Course {
    private int id;
    private int categoryId;
    private String categoryName;
    private String code;
    private String title;
    private String slug;
    private String shortDesc;
    private String description;
    private String outcomesRaw;
    private String instructorName;
    private String thumbnail;
    private BigDecimal price = BigDecimal.ZERO;
    private BigDecimal salePrice;
    private boolean pro;
    private String stripeProductId;
    private String level;
    private int featuredOrder = 100;
    private String status;
    private Timestamp createdAt;

    private int lessonCount;
    private int totalDurationSeconds;
    private double avgRating;
    private int reviewCount;
    private int studentCount;

    public Course() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getShortDesc() { return shortDesc; }
    public void setShortDesc(String shortDesc) { this.shortDesc = shortDesc; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getOutcomesRaw() { return outcomesRaw; }
    public void setOutcomesRaw(String outcomesRaw) { this.outcomesRaw = outcomesRaw; }

    public String getInstructorName() { return instructorName; }
    public void setInstructorName(String instructorName) { this.instructorName = instructorName; }

    public String getThumbnail() { return thumbnail; }
    public void setThumbnail(String thumbnail) { this.thumbnail = thumbnail; }

    public boolean isExternalThumbnail() {
        return thumbnail != null && (thumbnail.startsWith("http://") || thumbnail.startsWith("https://"));
    }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price != null ? price : BigDecimal.ZERO; }

    public BigDecimal getSalePrice() { return salePrice; }
    public void setSalePrice(BigDecimal salePrice) { this.salePrice = salePrice; }

    public boolean isPro() { return pro; }
    public void setPro(boolean pro) { this.pro = pro; }

    public String getStripeProductId() { return stripeProductId; }
    public void setStripeProductId(String stripeProductId) { this.stripeProductId = stripeProductId; }

    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }

    public int getFeaturedOrder() { return featuredOrder; }
    public void setFeaturedOrder(int featuredOrder) { this.featuredOrder = featuredOrder; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getLessonCount() { return lessonCount; }
    public void setLessonCount(int lessonCount) { this.lessonCount = lessonCount; }

    public int getTotalDurationSeconds() { return totalDurationSeconds; }
    public void setTotalDurationSeconds(int totalDurationSeconds) { this.totalDurationSeconds = totalDurationSeconds; }

    public double getAvgRating() { return avgRating; }
    public void setAvgRating(double avgRating) { this.avgRating = avgRating; }

    public int getReviewCount() { return reviewCount; }
    public void setReviewCount(int reviewCount) { this.reviewCount = reviewCount; }

    public int getStudentCount() { return studentCount; }
    public void setStudentCount(int studentCount) { this.studentCount = studentCount; }

    public boolean isFree() {
        return getEffectivePrice().compareTo(BigDecimal.ZERO) <= 0;
    }

    public BigDecimal getEffectivePrice() {
        if (salePrice != null && salePrice.compareTo(BigDecimal.ZERO) > 0
                && price != null && salePrice.compareTo(price) < 0) {
            return salePrice;
        }
        return price != null ? price : BigDecimal.ZERO;
    }

    public boolean isHasDiscount() {
        return salePrice != null && price != null
                && salePrice.compareTo(BigDecimal.ZERO) > 0
                && salePrice.compareTo(price) < 0;
    }

    public int getDiscountPercent() {
        if (!isHasDiscount() || price.compareTo(BigDecimal.ZERO) <= 0) return 0;
        BigDecimal diff = price.subtract(salePrice);
        return diff.multiply(BigDecimal.valueOf(100))
                .divide(price, 0, RoundingMode.HALF_UP)
                .intValue();
    }

    public String getFormattedEffectivePrice() {
        return FormatUtil.formatVnd(getEffectivePrice());
    }

    public String getFormattedPrice() {
        return FormatUtil.formatVnd(price);
    }

    public String getFormattedDuration() {
        return FormatUtil.formatDurationHours(totalDurationSeconds);
    }

    public String getLevelLabel() {
        return FormatUtil.levelLabel(level);
    }

    public List<String> getOutcomes() {
        List<String> list = new ArrayList<>();
        if (outcomesRaw == null || outcomesRaw.isBlank()) return list;
        for (String line : outcomesRaw.split("\\r?\\n")) {
            String trimmed = line.trim();
            if (!trimmed.isEmpty()) list.add(trimmed);
        }
        return list;
    }
}
