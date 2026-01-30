package com.onlineexam.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.onlineexam.util.DBConnection;

@WebServlet("/LogViolationServlet")
public class LogViolationServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        Integer userId = (Integer) session.getAttribute("userId");
        Integer examId = (Integer) session.getAttribute("examId");
        String eventType = request.getParameter("eventType");

        if (userId == null || examId == null || eventType == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "INSERT INTO proctoring_logs (user_id, exam_id, event_type, event_time) VALUES (?, ?, ?, NOW())"
             )) {

            ps.setInt(1, userId);
            ps.setInt(2, examId);
            ps.setString(3, eventType);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
