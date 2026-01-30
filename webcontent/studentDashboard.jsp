<%@ page import="java.sql.*" %>
<%@ page import="com.onlineexam.util.DBConnection" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if(userId == null){
        response.sendRedirect("login.jsp");
        return;
    }
%>

<h2>Available Exams</h2>
<table border="1">
<tr>
    <th>Exam Name</th>
    <th>Duration (minutes)</th>
    <th>Action</th>
</tr>

<%
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT exam_id, title, duration FROM exams WHERE status='PUBLISHED'"
         );
         ResultSet rs = ps.executeQuery()) {

        while(rs.next()){
%>
<tr>
    <td><%= rs.getString("title") %></td>
    <td><%= rs.getInt("duration") %></td>
    <td>
        <a href="StartExamServlet?examId=<%= rs.getInt("exam_id") %>">Start Exam</a>
    </td>
</tr>
<%
        }
    } catch(Exception e){
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    }
%>
</table>
