<%@ page import="java.sql.*" %>
<%@ page import="com.onlineexam.util.DBConnection" %>

<h2>Available Exams</h2>

<table border="1">
<tr>
    <th>Exam Name</th>
    <th>Duration</th>
    <th>Action</th>
</tr>

<%
Connection con = DBConnection.getConnection();
PreparedStatement ps =con.prepareStatement(
        "SELECT exam_id, title, duration FROM exams WHERE status='PUBLISHED'"
    );
ResultSet rs = ps.executeQuery();

while(rs.next()){
%>
<tr>
    <td><%=rs.getString("title")%></td>
    <td><%=rs.getInt("duration")%> minutes</td>
    <td>
        <a href="StartExamServlet?examId=<%=rs.getInt("exam_id")%>">
            Start Exam
        </a>
    </td>
</tr>
<%
}
%>
</table>
