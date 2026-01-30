package com.onlineexam.servlet;

import com.onlineexam.util.DBConnection;
import org.json.JSONObject;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class ProctoringLogServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        int examId = (Integer) session.getAttribute("examId");

        StringBuilder jsonBuffer = new StringBuilder();
        BufferedReader reader = request.getReader();
        String line;

        while ((line = reader.readLine()) != null) {
            jsonBuffer.append(line);
        }

        try {
            JSONObject json = new JSONObject(jsonBuffer.toString());
            String eventType = json.getString("event_type");

            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO proctoring_logs (user_id, exam_id, event_type) VALUES (?, ?, ?)"
            );

            ps.setInt(1, userId);
            ps.setInt(2, examId);
            ps.setString(3, eventType);

            ps.executeUpdate();

            ps.close();
            con.close();

            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
