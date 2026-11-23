package com.mycompany.courseshop.model;

public class LessonExercise {
    private int id;
    private int lessonId;
    private int courseId;
    private String title;
    private String promptText;
    private String language;
    private String starterCode;
    private String expectedTokens;
    private String hintText;
    private String solutionCode;
    private String lastSubmittedCode;
    private boolean passed;
    private String lastFeedback;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getLessonId() { return lessonId; }
    public void setLessonId(int lessonId) { this.lessonId = lessonId; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getPromptText() { return promptText; }
    public void setPromptText(String promptText) { this.promptText = promptText; }

    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }

    public String getStarterCode() { return starterCode; }
    public void setStarterCode(String starterCode) { this.starterCode = starterCode; }

    public String getExpectedTokens() { return expectedTokens; }
    public void setExpectedTokens(String expectedTokens) { this.expectedTokens = expectedTokens; }

    public String getHintText() { return hintText; }
    public void setHintText(String hintText) { this.hintText = hintText; }

    public String getSolutionCode() { return solutionCode; }
    public void setSolutionCode(String solutionCode) { this.solutionCode = solutionCode; }

    public String getLastSubmittedCode() { return lastSubmittedCode; }
    public void setLastSubmittedCode(String lastSubmittedCode) { this.lastSubmittedCode = lastSubmittedCode; }

    public boolean isPassed() { return passed; }
    public void setPassed(boolean passed) { this.passed = passed; }

    public String getLastFeedback() { return lastFeedback; }
    public void setLastFeedback(String lastFeedback) { this.lastFeedback = lastFeedback; }
}
