<%@ page session="true" %>

<%
if (session.getAttribute("username") == null ||
    !"student".equalsIgnoreCase((String) session.getAttribute("role"))) {

    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Student Home</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body>

<nav class="navbar navbar-dark bg-dark">
<div class="container-fluid">
<span class="navbar-brand">Online Exam System</span>

<a href="<%= request.getContextPath() %>/LogoutServlet" class="btn btn-danger">
Logout
</a>
</div>
</nav>

<div class="container mt-5">

<h3>Welcome, <%= session.getAttribute("username") %> (Student)</h3>

<a href="studentDashboard.jsp" class="btn btn-primary mt-3">
View Available Exams
</a>

</div>

</body>
</html>