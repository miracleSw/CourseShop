package com.mycompany.courseshop.model;

import java.sql.Timestamp;

public class Enrollment {
    private int id;
    private int userId;
    private int courseId;
    private Integer orderId;
    private Timestamp enrolledAt;
    private Course course;
    private int completedLessons;
    private int totalLessons;

    public Enrollment() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }

    public Timestamp getEnrolledAt() { return enrolledAt; }
    public void setEnrolledAt(Timestamp enrolledAt) { this.enrolledAt = enrolledAt; }

    public Course getCourse() { return course; }
    public void setCourse(Course course) { this.course = course; }

    public int getCompletedLessons() { return completedLessons; }
    public void setCompletedLessons(int completedLessons) { this.completedLessons = completedLessons; }

    public int getTotalLessons() { return totalLessons; }
    public void setTotalLessons(int totalLessons) { this.totalLessons = totalLessons; }

    public int getProgressPercent() {
        if (totalLessons <= 0) return 0;
        return Math.min(100, Math.round((completedLessons * 100f) / totalLessons));
    }
}
