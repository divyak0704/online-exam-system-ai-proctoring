<form action="<%=request.getContextPath()%>/AddQuestionServlet" method="post">
    <input type="hidden" name="examId" value="<%=request.getParameter("examId")%>">

    Question:<br>
    <textarea name="question"></textarea><br>

    A: <input name="a"><br>
    B: <input name="b"><br>
    C: <input name="c"><br>
    D: <input name="d"><br>

    Correct Option:
    <select name="correct">
        <option>A</option><option>B</option>
        <option>C</option><option>D</option>
    </select><br><br>

    <input type="submit" value="Add Question">
</form>
<form action="<%=request.getContextPath()%>/PublishExamServlet" method="post">
    <input type="hidden" name="examId" value="<%=request.getParameter("examId")%>">
    <input type="submit" value="Publish Exam">
</form>
