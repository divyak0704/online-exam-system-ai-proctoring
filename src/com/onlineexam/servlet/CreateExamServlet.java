package com.onlineexam.servlet;

import com.onlineexam.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class CreateExamServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if(session == null || !"faculty".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String title = request.getParameter("title");
        int duration = Integer.parseInt(request.getParameter("duration"));
        String rules = request.getParameter("rules");
        int facultyId = (int) session.getAttribute("userId");

        try (Connection conn = DBConnection.getConnection()) {

            String sql = "INSERT INTO exams (title, duration, rules, created_by) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

            ps.setString(1, title);
            ps.setInt(2, duration);
            ps.setString(3, rules);
            ps.setInt(4, facultyId);

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if(rs.next()) {
                int examId = rs.getInt(1);
                response.sendRedirect(request.getContextPath() +
                        "/addQuestions.jsp?examId=" + examId);
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/facultyHome.jsp");
        }
    }
}
