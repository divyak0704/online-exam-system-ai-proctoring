package com.onlineexam.servlet;

import com.onlineexam.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class AddQuestionServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int examId = Integer.parseInt(request.getParameter("examId"));
            String question = request.getParameter("question");
            String a = request.getParameter("a");
            String b = request.getParameter("b");
            String c = request.getParameter("c");
            String d = request.getParameter("d");
            String correct = request.getParameter("correct");

            try (Connection conn = DBConnection.getConnection()) {
                String sql = "INSERT INTO questions (exam_id, question_text, option_a, option_b, option_c, option_d, correct_option) VALUES (?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, examId);
                ps.setString(2, question);
                ps.setString(3, a);
                ps.setString(4, b);
                ps.setString(5, c);
                ps.setString(6, d);
                ps.setString(7, correct);
                ps.executeUpdate();
            }

            // Redirect back to same page to add next question
            response.sendRedirect(request.getContextPath() + "/addQuestions.jsp?examId=" + examId);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/facultyHome.jsp");
        }
    }
}
