<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    if(userId == null){
        response.sendRedirect("login.jsp");
        return;
    }

    Integer score = (Integer) request.getAttribute("score");
    Integer totalQuestions = (Integer) request.getAttribute("totalQuestions");
%>

<h2>Exam Completed</h2>

<p>Score: <b><%= (score != null ? score : 0) %> / <%= (totalQuestions != null ? totalQuestions : 0) %></b></p>

<a href="studentDashboard.jsp">Back to Dashboard</a>
