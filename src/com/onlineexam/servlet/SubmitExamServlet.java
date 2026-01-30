package com.onlineexam.servlet;

import com.onlineexam.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.Enumeration;

public class SubmitExamServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if(session == null || session.getAttribute("userId") == null){
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        int examId = Integer.parseInt(request.getParameter("examId"));

        int score = 0;
        int totalQuestions = 0;

        try (Connection con = DBConnection.getConnection()) {

            // Count total questions
            PreparedStatement countPs = con.prepareStatement(
                "SELECT COUNT(*) FROM questions WHERE exam_id=?"
            );
            countPs.setInt(1, examId);
            ResultSet countRs = countPs.executeQuery();
            if(countRs.next()){
                totalQuestions = countRs.getInt(1);
            }

            // Check answers
            Enumeration<String> paramNames = request.getParameterNames();
            while(paramNames.hasMoreElements()){
                String param = paramNames.nextElement();
                if(param.startsWith("q")){
                    int questionId = Integer.parseInt(param.substring(1));
                    String selectedOption = request.getParameter(param);

                    PreparedStatement ps = con.prepareStatement(
                        "SELECT correct_option FROM questions WHERE question_id=?"
                    );
                    ps.setInt(1, questionId);
                    ResultSet rs = ps.executeQuery();
                    if(rs.next()){
                        String correct = rs.getString("correct_option");
                        if(correct.equalsIgnoreCase(selectedOption)){
                            score++;
                        }
                    }
                }
            }

            // Save result
            PreparedStatement insert = con.prepareStatement(
                "INSERT INTO results (user_id, exam_id, score, total_questions) VALUES (?, ?, ?, ?)"
            );
            insert.setInt(1, userId);
            insert.setInt(2, examId);
            insert.setInt(3, score);
            insert.setInt(4, totalQuestions);
            insert.executeUpdate();

        } catch(Exception e){
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
        }

        request.setAttribute("score", score);
        request.setAttribute("totalQuestions", totalQuestions);
        RequestDispatcher rd = request.getRequestDispatcher("result.jsp");
        rd.forward(request, response);
    }
}
