<%@ page import="java.sql.*" %>
<%@ page import="com.onlineexam.util.DBConnection" %>
<%@ page session="true" %>

<%
Integer userId = (Integer) session.getAttribute("userId");
String username = (String) session.getAttribute("username");
if(userId == null){
    response.sendRedirect("login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Dashboard · AI Proctor System</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">

<style>
:root {
  --bg-dark: #09090b;
  --surface-base: #18181b;
  --surface-layer: rgba(255, 255, 255, 0.03);
  --border-light: rgba(255, 255, 255, 0.08);
  --accent-1: #6366f1;
  --accent-2: #8b5cf6;
  --danger: #ef4444;
  --text-main: #f8fafc;
  --text-muted: #94a3b8;
  --radius-lg: 16px;
  --shadow-glow: 0 12px 32px rgba(99, 102, 241, 0.15);
}

* { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: 'Plus Jakarta Sans', sans-serif;
  background: var(--bg-dark);
  color: var(--text-main);
  min-height: 100vh;
  position: relative;
  overflow-x: hidden;
}

/* Ambient glow */
.ambient-glow {
  position: absolute; width: 600px; height: 600px;
  background: radial-gradient(circle, rgba(99,102,241,0.15) 0%, transparent 60%);
  top: -200px; left: -100px; pointer-events: none; z-index: 0;
}

/* Header Navbar */
.nav-header {
  position: sticky; top: 0; z-index: 50;
  background: rgba(9, 9, 11, 0.8);
  backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--border-light);
  padding: 16px 40px;
  display: flex; align-items: center; justify-content: space-between;
}
.brand {
  font-size: 18px; font-weight: 700; display: flex; align-items: center; gap: 8px;
  background: linear-gradient(to right, #fff, #a5b4fc);
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
}
.brand-icon { filter: drop-shadow(0 0 8px var(--accent-1)); }
.nav-actions { display: flex; align-items: center; gap: 16px; }
.user-pill {
  background: var(--surface-layer); border: 1px solid var(--border-light);
  padding: 6px 16px; border-radius: 50px; font-size: 13px; font-weight: 500;
}
.btn-logout {
  background: rgba(239, 68, 68, 0.1); color: #fca5a5;
  border: 1px solid rgba(239, 68, 68, 0.2); border-radius: 8px;
  padding: 6px 16px; font-size: 13px; font-weight: 600; text-decoration: none;
  transition: all 0.2s;
}
.btn-logout:hover { background: rgba(239, 68, 68, 0.2); }

/* Main Content */
.container { max-width: 1100px; margin: 0 auto; padding: 56px 24px; position: relative; z-index: 10; }
.page-header { margin-bottom: 40px; }
.page-title { font-size: 32px; font-weight: 700; margin-bottom: 8px; letter-spacing: -0.5px; }
.page-subtitle { font-size: 15px; color: var(--text-muted); }

/* Consent Banner */
.consent-banner {
  background: linear-gradient(to right, rgba(99,102,241,0.1), rgba(139,92,246,0.05));
  border: 1px solid rgba(99,102,241,0.2);
  border-radius: var(--radius-lg); padding: 16px 24px;
  display: flex; align-items: flex-start; gap: 16px; margin-bottom: 48px;
  box-shadow: inset 0 0 20px rgba(255,255,255,0.02);
}
.consent-banner svg { color: var(--accent-1); width: 24px; height: 24px; flex-shrink: 0; }
.consent-text { font-size: 14px; line-height: 1.6; color: var(--text-muted); }
.consent-text strong { color: var(--text-main); font-weight: 600; }

/* Exam Grid */
.exam-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 24px; }
.exam-card {
  background: var(--surface-base); border: 1px solid var(--border-light);
  border-radius: var(--radius-lg); padding: 28px;
  display: flex; flex-direction: column; position: relative; overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
.exam-card::before {
  content: ''; position: absolute; left: 0; top: 0; width: 100%; height: 100%;
  background: linear-gradient(135deg, rgba(255,255,255,0.03) 0%, transparent 100%); pointer-events: none;
}
.exam-card:hover { transform: translateY(-4px); border-color: rgba(99,102,241,0.4); box-shadow: var(--shadow-glow); }

.card-badge {
  display: inline-flex; align-items: center; gap: 6px;
  background: rgba(34, 197, 94, 0.1); color: #4ade80;
  border: 1px solid rgba(34, 197, 94, 0.2);
  padding: 4px 12px; border-radius: 50px; font-size: 11px; font-weight: 700; letter-spacing: 0.5px;
  width: fit-content; margin-bottom: 16px;
}
.card-badge .dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; box-shadow: 0 0 8px currentColor; }
.exam-title { font-size: 20px; font-weight: 700; margin-bottom: 8px; line-height: 1.3; }
.exam-meta {
  display: flex; align-items: center; gap: 8px; font-size: 14px; color: var(--text-muted);
  margin-bottom: 32px; flex: 1;
}

.btn-start {
  display: block; width: 100%; text-align: center;
  background: var(--surface-layer); border: 1px solid var(--border-light);
  padding: 12px 20px; border-radius: 10px; color: var(--text-main); font-size: 14px; font-weight: 600; text-decoration: none;
  transition: all 0.2s; position: relative; overflow: hidden;
}
.btn-start:hover {
  background: var(--text-main); color: var(--bg-dark);
  box-shadow: 0 0 20px rgba(255,255,255,0.2);
}

.empty-state {
  grid-column: 1 / -1; text-align: center; padding: 80px 20px;
  border: 1px dashed var(--border-light); border-radius: var(--radius-lg); color: var(--text-muted);
}
</style>
</head>

<body>
<div class="ambient-glow"></div>

<header class="nav-header">
  <div class="brand"><span class="brand-icon">🛡️</span> AI Proctor System</div>
  <div class="nav-actions">
    <div class="user-pill">@<%= username %></div>
    <a href="LogoutServlet" class="btn-logout">Sign Out</a>
  </div>
</header>

<main class="container">
  <div class="page-header">
    <h1 class="page-title">Candidate Dashboard</h1>
    <p class="page-subtitle">Select an available assessment to commence your proctored session.</p>
  </div>

  <div class="consent-banner">
    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
    <div class="consent-text">
       <strong>Consent to AI Monitoring:</strong> Selecting "Launch Proctoring" will activate your device's webcam and microphone to establish a secure examination environment.
    </div>
  </div>

  <div class="exam-grid">
<%
try (Connection con = DBConnection.getConnection();
     PreparedStatement ps = con.prepareStatement("SELECT exam_id, title, duration FROM exams WHERE status='PUBLISHED'");
     ResultSet rs = ps.executeQuery()) {

    boolean hasExams = false;
    while(rs.next()){
        hasExams = true;
%>
    <div class="exam-card">
      <div class="card-badge"><div class="dot"></div>ACTIVE</div>
      <h3 class="exam-title"><%= rs.getString("title") %></h3>
      <div class="exam-meta">
        <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        Time Limit: <%= rs.getInt("duration") %> Minutes
      </div>
      <a href="StartExamServlet?examId=<%= rs.getInt("exam_id") %>" class="btn-start">
        Launch Proctoring →
      </a>
    </div>
<%  }
    if(!hasExams){ %>
    <div class="empty-state">
      <svg width="48" height="48" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="margin:0 auto 16px; opacity:0.5"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path></svg>
      <div>No pending assessments at this time </div>
    </div>
<%  }
} catch(Exception e){ out.println("<div class='empty-state'>Error loading exams</div>"); }
%>
  </div>
</main>
</body>
</html>