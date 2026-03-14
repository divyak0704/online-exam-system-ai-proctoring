<%@ page session="true" %>

<%
    String username = (String) session.getAttribute("username");
    String role     = (String) session.getAttribute("role");

    if (username == null || role == null || !role.equalsIgnoreCase("faculty")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Faculty Portal · AI Proctor</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

<style>
:root {
  --bg-dark: #09090b; --surface-base: #18181b; --surface-layer: rgba(255, 255, 255, 0.03);
  --border-light: rgba(255, 255, 255, 0.08); 
  --accent-1: #6366f1; --accent-2: #8b5cf6; --accent-3: #ec4899;
  --text-main: #f8fafc; --text-muted: #94a3b8; 
  --radius-xl: 24px; --radius-lg: 16px;
}

* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg-dark); color: var(--text-main); min-height: 100vh; position:relative; overflow-x:hidden;}

/* Animated mesh */
.mesh { position: absolute; inset: 0; z-index: 0; pointer-events: none; overflow: hidden; opacity: 0.15; }
.mesh::before, .mesh::after { content: ''; position: absolute; border-radius: 50%; filter: blur(100px); }
.mesh::before { top: 0; right: 20%; width: 40vw; height: 40vw; background: var(--accent-1); animation: float1 10s infinite alternate; }
.mesh::after { bottom: 0; left: 10%; width: 50vw; height: 50vw; background: var(--accent-2); animation: float2 14s infinite alternate; }
@keyframes float1 { to { transform: translate(50px, 50px); } }
@keyframes float2 { to { transform: translate(-50px, -50px); } }

/* Header */
.header { position: sticky; top: 0; z-index: 50; background: rgba(9, 9, 11, 0.8); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); border-bottom: 1px solid var(--border-light); padding: 20px 48px; display: flex; align-items: center; justify-content: space-between; }
.brand { display: flex; align-items: center; gap: 12px; font-size: 20px; font-weight: 800; letter-spacing: -0.5px; background: linear-gradient(to right, #fff, #a5b4fc); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
.meta { display: flex; align-items: center; gap: 16px; }
.chip { background: var(--surface-layer); border: 1px solid var(--border-light); padding: 8px 20px; border-radius: 50px; font-size: 14px; font-weight: 600; color: var(--text-muted); }
.btn-out { background: rgba(239, 68, 68, 0.08); color: #fca5a5; border: 1px solid rgba(239, 68, 68, 0.2); padding: 8px 24px; border-radius: 12px; font-size: 14px; font-weight: 600; text-decoration: none; transition: all 0.2s; }
.btn-out:hover { background: rgba(239, 68, 68, 0.15); }

/* Main */
.wrapper { max-width: 1024px; margin: 0 auto; padding: 64px 24px; position: relative; z-index: 10; }
.welcome { font-size: 36px; font-weight: 800; letter-spacing: -1px; margin-bottom: 12px; }
.sub { font-size: 16px; color: var(--text-muted); margin-bottom: 56px; line-height: 1.6; max-width: 600px; }

/* Grid */
.grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; }
.card { background: var(--surface-base); border: 1px solid var(--border-light); border-radius: var(--radius-xl); padding: 32px; display: flex; flex-direction: column; position: relative; overflow: hidden; transition: all 0.3s cubic-bezier(0.4,0,0.2,1); }
.card::before { content: ''; position: absolute; inset: 0; background: linear-gradient(135deg, rgba(255,255,255,0.03), transparent); pointer-events: none; }
.card:hover { transform: translateY(-8px); border-color: rgba(99,102,241,0.3); box-shadow: 0 24px 48px rgba(0,0,0,0.4), 0 0 0 1px rgba(99,102,241,0.1) inset; }

.ic-box { width: 56px; height: 56px; border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 24px; margin-bottom: 24px; }
.c1 .ic-box { background: rgba(99,102,241,0.1); color: #818cf8; box-shadow: inset 0 0 0 1px rgba(99,102,241,0.2); }
.c2 .ic-box { background: rgba(16,185,129,0.1); color: #34d399; box-shadow: inset 0 0 0 1px rgba(16,185,129,0.2); }
.c3 .ic-box { background: rgba(168,85,247,0.1); color: #c084fc; box-shadow: inset 0 0 0 1px rgba(168,85,247,0.2); }

.card h3 { font-size: 20px; font-weight: 700; margin-bottom: 12px; letter-spacing: -0.5px; }
.card p { font-size: 14px; color: var(--text-muted); line-height: 1.6; margin-bottom: 32px; flex: 1; }

.btn { display: inline-block; width: 100%; text-align: center; padding: 14px 24px; border-radius: 14px; text-decoration: none; font-size: 15px; font-weight: 600; transition: all 0.2s; position: relative; overflow: hidden; }
.btn::after { content: ''; position: absolute; top:0; left:-100%; width:50%; height:100%; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent); transform: skewX(-20deg); transition: left 0.5s; }
.card:hover .btn::after { left: 200%; }

.c1 .btn { background: var(--accent-1); color: #fff; box-shadow: 0 8px 24px rgba(99,102,241,0.3); }
.c2 .btn { background: #10b981; color: #fff; box-shadow: 0 8px 24px rgba(16,185,129,0.3); }
.c3 .btn { background: var(--accent-2); color: #fff; box-shadow: 0 8px 24px rgba(168,85,247,0.3); }
.btn:hover { transform: translateY(-2px); opacity: 0.95; }
</style>
</head>

<body>
<div class="mesh"></div>

<header class="header">
  <div class="brand">
    <svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
    Faculty Command
  </div>
  <div class="meta">
    <div class="chip">Prof. <%= username %></div>
    <a class="btn-out" href="LogoutServlet">Sign Out</a>
  </div>
</header>

<main class="wrapper">
  <h1 class="welcome">Administrative Portal</h1>
  <p class="sub">Oversee active assessments, provision new examination modules, and seamlessly review AI-driven proctoring telemetry logs.</p>

  <div class="grid">
    <div class="card c1">
      <div class="ic-box"><svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4"></path></svg></div>
      <h3>Provision Exam</h3>
      <p>Configure a secure assessment module by defining title, duration envelopes, and publication cadence.</p>
      <a class="btn" href="createExam.jsp">Create Module</a>
    </div>

    <div class="card c2">
      <div class="ic-box"><svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"></path></svg></div>
      <h3>Ingest Questions</h3>
      <p>Load encrypted metric-choice questionnaires and define standardized evaluation criteria.</p>
      <a class="btn" href="addQuestions.jsp">Deploy Questions</a>
    </div>

    <div class="card c3">
      <div class="ic-box"><svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg></div>
      <h3>Proctoring Console</h3>
      <p>Access live telemetry streams, AI violation ledgers, and photographic evidence for all active cohorts.</p>
      <a class="btn" href="FacultyDashboard">Launch Console</a>
    </div>
  </div>
</main>
</body>
</html>