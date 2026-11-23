package com.mycompany.courseshop.model;

import java.util.ArrayList;
import java.util.List;

public class Section {
    private int id;
    private int courseId;
    private String title;
    private int sortOrder;
    private List<Lesson> lessons = new ArrayList<>();

    public Section() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public List<Lesson> getLessons() { return lessons; }
    public void setLessons(List<Lesson> lessons) { this.lessons = lessons; }
}
