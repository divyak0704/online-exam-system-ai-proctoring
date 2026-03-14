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

        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        Integer examId = (Integer) session.getAttribute("examId");
        String eventType     = request.getParameter("eventType");
        String headPose      = request.getParameter("head_pose");
        String eyeGaze       = request.getParameter("eye_gaze");
        String objectDetected= request.getParameter("object_detected");

        if (userId == null || examId == null || eventType == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // Derive AI label and confidence from event type
        String aiLabel;
        double confidence;
        switch (eventType) {
            case "FACE_MISSING":        aiLabel = "no_face";          confidence = 0.95; break;
            case "MULTIPLE_FACES":      aiLabel = "multiple_faces";   confidence = 0.93; break;
            case "HEAD_MOVEMENT":       aiLabel = "head_turned";      confidence = 0.88; break;
            case "EYE_GAZE":            aiLabel = "gaze_away";        confidence = 0.85; break;
            case "OBJECT_DETECTED":     aiLabel = "object_found";     confidence = 0.92; break;
            case "AUDIO_NOISE":         aiLabel = "noise_detected";   confidence = 0.87; break;
            case "TAB_SWITCH":
            case "WINDOW_SWITCH":       aiLabel = "tab_switch";       confidence = 0.99; break;
            case "SCREENSHOT":          aiLabel = "screenshot";       confidence = 1.00; break;
            default:                    aiLabel = "suspicious";       confidence = 0.90; break;
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO proctoring_logs " +
                 "(user_id, exam_id, event_type, event_time, ai_result, confidence, head_pose, eye_gaze, object_detected) " +
                 "VALUES (?, ?, ?, NOW(), ?, ?, ?, ?, ?)"
             )) {

            ps.setInt(1, userId);
            ps.setInt(2, examId);
            ps.setString(3, eventType);
            ps.setString(4, aiLabel);
            ps.setDouble(5, confidence);
            ps.setString(6, headPose);
            ps.setString(7, eyeGaze);
            ps.setString(8, objectDetected);

            ps.executeUpdate();

            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}

