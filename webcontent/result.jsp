<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.onlineexam.util.DBConnection" %>
<%@ page session="true" %>

<%
Integer userId = (Integer) session.getAttribute("userId");
if(userId == null){ response.sendRedirect("login.jsp"); return; }

Integer score          = (Integer) request.getAttribute("score");
Integer totalQuestions = (Integer) request.getAttribute("totalQuestions");
int sc = score != null ? score : 0;
int tq = totalQuestions != null ? totalQuestions : 0;
int pct = tq > 0 ? (sc * 100 / tq) : 0;

int examId = 0; Integer examIdObj = (Integer) session.getAttribute("examId");
if(examIdObj != null) examId = examIdObj;

int violations = 0;
if(examId > 0){
    try(Connection _c = DBConnection.getConnection();
        PreparedStatement _p = _c.prepareStatement("SELECT COUNT(*) FROM proctoring_logs WHERE user_id=? AND exam_id=?")){
        _p.setInt(1, userId); _p.setInt(2, examId);
        ResultSet _r = _p.executeQuery();
        if(_r.next()) violations = _r.getInt(1);
    } catch(Exception _e){}
}

String grade, gradeColor, gradeBg;
if(pct >= 90){ grade = "A+"; gradeColor = "#10b981"; gradeBg = "rgba(16, 185, 129, 0.1)"; }
else if(pct >= 75){ grade = "A";  gradeColor = "#34d399"; gradeBg = "rgba(52, 211, 153, 0.1)"; }
else if(pct >= 60){ grade = "B";  gradeColor = "#6366f1"; gradeBg = "rgba(99, 102, 241, 0.1)"; }
else if(pct >= 45){ grade = "C";  gradeColor = "#f59e0b"; gradeBg = "rgba(245, 158, 11, 0.1)"; }
else { grade = "F";  gradeColor = "#ef4444"; gradeBg = "rgba(239, 68, 68, 0.1)"; }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Assessment Result · AI Proctor System</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

<style>
:root {
  --bg-dark: #09090b; --surface-base: #18181b; --border-light: rgba(255, 255, 255, 0.08);
  --accent-1: #6366f1; --accent-2: #a855f7; --text-main: #f8fafc; --text-muted: #94a3b8;
  --radius-xl: 32px; --radius-md: 16px;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg-dark); color: var(--text-main);
  min-height: 100vh; display: flex; flex-direction: column; align-items: center; justify-content: center;
  padding: 32px 16px; position: relative; overflow: hidden;
}
.mesh-bg { position: absolute; top:0; left:0; width:100%; height:100%; z-index:0; }
.mesh-bg::before { content:''; position:absolute; top:-20%; left:-10%; width:70vw; height:70vw; background:<%=gradeColor%>; border-radius:50%; filter:blur(140px); opacity:0.1; }

.result-card {
  position: relative; z-index: 10;
  background: var(--surface-base); border: 1px solid var(--border-light);
  border-radius: var(--radius-xl); padding: 56px 48px;
  max-width: 540px; width: 100%; text-align: center;
  box-shadow: 0 32px 64px rgba(0,0,0,0.5), inset 0 0 0 1px rgba(255,255,255,0.02);
  animation: slideUp 0.6s cubic-bezier(0.16,1,0.3,1) forwards; opacity: 0; transform: translateY(40px);
}
@keyframes slideUp { to { opacity:1; transform:translateY(0); } }

.icon-wrapper {
  width: 80px; height: 80px; margin: 0 auto 24px;
  background: <%= gradeBg %>; color: <%= gradeColor %>;
  border-radius: 24px; display: flex; align-items: center; justify-content: center; font-size: 32px;
  box-shadow: 0 12px 32px <%= gradeBg.replace("0.1","0.3") %>;
}
.title-main { font-size: 28px; font-weight: 800; letter-spacing: -0.5px; margin-bottom: 8px; }
.subtitle { color: var(--text-muted); font-size: 15px; margin-bottom: 40px; line-height: 1.5; }

/* Score Ring */
.score-circle {
  width: 180px; height: 180px; border-radius: 50%; margin: 0 auto 32px;
  background: conic-gradient(<%= gradeColor %> <%= pct %>%, #27272a 0);
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 0 48px <%= gradeBg.replace("0.1","0.4") %>; position: relative;
}
.score-circle::before {
  content: ''; position: absolute; inset: 6px; border-radius: 50%;
  background: var(--surface-base); z-index: 1;
}
.score-content { position: relative; z-index: 2; display: flex; flex-direction: column; align-items: center; }
.score-value { font-size: 48px; font-weight: 800; color: <%= gradeColor %>; line-height: 1; letter-spacing: -1px; }
.score-label { font-size: 14px; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 1px; margin-top: 4px; }

/* Grid Stats */
.stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 40px; }
.stat-box { background: rgba(255,255,255,0.02); border: 1px solid var(--border-light); border-radius: var(--radius-md); padding: 20px 16px; }
.sb-label { font-size: 11px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px; }
.sb-val { font-size: 24px; font-weight: 700; }

.grade-pill { display: inline-flex; align-items: center; justify-content: center; background: <%= gradeBg %>; color: <%= gradeColor %>; padding: 6px 20px; border-radius: 50px; font-size: 18px; font-weight: 800; border: 1px solid <%= gradeColor %>; margin-bottom: 32px; }

/* Buttons */
.action-group { display: flex; flex-direction: column; gap: 12px; }
.btn { width: 100%; padding: 16px; border-radius: 12px; font-size: 15px; font-weight: 600; text-decoration: none; text-align: center; transition: all 0.2s; }
.btn-primary { background: var(--text-main); color: var(--bg-dark); }
.btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(255,255,255,0.2); }
.btn-secondary { background: rgba(255,255,255,0.05); color: var(--text-main); border: 1px solid var(--border-light); }
.btn-secondary:hover { background: rgba(255,255,255,0.1); }
</style>
</head>

<body>
<div class="mesh-bg"></div>

<main class="result-card">
  <div class="icon-wrapper">
    <% if(pct >= 60){ %><svg width="32" height="32" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg><% } else { %><svg width="32" height="32" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg><% } %>
  </div>
  
  <h1 class="title-main">Assessment Concluded</h1>
  <p class="subtitle">Your AI-proctored session data has been securely logged and analyzed.</p>

  <div class="score-circle">
    <div class="score-content">
      <div class="score-value"><%= pct %>%</div>
      <div class="score-label">Final Score</div>
    </div>
  </div>

  <div class="grade-pill">Grade: <%= grade %></div>

  <div class="stats-grid">
    <div class="stat-box">
      <div class="sb-label">Correct</div>
      <div class="sb-val" style="color:<%= gradeColor %>"><%= sc %></div>
    </div>
    <div class="stat-box">
      <div class="sb-label">Total</div>
      <div class="sb-val"><%= tq %></div>
    </div>
    <div class="stat-box">
      <div class="sb-label">Flags</div>
      <div class="sb-val" style="color:<%= violations > 0 ? "#ef4444" : "#10b981" %>"><%= violations %></div>
    </div>
  </div>

  <div class="action-group">
    <a href="studentDashboard.jsp" class="btn btn-primary">Return to Dashboard</a>
    <a href="LogoutServlet" class="btn btn-secondary">End Session</a>
  </div>
</main>
</body>
</html>