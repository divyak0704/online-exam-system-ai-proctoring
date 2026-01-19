<%@ page session="true" %>
<%
    if(session.getAttribute("username") == null || !"faculty".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<html>
<head>
    <title>Faculty Dashboard</title>
</head>
<body>

<h2>Welcome, <%= session.getAttribute("username") %> (Faculty)</h2>

<ul>
    <li><a href="<%=request.getContextPath()%>/createExam.jsp">Create New Exam</a></li>
    <li><a href="<%=request.getContextPath()%>/ViewExamsServlet">View My Exams</a></li>
    <li><a href="<%=request.getContextPath()%>/LogoutServlet">Logout</a></li>
</ul>

</body>
</html>
