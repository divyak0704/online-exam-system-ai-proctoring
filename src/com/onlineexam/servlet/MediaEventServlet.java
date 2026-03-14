package com.onlineexam.servlet;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.onlineexam.util.DBConnection;

@WebServlet("/api/media-event")
public class MediaEventServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection con = null;
        PreparedStatement ps = null;

        try {
            /* =====================
               DAY 9 – READ REQUEST
               ===================== */
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;

            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }

            JSONObject json = new JSONObject(sb.toString());

            String studentId = json.getString("student_id");
            String examId = json.getString("exam_id");
            boolean facePresent = json.getBoolean("face_present");
            boolean multipleFaces = json.getBoolean("multiple_faces");
            boolean noiseDetected = json.getBoolean("noise_detected");
            String noiseLevel = json.getString("noise_level");
            String timestamp = json.getString("timestamp");

            /* =====================
               DAY 9 – STORE IN DB
               ===================== */
            con = DBConnection.getConnection();

            String sql = "INSERT INTO media_events "
                       + "(student_id, exam_id, face_present, multiple_faces, "
                       + "noise_detected, noise_level, event_time) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setString(1, studentId);
            ps.setString(2, examId);
            ps.setBoolean(3, facePresent);
            ps.setBoolean(4, multipleFaces);
            ps.setBoolean(5, noiseDetected);
            ps.setString(6, noiseLevel);

            String ts = json.getString("timestamp").replace("T", " ");
            ps.setTimestamp(7, Timestamp.valueOf(ts));


            ps.executeUpdate();

            /* =====================
               DAY 10 – CALL AI (FLASK)
               ===================== */
            URL url = new URL("http://127.0.0.1:5000/analyze");
            HttpURLConnection aiCon = (HttpURLConnection) url.openConnection();

            aiCon.setRequestMethod("POST");
            aiCon.setRequestProperty("Content-Type", "application/json");
            aiCon.setDoOutput(true);

            // Send ONLY required features to AI
            JSONObject aiRequest = new JSONObject();
            aiRequest.put("face_present", facePresent);
            aiRequest.put("noise_detected", noiseDetected);

            OutputStream os = aiCon.getOutputStream();
            os.write(aiRequest.toString().getBytes());
            os.flush();
            os.close();

            // Read AI response
            BufferedReader aiReader = new BufferedReader(
                    new InputStreamReader(aiCon.getInputStream())
            );

            StringBuilder aiResponse = new StringBuilder();
            String aiLine;

            while ((aiLine = aiReader.readLine()) != null) {
                aiResponse.append(aiLine);
            }
            aiReader.close();

            System.out.println("AI Response: " + aiResponse.toString());

            /* =====================
               FINAL RESPONSE
               ===================== */
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();

            JSONObject finalResponse = new JSONObject();
            finalResponse.put("status", "stored");
            finalResponse.put("ai_decision", new JSONObject(aiResponse.toString()));

            out.print(finalResponse.toString());
            out.flush();

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            response.getWriter().print("{\"status\":\"error\"}");

        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception ignored) {}
        }
    }
}
