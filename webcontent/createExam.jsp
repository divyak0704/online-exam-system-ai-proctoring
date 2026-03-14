<!DOCTYPE html>
<html>
<head>

<title>Create Exam</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

</head>

<body>

<div class="container mt-5">

<div class="card">

<div class="card-header bg-primary text-white">
Create Exam
</div>

<div class="card-body">

<form action="<%=request.getContextPath()%>/CreateExamServlet" method="post">

<div class="mb-3">
<label>Exam Title</label>
<input class="form-control" type="text" name="title" required>
</div>

<div class="mb-3">
<label>Duration (minutes)</label>
<input class="form-control" type="number" name="duration" required>
</div>

<div class="mb-3">
<label>Rules</label>
<textarea class="form-control" name="rules"></textarea>
</div>

<button class="btn btn-success">Create Exam</button>

</form>

</div>
</div>

</div>

</body>
</html>