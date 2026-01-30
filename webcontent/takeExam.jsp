<%@ page import="java.sql.*" %>
<%@ page import="com.onlineexam.util.DBConnection" %>
<%@ page session="true" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    Integer examIdObj = (Integer) session.getAttribute("examId");

    if (userId == null || examIdObj == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int examId = examIdObj;
%>

<!DOCTYPE html>
<html>
<head>
    <title>Take Exam</title>
</head>

<body>

<h2>Exam Started</h2>

<form action="SubmitExamServlet" method="post">

<input type="hidden" name="examId" value="<%= examId %>">

<%
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT question_id, question_text, option_a, option_b, option_c, option_d FROM questions WHERE exam_id=?"
         )) {

        ps.setInt(1, examId);
        ResultSet rs = ps.executeQuery();

        int qno = 1;
        while (rs.next()) {
%>

    <p><b>Q<%= qno++ %>. <%= rs.getString("question_text") %></b></p>

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
    } catch (Exception e) {
        out.println("Error loading questions");
        e.printStackTrace();
    }
%>

<br>
<input type="submit" value="Submit Exam">

</form>

<!-- ===================== -->
<!-- PROCTORING SCRIPT -->
<!-- ===================== -->

<script>
    let tabSwitchCount = 0;

    document.addEventListener("visibilitychange", function () {
        if (document.hidden) {
            tabSwitchCount++;
            sendViolation("TAB_SWITCH");

            if (tabSwitchCount >= 3) {
                alert("Multiple tab switches detected. Exam will be submitted.");
                document.forms[0].submit();
            }
        }
    });

    window.addEventListener("blur", function () {
        sendViolation("WINDOW_BLUR");
    });

    function sendViolation(type) {
        fetch("LogViolationServlet", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: "eventType=" + type
        });
    }
</script>

</body>
</html>


