package com.onlineexam.servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.onlineexam.util.DBConnection;

public class SubmitExamServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        int examId = (Integer) session.getAttribute("examId");

        int score = 0;

        try {
            Connection con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(
                "SELECT question_id, correct_option FROM questions WHERE exam_id = ?"
            );
            ps.setInt(1, examId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                int qid = rs.getInt("question_id");
                String correct = rs.getString("correct_option");

                String userAnswer = request.getParameter("q" + qid);

                if (userAnswer != null && userAnswer.equals(correct)) {
                    score++;
                }
            }

            con.close();

            request.setAttribute("score", score);
            RequestDispatcher rd = request.getRequestDispatcher("result.jsp");
            rd.forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
