package com.mycompany.courseshop.model;

import com.mycompany.courseshop.utils.FormatUtil;
import java.math.BigDecimal;

public class OrderItem {
    private int id;
    private int orderId;
    private int courseId;
    private String courseTitle;
    private String courseSlug;
    private String courseCode;
    private String courseThumbnail;
    private String stripeProductId;
    private BigDecimal unitPrice = BigDecimal.ZERO;

    public OrderItem() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    public String getCourseSlug() { return courseSlug; }
    public void setCourseSlug(String courseSlug) { this.courseSlug = courseSlug; }

    public String getCourseCode() { return courseCode; }
    public void setCourseCode(String courseCode) { this.courseCode = courseCode; }

    public String getCourseThumbnail() { return courseThumbnail; }
    public void setCourseThumbnail(String courseThumbnail) { this.courseThumbnail = courseThumbnail; }

    public String getStripeProductId() { return stripeProductId; }
    public void setStripeProductId(String stripeProductId) { this.stripeProductId = stripeProductId; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public String getFormattedPrice() { return FormatUtil.formatVndAlways(unitPrice); }
}
