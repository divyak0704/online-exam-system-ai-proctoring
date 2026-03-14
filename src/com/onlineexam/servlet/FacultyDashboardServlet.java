package com.onlineexam.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.onlineexam.util.DBConnection;

@WebServlet("/FacultyDashboard")
public class FacultyDashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"faculty".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        // ── Proctoring logs (all 9 columns: user_id, exam_id, event_type, ai_result,
        //    confidence, event_time, head_pose, eye_gaze, object_detected) ──
        ArrayList<String[]> logs = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT pl.user_id, u.username, pl.exam_id, e.title, " +
                 "pl.event_type, pl.ai_result, pl.confidence, pl.event_time, " +
                 "COALESCE(pl.head_pose,'–') AS head_pose, " +
                 "COALESCE(pl.eye_gaze,'–') AS eye_gaze, " +
                 "COALESCE(pl.object_detected,'–') AS object_detected " +
                 "FROM proctoring_logs pl " +
                 "LEFT JOIN users u ON pl.user_id = u.user_id " +
                 "LEFT JOIN exams e ON pl.exam_id = e.exam_id " +
                 "ORDER BY pl.event_time DESC LIMIT 500"
             );
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String[] row = new String[11];
                row[0]  = rs.getString("user_id");
                row[1]  = rs.getString("username");
                row[2]  = rs.getString("exam_id");
                row[3]  = rs.getString("title");
                row[4]  = rs.getString("event_type");
                row[5]  = rs.getString("ai_result");
                row[6]  = rs.getString("confidence");
                row[7]  = rs.getString("event_time");
                row[8]  = rs.getString("head_pose");
                row[9]  = rs.getString("eye_gaze");
                row[10] = rs.getString("object_detected");
                logs.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // ── Screenshot records ──
        ArrayList<String[]> screenshots = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT s.user_id, u.username, s.exam_id, e.title, " +
                 "s.screenshot_path, s.captured_at " +
                 "FROM exam_screenshots s " +
                 "LEFT JOIN users u ON s.user_id = u.user_id " +
                 "LEFT JOIN exams e ON s.exam_id = e.exam_id " +
                 "ORDER BY s.captured_at DESC LIMIT 200"
             );
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String[] row = new String[6];
                row[0] = rs.getString("user_id");
                row[1] = rs.getString("username");
                row[2] = rs.getString("exam_id");
                row[3] = rs.getString("title");
                row[4] = rs.getString("screenshot_path");
                row[5] = rs.getString("captured_at");
                screenshots.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("logs", logs);
        request.setAttribute("screenshots", screenshots);
        request.getRequestDispatcher("faculty_dashboard.jsp").forward(request, response);
    }
}
