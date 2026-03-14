<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.onlineexam.util.DBConnection" %>
<%@ page import="org.json.JSONArray, org.json.JSONObject" %>
<%@ page session="true" %>

<%
    String username = (String) session.getAttribute("username");
    String role     = (String) session.getAttribute("role");
    if(username == null || role == null || !role.equalsIgnoreCase("faculty")){ response.sendRedirect("login.jsp"); return; }
    
    // Fallbacks if attributes are missing
    String logsJsonStr = (String) request.getAttribute("logsJson");
    if(logsJsonStr == null) logsJsonStr = "[]";
    String shotsJsonStr = (String) request.getAttribute("screenshotsJson");
    if(shotsJsonStr == null) shotsJsonStr = "[]";

    JSONArray logs = new JSONArray(logsJsonStr);
    JSONArray shots = new JSONArray(shotsJsonStr);

    int total = logs.length();
    int cFace=0, cMulti=0, cHead=0, cEye=0, cObj=0, cAudio=0, cTab=0, cWin=0;
    for(int i=0; i<total; i++){
        String type = logs.getJSONObject(i).optString("event_type", "");
        if(type.equals("FACE_MISSING")) cFace++;
        if(type.equals("MULTIPLE_FACES")) cMulti++;
        if(type.equals("HEAD_MOVEMENT")) cHead++;
        if(type.equals("EYE_GAZE")) cEye++;
        if(type.equals("OBJECT_DETECTED")) cObj++;
        if(type.equals("AUDIO_NOISE")) cAudio++;
        if(type.equals("TAB_SWITCH")) cTab++;
        if(type.equals("WINDOW_SWITCH")) cWin++;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Proctoring Telemetry · AI System</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">

<style>
:root {
  --bg-dark: #09090b; --surface-base: #18181b; --surface-alt: #27272a; --surface-float: rgba(255,255,255,0.03);
  --border-light: rgba(255, 255, 255, 0.08); --border-strong: rgba(255,255,255,0.15);
  --accent-1: #6366f1; --accent-2: #8b5cf6;
  --success: #10b981; --warn: #f59e0b; --danger: #ef4444; 
  --text-main: #f8fafc; --text-muted: #a1a1aa;
  --radius-xl: 20px; --radius-lg: 12px; --radius-sm: 8px;
}

* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg-dark); color: var(--text-main); min-height: 100vh; }
::-webkit-scrollbar { width: 8px; height: 8px; }
::-webkit-scrollbar-track { background: var(--bg-dark); }
::-webkit-scrollbar-thumb { background: var(--border-strong); border-radius: 4px; }

/* Sticky Header */
.nav-bar {
  position: sticky; top: 0; z-index: 100;
  background: rgba(9, 9, 11, 0.85); backdrop-filter: blur(24px); -webkit-backdrop-filter: blur(24px);
  border-bottom: 1px solid var(--border-light);
  display: flex; align-items: center; justify-content: space-between; padding: 16px 32px;
}
.brand { display: flex; align-items: center; gap: 10px; font-weight: 700; font-size: 18px; color: #fff; letter-spacing: -0.5px; }
.brand svg { color: var(--accent-1); }
.nav-actions { display: flex; align-items: center; gap: 16px; font-size: 14px; }
.btn-outline { border: 1px solid var(--border-strong); background: transparent; color: var(--text-main); padding: 8px 16px; border-radius: 8px; text-decoration: none; font-weight: 600; transition: all 0.2s; }
.btn-outline:hover { background: var(--surface-float); border-color: var(--text-muted); }
.refresh-counter { color: var(--accent-1); font-weight: 600; background: rgba(99,102,241,0.1); padding: 6px 16px; border-radius: 50px; display:flex; gap:6px; align-items:center; }
.refresh-counter .dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; box-shadow: 0 0 8px currentColor; animation: blink 1s infinite alternate; }
@keyframes blink { to { opacity: 0.3; } }

/* Main Layout */
.dashboard { padding: 32px; max-width: 1600px; margin: 0 auto; display: flex; flex-direction: column; gap: 32px; }
.section-title { font-size: 20px; font-weight: 700; display: flex; align-items: center; gap: 8px; margin-bottom: 20px; }
.section-title span { color: var(--text-muted); font-weight: 500; font-size: 15px; }

/* Stats Grid */
.stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; }
.stat-card {
  background: var(--surface-base); border: 1px solid var(--border-light); border-radius: var(--radius-lg);
  padding: 20px; position: relative; overflow: hidden;
}
.stat-card::after { content:''; position:absolute; top:0; left:0; width:4px; height:100%; border-radius: 4px 0 0 4px; }
.stat-card[data-color="indigo"]::after { background: var(--accent-1); }
.stat-card[data-color="rose"]::after { background: var(--danger); }
.stat-card[data-color="amber"]::after { background: var(--warn); }
.stat-card[data-color="emerald"]::after { background: var(--success); }

.sc-num { font-size: 32px; font-weight: 800; line-height: 1; margin-bottom: 8px; }
.sc-label { font-size: 12px; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; }

/* Toolkit Bar */
.toolkit { display: flex; gap: 16px; margin-bottom: 16px; }
.search-box {
  flex: 1; position: relative; max-width: 320px;
}
.search-box svg { position: absolute; left: 16px; top: 12px; color: var(--text-muted); }
.search-box input {
  width: 100%; background: var(--surface-base); border: 1px solid var(--border-strong);
  color: #fff; font-family: inherit; font-size: 14px; padding: 12px 16px 12px 48px;
  border-radius: var(--radius-sm); outline: none; transition: border-color 0.2s;
}
.search-box input:focus { border-color: var(--accent-1); }
.filter-select {
  background: var(--surface-base); border: 1px solid var(--border-strong);
  color: #fff; font-family: inherit; font-size: 14px; padding: 0 16px;
  border-radius: var(--radius-sm); outline: none; cursor: pointer;
}

/* Data Table */
.table-wrap {
  background: var(--surface-base); border: 1px solid var(--border-light);
  border-radius: var(--radius-lg); overflow: hidden;
}
.data-table { width: 100%; border-collapse: collapse; text-align: left; }
.data-table th { background: rgba(255,255,255,0.02); font-size: 12px; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; padding: 16px 20px; border-bottom: 1px solid var(--border-light); }
.data-table td { padding: 16px 20px; border-bottom: 1px solid var(--border-light); font-size: 14px; color: var(--text-main); }
.data-table tr:last-child td { border-bottom: none; }
.data-table tbody tr:hover { background: rgba(255,255,255,0.02); }

.tag { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700; letter-spacing: 0.5px; text-transform: uppercase; }
.tag.high { background: rgba(239, 68, 68, 0.15); color: #fca5a5; }
.tag.med { background: rgba(245, 158, 11, 0.15); color: #fcd34d; }
.tag.low { background: rgba(52, 211, 153, 0.15); color: #6ee7b7; }
.tag.info { background: rgba(99, 102, 241, 0.15); color: #a5b4fc; }

.subtext { font-size: 12px; color: var(--text-muted); display: block; margin-top: 4px; }
.empty-msg { text-align: center; padding: 64px 24px; color: var(--text-muted); }

/* Gallery */
.gallery-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; }
.shot-card { background: var(--surface-base); border: 1px solid var(--border-light); border-radius: var(--radius-lg); overflow: hidden; position: relative; }
.shot-card img { width: 100%; height: 180px; object-fit: cover; display: block; transition: transform 0.3s; }
.shot-card:hover img { transform: scale(1.05); }
.shot-meta { position: absolute; bottom: 0; left: 0; width: 100%; background: linear-gradient(to top, rgba(0,0,0,0.9), transparent); padding: 32px 16px 12px; }
.shot-meta .st-name { font-size: 14px; font-weight: 600; color: #fff; }
.shot-meta .st-time { font-size: 12px; color: #a1a1aa; display: flex; align-items: center; gap: 4px; margin-top: 4px; }
</style>
</head>

<body>
<header class="nav-bar">
  <div class="brand">
    <svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.956 11.956 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path></svg>
    Proctoring Telemetry Let
  </div>
  <div class="nav-actions">
    <div class="refresh-counter">
      <div class="dot"></div> Live Sync in <span id="countdown">5</span>s
    </div>
    <a href="facultyHome.jsp" class="btn-outline">Exit Console</a>
  </div>
</header>

<main class="dashboard">
  
  <section>
    <div class="section-title">Global Telemetry <span>(Active Sessions)</span></div>
    <div class="stat-grid">
      <div class="stat-card" data-color="indigo">
        <div class="sc-num"><%= total %></div>
        <div class="sc-label">Total Events Logs</div>
      </div>
      <div class="stat-card" data-color="rose">
        <div class="sc-num"><%= cFace %></div>
        <div class="sc-label">Missing Face Flags</div>
      </div>
      <div class="stat-card" data-color="amber">
        <div class="sc-num"><%= cMulti %></div>
        <div class="sc-label">Multi-Face Alerts</div>
      </div>
      <div class="stat-card" data-color="emerald">
        <div class="sc-num"><%= shots.length() %></div>
        <div class="sc-label">Snapshots Archived</div>
      </div>
      <div class="stat-card" data-color="rose">
        <div class="sc-num"><%= cObj %></div>
        <div class="sc-label">Illegal Objects</div>
      </div>
      <div class="stat-card" data-color="amber">
        <div class="sc-num"><%= cTab + cWin %></div>
        <div class="sc-label">Browser Exits</div>
      </div>
    </div>
  </section>

  <section>
    <div class="section-title">Anomaly Ledger</div>
    <div class="toolkit">
      <div class="search-box">
        <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
        <input type="text" id="searchInput" placeholder="Search candidate or exam..." onkeyup="filterTable()">
      </div>
      <select id="riskFilter" class="filter-select" onchange="filterTable()">
        <option value="ALL">All Threat Levels</option>
        <option value="CRITICAL">Critical (Face/Object)</option>
        <option value="WARNING">Warning (Head/Eye/Audio)</option>
        <option value="INFO">Info (Tab Switch)</option>
      </select>
    </div>

    <div class="table-wrap">
      <table class="data-table" id="logTable">
        <thead>
          <tr>
            <th>Timestamp</th>
            <th>Candidate Context</th>
            <th>Vector / AI Engine</th>
            <th>Confidence / Object</th>
            <th>Gaze & Posture Metrics</th>
            <th>Severity</th>
          </tr>
        </thead>
        <tbody>
<%
    if(total == 0){ out.println("<tr><td colspan='6'><div class='empty-msg'>No telemetry signals recorded in this session.</div></td></tr>"); }
    for(int i=0; i<total; i++){
        JSONObject row = logs.getJSONObject(i);
        String eType = row.optString("event_type", "");
        String label = row.optString("ai_label", "N/A");
        double conf = row.optDouble("confidence", 0.0);
        String head = row.optString("head_pose", "-");
        String eye = row.optString("eye_gaze", "-");
        String obj = row.optString("object_detected", "-");
        
        String risk="info"; String riskText="INFO";
        if(eType.equals("FACE_MISSING") || eType.equals("MULTIPLE_FACES") || eType.equals("OBJECT_DETECTED")){ risk="high"; riskText="CRITICAL"; }
        else if(eType.equals("HEAD_MOVEMENT") || eType.equals("EYE_GAZE") || eType.equals("AUDIO_NOISE")){ risk="med"; riskText="WARNING"; }
%>
          <tr>
            <td style="color:var(--text-muted); font-size:13px; font-variant-numeric: tabular-nums;"><%= row.optString("event_timestamp").replace(".0","") %></td>
            <td>
              <strong style="color:#fff;"><%= row.optString("username", "Unknown") %></strong>
              <span class="subtext">Module: <%= row.optString("title", "Exam " + row.optInt("exam_id")) %></span>
            </td>
            <td>
              <span style="font-weight:600;"><%= eType.replace("_", " ") %></span>
              <span class="subtext">Engine: <%= label %></span>
            </td>
            <td>
              <%= eType.equals("OBJECT_DETECTED") ? obj : String.format("%.1f %%", conf) %>
            </td>
            <td>
              <span style="font-size:12px;">Head: <span style="color:#fff"><%= head %></span></span><br>
              <span style="font-size:12px; color:var(--text-muted);">Iris: <span style="color:#fff"><%= eye %></span></span>
            </td>
            <td><span class="tag <%= risk %>"><%= riskText %></span></td>
          </tr>
<%  } %>
        </tbody>
      </table>
    </div>
  </section>

  <section>
    <div class="section-title">Photographic Evidence Vault</div>
    <% if(shots.length() == 0){ out.println("<div class='empty-msg' style='border:1px dashed var(--border-light); border-radius:12px;'>No snapshots have been archived yet.</div>"); } else { %>
    <div class="gallery-grid">
      <% for(int i=0; i<shots.length(); i++){
           JSONObject s = shots.getJSONObject(i);
      %>
      <div class="shot-card">
        <a href="<%= request.getContextPath() %>/<%= s.optString("screenshot_path").replace("\\","/") %>" target="_blank">
          <img src="<%= request.getContextPath() %>/<%= s.optString("screenshot_path").replace("\\","/") %>" alt="Snapshot" loading="lazy">
        </a>
        <div class="shot-meta">
          <div class="st-name"><%= s.optString("username", "Unknown") %></div>
          <div class="st-time">
            <svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
            <%= s.optString("capture_time").replace(".0","") %>
          </div>
        </div>
      </div>
      <% } %>
    </div>
    <% } %>
  </section>
</main>

<script>
let count = 5; const ce = document.getElementById('countdown');
setInterval(() => { count--; ce.textContent = count; if(count <= 0) location.reload(); }, 1000);

function filterTable(){
  const searchVal = document.getElementById('searchInput').value.toLowerCase();
  const riskVal = document.getElementById('riskFilter').value;
  const rows = document.getElementById('logTable').getElementsByTagName('tbody')[0].getElementsByTagName('tr');
  for(let i=0; i<rows.length; i++){
    if(rows[i].getElementsByTagName('td').length < 2) continue; // skip empty msg
    const text = rows[i].innerText.toLowerCase();
    const riskBadges = rows[i].getElementsByClassName('tag');
    let riskMatch = true;
    if(riskVal !== 'ALL' && riskBadges.length > 0){
        const rowRisk = riskBadges[0].innerText.toUpperCase();
        if(rowRisk !== riskVal) riskMatch = false;
    }
    rows[i].style.display = (text.indexOf(searchVal) > -1 && riskMatch) ? '' : 'none';
  }
}
</script>
</body>
</html>