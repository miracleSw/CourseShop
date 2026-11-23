package com.mycompany.courseshop.controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.mycompany.courseshop.dao.CertificateDAO;
import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.dao.DiscussionDAO;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.dao.PracticeDAO;
import com.mycompany.courseshop.dao.QuizDAO;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.Lesson;
import com.mycompany.courseshop.model.LessonDiscussion;
import com.mycompany.courseshop.model.LessonExercise;
import com.mycompany.courseshop.model.Quiz;
import com.mycompany.courseshop.model.QuizQuestion;
import com.mycompany.courseshop.model.Section;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "LearnServlet", urlPatterns = {"/learn"})
public class LearnServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    private final PracticeDAO practiceDAO = new PracticeDAO();
    private final QuizDAO quizDAO = new QuizDAO();
    private final DiscussionDAO discussionDAO = new DiscussionDAO();
    private final CertificateDAO certificateDAO = new CertificateDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("user");
        int courseId = parseInt(req.getParameter("courseId"));
        int lessonId = parseInt(req.getParameter("lessonId"));

        Course course = courseDAO.findById(courseId);
        if (course == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy khóa học.");
            return;
        }

        boolean enrolled = enrollmentDAO.isEnrolled(user.getId(), courseId);
        boolean allowed = user.isAdmin() || enrolled;
        if (!allowed) {
            req.getSession().setAttribute("flashError", "Bạn cần đăng ký khóa học này để truy cập không gian học tập.");
            resp.sendRedirect(req.getContextPath() + "/course?slug=" + course.getSlug());
            return;
        }

        List<Section> sections = courseDAO.findSectionsWithLessons(courseId, user.getId());
        List<Lesson> flatLessons = new ArrayList<>();
        int completedCount = 0;
        for (Section s : sections) {
            for (Lesson l : s.getLessons()) {
                flatLessons.add(l);
                if (l.isCompleted()) completedCount++;
            }
        }

        // Resume Playback: if no explicit lessonId requested, restore last_lesson_id
        if (lessonId <= 0 && enrolled) {
            Integer lastId = enrollmentDAO.getLastLessonId(user.getId(), courseId);
            if (lastId != null && lastId > 0) {
                lessonId = lastId;
            }
        }

        Lesson activeLesson = null;
        int activeIndex = -1;
        for (int i = 0; i < flatLessons.size(); i++) {
            if (lessonId > 0 && flatLessons.get(i).getId() == lessonId) {
                activeLesson = flatLessons.get(i);
                activeIndex = i;
                break;
            }
        }
        if (activeLesson == null && !flatLessons.isEmpty()) {
            activeIndex = 0;
            for (int i = 0; i < flatLessons.size(); i++) {
                if (!flatLessons.get(i).isCompleted()) {
                    activeIndex = i;
                    break;
                }
            }
            activeLesson = flatLessons.get(activeIndex);
        }

        if (activeLesson != null && enrolled) {
            enrollmentDAO.updateLastLesson(user.getId(), courseId, activeLesson.getId());
        }

        Lesson prevLesson = (activeIndex > 0) ? flatLessons.get(activeIndex - 1) : null;
        Lesson nextLesson = (activeIndex >= 0 && activeIndex < flatLessons.size() - 1) ? flatLessons.get(activeIndex + 1) : null;

        int totalLessons = flatLessons.size();
        int progressPercent = totalLessons > 0 ? Math.round((completedCount * 100f) / totalLessons) : 0;

        String certCode = null;
        if (enrolled) {
            certCode = certificateDAO.findCode(user.getId(), courseId);
            if (certCode == null && progressPercent == 100 && totalLessons > 0) {
                try {
                    certCode = certificateDAO.issueIfNotExists(user.getId(), courseId);
                } catch (Exception ignored) {}
            }
        }

        LessonExercise exercise = activeLesson != null
                ? practiceDAO.findByLessonForUser(activeLesson.getId(), user.getId()) : null;
        List<Quiz> quizzes = quizDAO.findByCourseForUser(courseId, user.getId());
        List<LessonDiscussion> discussions = activeLesson != null
                ? discussionDAO.findTreeByLesson(activeLesson.getId()) : List.of();

        req.setAttribute("course", course);
        req.setAttribute("sections", sections);
        req.setAttribute("activeLesson", activeLesson);
        req.setAttribute("prevLesson", prevLesson);
        req.setAttribute("nextLesson", nextLesson);
        req.setAttribute("completedCount", completedCount);
        req.setAttribute("totalLessons", totalLessons);
        req.setAttribute("progressPercent", progressPercent);
        req.setAttribute("certificateCode", certCode);
        req.setAttribute("lessonNotes", activeLesson != null
                ? enrollmentDAO.findNotes(user.getId(), courseId, activeLesson.getId()) : List.of());
        req.setAttribute("exercise", exercise);
        req.setAttribute("exerciseJson", serializeExercise(exercise));
        req.setAttribute("quizzesJson", serializeQuizzes(quizzes, activeLesson));
        req.setAttribute("quizzesCount", quizzes.size());
        req.setAttribute("discussionsJson", serializeDiscussions(discussions, user));
        req.setAttribute("discussionsCount", discussions.size());
        req.setAttribute("pageTitle", (activeLesson != null ? activeLesson.getTitle() + " · " : "") + course.getTitle());

        req.getRequestDispatcher("/views/learn.jsp").forward(req, resp);
    }

    private String serializeExercise(LessonExercise ex) {
        if (ex == null) return "null";
        JsonObject o = new JsonObject();
        o.addProperty("id", ex.getId());
        o.addProperty("title", ex.getTitle());
        o.addProperty("promptText", ex.getPromptText());
        o.addProperty("language", ex.getLanguage());
        o.addProperty("starterCode", ex.getStarterCode() == null ? "" : ex.getStarterCode());
        o.addProperty("hintText", ex.getHintText() == null ? "" : ex.getHintText());
        o.addProperty("solutionCode", ex.getSolutionCode() == null ? "" : ex.getSolutionCode());
        o.addProperty("lastSubmittedCode", ex.getLastSubmittedCode() == null ? "" : ex.getLastSubmittedCode());
        o.addProperty("passed", ex.isPassed());
        o.addProperty("lastFeedback", ex.getLastFeedback() == null ? "" : ex.getLastFeedback());
        return safeInlineJson(gson.toJson(o));
    }

    private String serializeQuizzes(List<Quiz> quizzes, Lesson activeLesson) {
        JsonArray arr = new JsonArray();
        for (Quiz q : quizzes) {
            if (q.getQuestions().isEmpty()) continue;
            JsonObject o = new JsonObject();
            o.addProperty("id", q.getId());
            o.addProperty("sectionId", q.getSectionId());
            o.addProperty("lessonId", q.getLessonId());
            o.addProperty("title", q.getTitle());
            o.addProperty("description", q.getDescription() == null ? "" : q.getDescription());
            o.addProperty("passScore", q.getPassScore());
            o.addProperty("bestScore", q.getBestScore());
            o.addProperty("passed", q.isPassed());
            boolean isCurrentSection = activeLesson != null && q.getSectionId() != null
                    && q.getSectionId() == activeLesson.getSectionId();
            o.addProperty("isCurrentSection", isCurrentSection);
            JsonArray qArr = new JsonArray();
            for (QuizQuestion qq : q.getQuestions()) {
                JsonObject qo = new JsonObject();
                qo.addProperty("id", qq.getId());
                qo.addProperty("questionText", qq.getQuestionText());
                qo.addProperty("optionA", qq.getOptionA());
                qo.addProperty("optionB", qq.getOptionB());
                qo.addProperty("optionC", qq.getOptionC());
                qo.addProperty("optionD", qq.getOptionD());
                qArr.add(qo);
            }
            o.add("questions", qArr);
            arr.add(o);
        }
        return safeInlineJson(gson.toJson(arr));
    }

    private String serializeDiscussions(List<LessonDiscussion> items, User current) {
        SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        JsonArray arr = new JsonArray();
        for (LessonDiscussion d : items) {
            arr.add(discussionToJson(d, current, fmt));
        }
        return safeInlineJson(gson.toJson(arr));
    }

    private JsonObject discussionToJson(LessonDiscussion d, User current, SimpleDateFormat fmt) {
        JsonObject o = new JsonObject();
        o.addProperty("id", d.getId());
        o.addProperty("parentId", d.getParentId());
        o.addProperty("userId", d.getUserId());
        o.addProperty("userName", d.getUserName());
        o.addProperty("userInitials", d.getUserInitials());
        o.addProperty("instructor", d.isInstructor());
        o.addProperty("content", d.getContent());
        o.addProperty("createdAt", d.getCreatedAt() != null ? fmt.format(d.getCreatedAt()) : "Vừa xong");
        o.addProperty("canDelete", current != null && (current.isAdmin() || current.getId() == d.getUserId()));
        JsonArray replies = new JsonArray();
        for (LessonDiscussion r : d.getReplies()) {
            replies.add(discussionToJson(r, current, fmt));
        }
        o.add("replies", replies);
        return o;
    }

    private String safeInlineJson(String raw) {
        return raw.replace("</", "<\\/");
    }

    private int parseInt(String val) {
        try { return Integer.parseInt(val); } catch (Exception e) { return 0; }
    }
}
