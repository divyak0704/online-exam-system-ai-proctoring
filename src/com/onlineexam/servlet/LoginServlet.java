package com.onlineexam.servlet;

import com.onlineexam.util.DBConnection;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Read username and password from login form
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // 🔹 Debug: check what values the servlet is receiving
        System.out.println("DEBUG: Username from form: " + username + ", Password: " + password);

        try (Connection conn = DBConnection.getConnection()) {

            String sql = "SELECT * FROM users WHERE username=? AND password=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            // 🔹 Debug: check if ResultSet returned a row
            boolean userExists = rs.next();
            System.out.println("DEBUG: ResultSet has next? " + userExists);

            if (userExists) {
                // Get user info
                int userId = rs.getInt("user_id");
                String dbUsername = rs.getString("username");
                String role = rs.getString("role");

                // 🔹 Debug: print user info retrieved from DB
                System.out.println("DEBUG: User ID: " + userId + ", Username: " + dbUsername + ", Role: " + role);

                // Set session attributes
                HttpSession session = request.getSession();
                session.setAttribute("userId", userId);
                session.setAttribute("username", dbUsername);
                session.setAttribute("role", role);

                // Redirect based on role
                if ("student".equalsIgnoreCase(role)) {
                    response.sendRedirect(request.getContextPath() + "/studentHome.jsp");
                } else if ("faculty".equalsIgnoreCase(role)) {
                    response.sendRedirect(request.getContextPath() + "/facultyHome.jsp");
                } else {
                    response.sendRedirect(request.getContextPath() + "/login.jsp");
                }

            } else {
                // Login failed: forward back to login page with error
                request.setAttribute("usernameValue", username);
                request.setAttribute("error", "Invalid username or password");
                RequestDispatcher rd = request.getRequestDispatcher("/login.jsp");
                rd.forward(request, response);
            }

        } catch (Exception e) {
            // 🔹 Debug: print any exceptions to console
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to login page
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
}

