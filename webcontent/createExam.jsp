<form action="<%=request.getContextPath()%>/CreateExamServlet" method="post">
    Exam Title: <input type="text" name="title" required><br><br>
    Duration (minutes): <input type="number" name="duration" required><br><br>
    Rules:<br>
    <textarea name="rules"></textarea><br><br>
    <input type="submit" value="Create Exam">
</form>
