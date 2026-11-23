package com.mycompany.courseshop.model;

import com.mycompany.courseshop.utils.FormatUtil;

public class Lesson {
    private int id;
    private int sectionId;
    private int courseId;
    private String title;
    private String videoUrl;
    private int durationSeconds;
    private String contentText;
    private boolean preview;
    private int sortOrder;
    private boolean completed;

    public Lesson() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getSectionId() { return sectionId; }
    public void setSectionId(int sectionId) { this.sectionId = sectionId; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getVideoUrl() { return videoUrl; }
    public void setVideoUrl(String videoUrl) { this.videoUrl = videoUrl; }

    public int getDurationSeconds() { return durationSeconds; }
    public void setDurationSeconds(int durationSeconds) { this.durationSeconds = durationSeconds; }

    public String getContentText() { return contentText; }
    public void setContentText(String contentText) { this.contentText = contentText; }

    public boolean isPreview() { return preview; }
    public void setPreview(boolean preview) { this.preview = preview; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public boolean isCompleted() { return completed; }
    public void setCompleted(boolean completed) { this.completed = completed; }

    public String getFormattedDuration() {
        return FormatUtil.formatTimestamp(durationSeconds);
    }

    public String getYoutubeId() {
        return FormatUtil.extractYoutubeId(videoUrl);
    }
}
