package com.mycompany.courseshop.controller;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mycompany.courseshop.dao.EnrollmentDAO;
import com.mycompany.courseshop.dao.QuizDAO;
import com.mycompany.courseshop.model.Quiz;
import com.mycompany.courseshop.model.QuizQuestion;
import com.mycompany.courseshop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.stream.Collectors;

@WebServlet(name = "QuizServlet", urlPatterns = {"/api/quiz"})
public class QuizServlet extends HttpServlet {

    private final QuizDAO quizDAO = new QuizDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        User user = (User) req.getSession().getAttribute("user");

        try {
            String body = req.getReader().lines().collect(Collectors.joining());
            JsonObject json = JsonParser.parseString(body).getAsJsonObject();
            int quizId = json.get("quizId").getAsInt();
            JsonObject answers = json.has("answers") && json.get("answers").isJsonObject()
                    ? json.getAsJsonObject("answers") : new JsonObject();

            Quiz quiz = quizDAO.findByIdWithQuestions(quizId);
            if (quiz == null || quiz.getQuestions().isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("{\"ok\":false,\"error\":\"Không tìm thấy bài kiểm tra.\"}");
                return;
            }
            if (!user.isAdmin() && !enrollmentDAO.isEnrolled(user.getId(), quiz.getCourseId())) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.getWriter().write("{\"ok\":false,\"error\":\"Bạn chưa đăng ký khóa học này.\"}");
                return;
            }

            int correctCount = 0;
            int total = quiz.getQuestions().size();
            JsonArray details = new JsonArray();

            for (QuizQuestion q : quiz.getQuestions()) {
                String key = String.valueOf(q.getId());
                String chosen = answers.has(key) && !answers.get(key).isJsonNull()
                        ? answers.get(key).getAsString().trim().toUpperCase() : "";
                boolean isCorrect = q.getCorrectOption().equalsIgnoreCase(chosen);
                if (isCorrect) correctCount++;

                JsonObject item = new JsonObject();
                item.addProperty("questionId", q.getId());
                item.addProperty("chosen", chosen);
                item.addProperty("correctOption", q.getCorrectOption());
                item.addProperty("correct", isCorrect);
                item.addProperty("explanation", q.getExplanation() == null ? "" : q.getExplanation());
                details.add(item);
            }

            int scorePercent = Math.round((correctCount * 100f) / total);
            boolean passed = scorePercent >= quiz.getPassScore();
            quizDAO.recordAttempt(quizId, user.getId(), scorePercent, correctCount, total, passed);

            JsonObject out = new JsonObject();
            out.addProperty("ok", true);
            out.addProperty("scorePercent", scorePercent);
            out.addProperty("correctCount", correctCount);
            out.addProperty("totalQuestions", total);
            out.addProperty("passScore", quiz.getPassScore());
            out.addProperty("passed", passed);
            out.add("details", details);
            resp.getWriter().write(out.toString());
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"ok\":false,\"error\":\"Không thể chấm bài kiểm tra lúc này.\"}");
        }
    }
}
