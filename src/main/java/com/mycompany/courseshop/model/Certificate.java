package com.mycompany.courseshop.model;

import java.sql.Timestamp;

public class Certificate {
    private int id;
    private String certificateCode;
    private int userId;
    private int courseId;
    private String userName;
    private String courseTitle;
    private String courseCode;
    private String instructorName;
    private Timestamp issuedAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCertificateCode() { return certificateCode; }
    public void setCertificateCode(String certificateCode) { this.certificateCode = certificateCode; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    public String getCourseCode() { return courseCode; }
    public void setCourseCode(String courseCode) { this.courseCode = courseCode; }

    public String getInstructorName() { return instructorName; }
    public void setInstructorName(String instructorName) { this.instructorName = instructorName; }

    public Timestamp getIssuedAt() { return issuedAt; }
    public void setIssuedAt(Timestamp issuedAt) { this.issuedAt = issuedAt; }
}
