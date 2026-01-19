package com.onlineexam.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class StartExamServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get examId from URL
        int examId = Integer.parseInt(request.getParameter("examId"));

        // Store examId in session
        HttpSession session = request.getSession();
        session.setAttribute("examId", examId);

        // Redirect to exam page
        response.sendRedirect(request.getContextPath() + "/takeExam.jsp");
    }
}
