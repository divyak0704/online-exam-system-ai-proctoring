<!DOCTYPE html>
<html>
<head>

<title>Add Question</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

</head>

<body>

<div class="container mt-5">

<div class="card">

<div class="card-header bg-dark text-white">
Add Question
</div>

<div class="card-body">

<form action="<%=request.getContextPath()%>/AddQuestionServlet" method="post">

<input type="hidden" name="examId"
value="<%=request.getParameter("examId")%>">

<div class="mb-3">
<label>Question</label>
<textarea class="form-control" name="question"></textarea>
</div>

<div class="row">

<div class="col-md-6 mb-3">
<label>Option A</label>
<input class="form-control" name="a">
</div>

<div class="col-md-6 mb-3">
<label>Option B</label>
<input class="form-control" name="b">
</div>

<div class="col-md-6 mb-3">
<label>Option C</label>
<input class="form-control" name="c">
</div>

<div class="col-md-6 mb-3">
<label>Option D</label>
<input class="form-control" name="d">
</div>

</div>

<div class="mb-3">
<label>Correct Option</label>

<select class="form-control" name="correct">
<option>A</option>
<option>B</option>
<option>C</option>
<option>D</option>
</select>

</div>

<button class="btn btn-primary">
Add Question
</button>

</form>

<hr>

<form action="<%=request.getContextPath()%>/PublishExamServlet" method="post">

<input type="hidden" name="examId"
value="<%=request.getParameter("examId")%>">

<button class="btn btn-success">
Publish Exam
</button>

</form>

</div>
</div>

</div>

</body>
</html>