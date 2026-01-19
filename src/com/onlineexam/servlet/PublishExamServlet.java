package com.onlineexam.servlet;

import com.onlineexam.util.DBConnection;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class PublishExamServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int examId = Integer.parseInt(request.getParameter("examId"));

            try (Connection conn = DBConnection.getConnection()) {
                String sql = "UPDATE exams SET status='PUBLISHED' WHERE exam_id=?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, examId);
                ps.executeUpdate();
            }

            // Redirect back to faculty dashboard
            response.sendRedirect(request.getContextPath() + "/facultyHome.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/facultyHome.jsp");
        }
    }
}
