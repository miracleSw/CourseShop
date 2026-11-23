package com.mycompany.courseshop.model;

import com.mycompany.courseshop.utils.FormatUtil;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Order {
    private int id;
    private String orderCode;
    private int userId;
    private String userName;
    private String userEmail;
    private Integer couponId;
    private String couponCode;
    private String stripeCouponId;
    private BigDecimal subtotal = BigDecimal.ZERO;
    private BigDecimal discountAmount = BigDecimal.ZERO;
    private BigDecimal totalAmount = BigDecimal.ZERO;
    private String paymentMethod;
    private String stripeSessionId;
    private String status;
    private Timestamp createdAt;
    private Timestamp paidAt;
    private List<OrderItem> items = new ArrayList<>();

    public Order() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public Integer getCouponId() { return couponId; }
    public void setCouponId(Integer couponId) { this.couponId = couponId; }

    public String getCouponCode() { return couponCode; }
    public void setCouponCode(String couponCode) { this.couponCode = couponCode; }

    public String getStripeCouponId() { return stripeCouponId; }
    public void setStripeCouponId(String stripeCouponId) { this.stripeCouponId = stripeCouponId; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getStripeSessionId() { return stripeSessionId; }
    public void setStripeSessionId(String stripeSessionId) { this.stripeSessionId = stripeSessionId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }

    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }

    public String getFormattedSubtotal() { return FormatUtil.formatVndAlways(subtotal); }
    public String getFormattedDiscount() { return FormatUtil.formatVndAlways(discountAmount); }
    public String getFormattedTotal() { return FormatUtil.formatVndAlways(totalAmount); }

    public String getStatusLabel() {
        if (status == null) return "Chờ xác nhận";
        return switch (status.toUpperCase()) {
            case "PAID" -> "Đã thanh toán";
            case "PENDING" -> "Chờ xác nhận";
            case "CANCELLED" -> "Đã hủy";
            case "FAILED" -> "Thất bại";
            default -> status;
        };
    }

    public String getPaymentMethodLabel() {
        if (paymentMethod == null) return "Chuyển khoản";
        return switch (paymentMethod.toUpperCase()) {
            case "STRIPE", "STRIPE_SANDBOX" -> "Thẻ quốc tế (Stripe)";
            case "BANK_TRANSFER" -> "Chuyển khoản ngân hàng";
            default -> paymentMethod;
        };
    }
}
