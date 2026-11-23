package com.mycompany.courseshop.controller.admin;

import com.mycompany.courseshop.dao.CourseDAO;
import com.mycompany.courseshop.dao.PracticeDAO;
import com.mycompany.courseshop.dao.QuizDAO;
import com.mycompany.courseshop.model.Course;
import com.mycompany.courseshop.model.Lesson;
import com.mycompany.courseshop.model.LessonExercise;
import com.mycompany.courseshop.model.QuizQuestion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "AdminCurriculumServlet", urlPatterns = {"/admin/curriculum"})
public class AdminCurriculumServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final PracticeDAO practiceDAO = new PracticeDAO();
    private final QuizDAO quizDAO = new QuizDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int courseId = parseInt(req.getParameter("courseId"), 0);
        Course course = courseDAO.findById(courseId);
        if (course == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/courses");
            return;
        }
        req.setAttribute("course", course);
        req.setAttribute("sections", courseDAO.findSectionsWithLessons(courseId, null));
        req.setAttribute("exercisesMap", practiceDAO.findMapByCourse(courseId));
        req.setAttribute("quizzes", quizDAO.findByCourseForUser(courseId, null));
        req.setAttribute("adminNav", "courses");
        req.setAttribute("pageTitle", "Giáo trình: " + course.getCode() + " — Quản trị CourseShop");
        req.getRequestDispatcher("/views/admin/curriculum.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int courseId = parseInt(req.getParameter("courseId"), 0);
        String action = req.getParameter("action");

        try {
            switch (action == null ? "" : action) {
                case "addSection" -> {
                    String title = req.getParameter("title");
                    int sort = parseInt(req.getParameter("sortOrder"), 1);
                    if (title != null && !title.isBlank()) {
                        courseDAO.createSection(courseId, title, sort);
                        req.getSession().setAttribute("flashSuccess", "Đã thêm chương mới.");
                    }
                }
                case "updateSection" -> {
                    int sectionId = parseInt(req.getParameter("sectionId"), 0);
                    String title = req.getParameter("title");
                    int sort = parseInt(req.getParameter("sortOrder"), 1);
                    if (sectionId > 0 && title != null && !title.isBlank()) {
                        courseDAO.updateSection(sectionId, title, sort);
                        req.getSession().setAttribute("flashSuccess", "Đã cập nhật thông tin chương.");
                    }
                }
                case "deleteSection" -> {
                    courseDAO.deleteSection(parseInt(req.getParameter("sectionId"), 0));
                    req.getSession().setAttribute("flashSuccess", "Đã xóa chương và các bài học bên trong.");
                }
                case "addLesson" -> {
                    Lesson l = new Lesson();
                    l.setCourseId(courseId);
                    l.setSectionId(parseInt(req.getParameter("sectionId"), 0));
                    l.setTitle(req.getParameter("title") == null ? "" : req.getParameter("title").trim());
                    l.setVideoUrl(req.getParameter("videoUrl"));
                    l.setDurationSeconds(parseInt(req.getParameter("durationMinutes"), 10) * 60);
                    l.setContentText(req.getParameter("contentText"));
                    l.setPreview("1".equals(req.getParameter("isPreview")));
                    l.setSortOrder(parseInt(req.getParameter("sortOrder"), 1));
                    if (!l.getTitle().isBlank() && l.getSectionId() > 0) {
                        courseDAO.createLesson(l);
                        req.getSession().setAttribute("flashSuccess", "Đã thêm bài học \"" + l.getTitle() + "\".");
                    }
                }
                case "updateLesson" -> {
                    Lesson l = new Lesson();
                    l.setId(parseInt(req.getParameter("lessonId"), 0));
                    l.setTitle(req.getParameter("title") == null ? "" : req.getParameter("title").trim());
                    l.setVideoUrl(req.getParameter("videoUrl"));
                    l.setDurationSeconds(parseInt(req.getParameter("durationMinutes"), 10) * 60);
                    l.setContentText(req.getParameter("contentText"));
                    l.setPreview("1".equals(req.getParameter("isPreview")));
                    l.setSortOrder(parseInt(req.getParameter("sortOrder"), 1));
                    if (l.getId() > 0 && !l.getTitle().isBlank()) {
                        courseDAO.updateLesson(l);
                        req.getSession().setAttribute("flashSuccess", "Đã cập nhật bài học \"" + l.getTitle() + "\".");
                    }
                }
                case "deleteLesson" -> {
                    courseDAO.deleteLesson(parseInt(req.getParameter("lessonId"), 0));
                    req.getSession().setAttribute("flashSuccess", "Đã xóa bài học.");
                }
                case "saveExercise" -> {
                    int lessonId = parseInt(req.getParameter("lessonId"), 0);
                    String title = req.getParameter("title");
                    String prompt = req.getParameter("promptText");
                    if (lessonId > 0 && title != null && !title.isBlank() && prompt != null && !prompt.isBlank()) {
                        LessonExercise ex = new LessonExercise();
                        ex.setLessonId(lessonId);
                        ex.setCourseId(courseId);
                        ex.setTitle(title);
                        ex.setPromptText(prompt);
                        ex.setLanguage(req.getParameter("language"));
                        ex.setStarterCode(req.getParameter("starterCode"));
                        ex.setExpectedTokens(req.getParameter("expectedTokens"));
                        ex.setHintText(req.getParameter("hintText"));
                        ex.setSolutionCode(req.getParameter("solutionCode"));
                        practiceDAO.upsertExercise(ex);
                        req.getSession().setAttribute("flashSuccess", "Đã lưu bài tập thực hành cho bài học.");
                    }
                }
                case "deleteExercise" -> {
                    int lessonId = parseInt(req.getParameter("lessonId"), 0);
                    if (lessonId > 0) {
                        practiceDAO.deleteExerciseByLesson(lessonId);
                        req.getSession().setAttribute("flashSuccess", "Đã gỡ bài tập thực hành.");
                    }
                }
                case "addQuiz" -> {
                    String title = req.getParameter("title");
                    String desc = req.getParameter("description");
                    int sectionId = parseInt(req.getParameter("sectionId"), 0);
                    int passScore = parseInt(req.getParameter("passScore"), 70);
                    if (title != null && !title.isBlank()) {
                        quizDAO.createQuiz(courseId, sectionId > 0 ? sectionId : null, null, title, desc, passScore);
                        req.getSession().setAttribute("flashSuccess", "Đã tạo bài kiểm tra trắc nghiệm mới.");
                    }
                }
                case "deleteQuiz" -> {
                    quizDAO.deleteQuiz(parseInt(req.getParameter("quizId"), 0));
                    req.getSession().setAttribute("flashSuccess", "Đã xóa bài kiểm tra.");
                }
                case "addQuestion" -> {
                    QuizQuestion qq = new QuizQuestion();
                    qq.setQuizId(parseInt(req.getParameter("quizId"), 0));
                    qq.setQuestionText(req.getParameter("questionText") == null ? "" : req.getParameter("questionText"));
                    qq.setOptionA(req.getParameter("optionA") == null ? "" : req.getParameter("optionA"));
                    qq.setOptionB(req.getParameter("optionB") == null ? "" : req.getParameter("optionB"));
                    qq.setOptionC(req.getParameter("optionC") == null ? "" : req.getParameter("optionC"));
                    qq.setOptionD(req.getParameter("optionD") == null ? "" : req.getParameter("optionD"));
                    qq.setCorrectOption(req.getParameter("correctOption") == null ? "A" : req.getParameter("correctOption"));
                    qq.setExplanation(req.getParameter("explanation"));
                    qq.setSortOrder(parseInt(req.getParameter("sortOrder"), 1));
                    if (qq.getQuizId() > 0 && !qq.getQuestionText().isBlank()) {
                        quizDAO.addQuestion(qq);
                        req.getSession().setAttribute("flashSuccess", "Đã thêm câu hỏi trắc nghiệm.");
                    }
                }
                case "deleteQuestion" -> {
                    quizDAO.deleteQuestion(parseInt(req.getParameter("questionId"), 0));
                    req.getSession().setAttribute("flashSuccess", "Đã xóa câu hỏi.");
                }
                default -> {}
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.getSession().setAttribute("flashError", "Không thể cập nhật giáo trình lúc này. Vui lòng thử lại.");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/curriculum?courseId=" + courseId);
    }

    private int parseInt(String v, int def) {
        try { return Integer.parseInt(v.trim()); } catch (Exception e) { return def; }
    }
}
