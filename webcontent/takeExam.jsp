<%@ page import="java.sql.*" %>
<%@ page import="com.onlineexam.util.DBConnection" %>

<html>
<head>
    <title>Take Exam</title>
</head>
<body>

<h2>Exam Started</h2>

<form action="SubmitExamServlet" method="post">
<input type="hidden" name="exam_id" value="<%= session.getAttribute("examId") %>">

<%
    int examId = (Integer) session.getAttribute("examId");

    Connection con = DBConnection.getConnection();
    PreparedStatement ps = con.prepareStatement(
        "SELECT * FROM questions WHERE exam_id = ?"
    );
    ps.setInt(1, examId);

    ResultSet rs = ps.executeQuery();
    int qno = 1;

    while (rs.next()) {
%>

<p>
<b>Q<%= qno++ %>. <%= rs.getString("question_text") %></b>
</p>

<input type="radio" name="q<%= rs.getInt("question_id") %>" value="A">
<%= rs.getString("option_a") %><br>

<input type="radio" name="q<%= rs.getInt("question_id") %>" value="B">
<%= rs.getString("option_b") %><br>

<input type="radio" name="q<%= rs.getInt("question_id") %>" value="C">
<%= rs.getString("option_c") %><br>

<input type="radio" name="q<%= rs.getInt("question_id") %>" value="D">
<%= rs.getString("option_d") %><br><br>

<%
    }
    con.close();
%>

<input type="submit" value="Submit Exam">
</form>

</body>
</html>
