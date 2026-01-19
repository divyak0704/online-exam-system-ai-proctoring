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
    <title>Student Dashboard</title>
</head>
<body>

<h2>Welcome, <%= session.getAttribute("username") %> (Student)</h2>

<p>
    <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
</p>

</body>
</html>
