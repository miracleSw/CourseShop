package com.mycompany.courseshop.model;

import java.util.ArrayList;
import java.util.List;

public class Quiz {
    private int id;
    private int courseId;
    private Integer sectionId;
    private Integer lessonId;
    private String title;
    private String description;
    private int passScore = 70;
    private List<QuizQuestion> questions = new ArrayList<>();
    private Integer bestScore;
    private boolean passed;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public Integer getSectionId() { return sectionId; }
    public void setSectionId(Integer sectionId) { this.sectionId = sectionId; }

    public Integer getLessonId() { return lessonId; }
    public void setLessonId(Integer lessonId) { this.lessonId = lessonId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getPassScore() { return passScore; }
    public void setPassScore(int passScore) { this.passScore = passScore; }

    public List<QuizQuestion> getQuestions() { return questions; }
    public void setQuestions(List<QuizQuestion> questions) { this.questions = questions; }

    public Integer getBestScore() { return bestScore; }
    public void setBestScore(Integer bestScore) { this.bestScore = bestScore; }

    public boolean isPassed() { return passed; }
    public void setPassed(boolean passed) { this.passed = passed; }
}
