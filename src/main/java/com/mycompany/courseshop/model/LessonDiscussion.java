package com.mycompany.courseshop.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class LessonDiscussion {
    private int id;
    private int lessonId;
    private int courseId;
    private int userId;
    private Integer parentId;
    private String userName;
    private String userInitials;
    private boolean instructor;
    private String content;
    private Timestamp createdAt;
    private List<LessonDiscussion> replies = new ArrayList<>();

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getLessonId() { return lessonId; }
    public void setLessonId(int lessonId) { this.lessonId = lessonId; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Integer getParentId() { return parentId; }
    public void setParentId(Integer parentId) { this.parentId = parentId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserInitials() { return userInitials; }
    public void setUserInitials(String userInitials) { this.userInitials = userInitials; }

    public boolean isInstructor() { return instructor; }
    public void setInstructor(boolean instructor) { this.instructor = instructor; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public List<LessonDiscussion> getReplies() { return replies; }
    public void setReplies(List<LessonDiscussion> replies) { this.replies = replies; }
}
