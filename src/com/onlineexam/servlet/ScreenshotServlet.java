package com.onlineexam.servlet;

import com.onlineexam.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.*;
import java.sql.*;
import java.util.Base64;

/**
 * ScreenshotServlet  – receives a webcam snapshot from the exam page
 * (base64-encoded PNG), saves it to the server's screenshot directory,
 * and records the file path in the exam_screenshots table.
 *
 * POST body params:
 *   screenshot  – base64 PNG data URI  (data:image/png;base64,…)
 *   examId      – exam being monitored  (also read from session)
 */
@WebServlet("/ScreenshotServlet")
public class ScreenshotServlet extends HttpServlet {

    /** Where screenshots are saved on the server file-system */
    private static final String SCREENSHOT_DIR = "screenshots";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"status\":\"unauthorized\"}");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        int examId = (Integer) session.getAttribute("examId");

        String dataUri = request.getParameter("screenshot");
        if (dataUri == null || !dataUri.startsWith("data:image")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"bad_request\"}");
            return;
        }

        try {
            // Strip the data-URI prefix: "data:image/png;base64,..."
            String base64Data = dataUri.split(",", 2)[1];
            byte[] imgBytes   = Base64.getDecoder().decode(base64Data);

            // Resolve save directory relative to the web application root
            String realPath  = getServletContext().getRealPath("/") + SCREENSHOT_DIR;
            Path   saveDir   = Paths.get(realPath);
            Files.createDirectories(saveDir);

            String filename = "user" + userId + "_exam" + examId + "_" + System.currentTimeMillis() + ".png";
            Path   filePath = saveDir.resolve(filename);
            Files.write(filePath, imgBytes);

            // Relative web path for storage (served back via faculty dashboard)
            String webPath = SCREENSHOT_DIR + "/" + filename;

            // Persist to DB
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "INSERT INTO exam_screenshots (user_id, exam_id, screenshot_path) VALUES (?, ?, ?)"
                 )) {
                ps.setInt(1, userId);
                ps.setInt(2, examId);
                ps.setString(3, webPath);
                ps.executeUpdate();
            }

            out.print("{\"status\":\"saved\",\"path\":\"" + webPath + "\"}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"status\":\"error\",\"msg\":\"" + e.getMessage() + "\"}");
        }
    }
}