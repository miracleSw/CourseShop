package com.mycompany.courseshop.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;

public class Coupon {
    private int id;
    private String code;
    private int discountPercent;
    private BigDecimal maxDiscount;
    private int usageLimit;
    private int usedCount;
    private Timestamp expiredAt;
    private boolean status;
    private String stripeCouponId;

    public Coupon() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public int getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(int discountPercent) { this.discountPercent = discountPercent; }

    public BigDecimal getMaxDiscount() { return maxDiscount; }
    public void setMaxDiscount(BigDecimal maxDiscount) { this.maxDiscount = maxDiscount; }

    public int getUsageLimit() { return usageLimit; }
    public void setUsageLimit(int usageLimit) { this.usageLimit = usageLimit; }

    public int getUsedCount() { return usedCount; }
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }

    public Timestamp getExpiredAt() { return expiredAt; }
    public void setExpiredAt(Timestamp expiredAt) { this.expiredAt = expiredAt; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }

    public String getStripeCouponId() { return stripeCouponId; }
    public void setStripeCouponId(String stripeCouponId) { this.stripeCouponId = stripeCouponId; }

    public boolean isValidNow() {
        if (!status) return false;
        if (usageLimit > 0 && usedCount >= usageLimit) return false;
        return expiredAt == null || expiredAt.after(new Timestamp(System.currentTimeMillis()));
    }

    public BigDecimal calculateDiscount(BigDecimal subtotal) {
        if (subtotal == null || subtotal.compareTo(BigDecimal.ZERO) <= 0 || !isValidNow()) {
            return BigDecimal.ZERO;
        }
        BigDecimal raw = subtotal.multiply(BigDecimal.valueOf(discountPercent))
                .divide(BigDecimal.valueOf(100), 0, RoundingMode.FLOOR);
        if (maxDiscount != null && maxDiscount.compareTo(BigDecimal.ZERO) > 0 && raw.compareTo(maxDiscount) > 0) {
            return maxDiscount;
        }
        return raw.min(subtotal);
    }
}
