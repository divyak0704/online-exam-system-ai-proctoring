package com.onlineexam.servlet;

import com.onlineexam.util.DBConnection;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {

            con = DBConnection.getConnection();

            String query = "SELECT user_id, role FROM users WHERE username=? AND password=?";
            ps = con.prepareStatement(query);

            ps.setString(1, username);
            ps.setString(2, password);

            rs = ps.executeQuery();

            if (rs.next()) {

                int userId = rs.getInt("user_id");
                String role = rs.getString("role");

                // Create session
                HttpSession session = request.getSession(true);
                session.setAttribute("userId", userId);
                session.setAttribute("username", username);
                session.setAttribute("role", role);

                // Redirect based on role
                if (role != null && role.equalsIgnoreCase("faculty")) {

                    response.sendRedirect(request.getContextPath() + "/facultyHome.jsp");

                } 
                else if (role != null && role.equalsIgnoreCase("student")) {

                    response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp");

                } 
                else {

                    response.sendRedirect(request.getContextPath() + "/login.jsp");

                }

            } 
            else {

                request.setAttribute("error", "Invalid Username or Password");
                RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                rd.forward(request, response);

            }

        } 
        catch (Exception e) {

            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login.jsp");

        } 
        finally {

            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}

        }
    }
}