package com.onlineexam.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class StartExamServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false); // Don't create new session

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int examId = Integer.parseInt(request.getParameter("examId"));
            session.setAttribute("examId", examId);

            response.sendRedirect(request.getContextPath() + "/takeExam.jsp");
        } catch(NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp");
        }
    }
}
