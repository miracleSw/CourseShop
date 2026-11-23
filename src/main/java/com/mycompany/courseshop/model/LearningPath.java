package com.mycompany.courseshop.model;

import java.util.ArrayList;
import java.util.List;

public class LearningPath {
    private int id;
    private String code;
    private String title;
    private String slug;
    private String summary;
    private String targetRole;
    private String icon;
    private int sortOrder;
    private List<Course> courses = new ArrayList<>();

    public LearningPath() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }

    public String getTargetRole() { return targetRole; }
    public void setTargetRole(String targetRole) { this.targetRole = targetRole; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public List<Course> getCourses() { return courses; }
    public void setCourses(List<Course> courses) { this.courses = courses; }

    public int getTotalHours() {
        int sec = 0;
        for (Course c : courses) {
            sec += c.getTotalDurationSeconds();
        }
        return Math.max(1, Math.round(sec / 3600f));
    }
}
