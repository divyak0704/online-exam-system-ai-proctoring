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
String username = (String) session.getAttribute("username");

// Load exam duration from DB
int durationMinutes = 30;
try (Connection _con = DBConnection.getConnection();
     PreparedStatement _ps = _con.prepareStatement("SELECT duration FROM exams WHERE exam_id=?")) {
    _ps.setInt(1, examId);
    ResultSet _rs = _ps.executeQuery();
    if (_rs.next()) durationMinutes = _rs.getInt("duration");
} catch (Exception _e) { /* use default */ }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Assessment Session · AI Proctor</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">

<!-- TensorFlow.js + COCO-SSD -->
<script defer src="https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@4.2.0/dist/tf.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/@tensorflow-models/coco-ssd@2.2.2/dist/coco-ssd.min.js"></script>

<style>
:root {
  --bg-dark: #09090b; --surface-base: #121214; --surface-layer: rgba(255, 255, 255, 0.05);
  --border-light: rgba(255, 255, 255, 0.1); --border-focus: rgba(99, 102, 241, 0.5);
  --accent-1: #6366f1; --accent-2: #8b5cf6;
  --success: #10b981; --warn: #f59e0b; --danger: #ef4444; --magenta: #d946ef;
  --text-main: #f8fafc; --text-muted: #94a3b8;
  --radius-lg: 16px; --radius-xl: 24px;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
html, body {
  width: 100%;
  min-height: 100%;
}
body {
  font-family: 'Plus Jakarta Sans', sans-serif;
  background: var(--bg-dark);
  color: var(--text-main);
  min-height: 100vh;
  overflow-x: hidden;
  overflow-y: auto;
}
body.fullscreen-enforced {
  overflow-y: auto !important;
  overflow-x: hidden !important;
}

/* Sticky Header */
.exam-header {
  position: sticky; top: 0; z-index: 100;
  background: rgba(9, 9, 11, 0.85); backdrop-filter: blur(24px); -webkit-backdrop-filter: blur(24px);
  border-bottom: 1px solid var(--border-light);
  display: flex; align-items: center; justify-content: space-between;
  padding: 16px 32px;
}
.brand { display: flex; align-items: center; gap: 10px; font-weight: 700; font-size: 18px; color: #fff; }
.brand svg { color: var(--accent-1); }

/* HUD Meta Bar */
.hud-meta { display: flex; align-items: center; gap: 16px; }
.hud-pill {
  display: flex; align-items: center; gap: 8px;
  background: var(--surface-base); border: 1px solid var(--border-light);
  padding: 8px 16px; border-radius: 50px; font-size: 14px; font-weight: 600;
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.2);
}
.hud-warns { border-color: rgba(245, 158, 11, 0.3); color: var(--warn); }
.hud-warns .pulsing-dot { background: var(--warn); box-shadow: 0 0 12px var(--warn); }
.hud-timer { border-color: rgba(239, 68, 68, 0.4); background: rgba(239, 68, 68, 0.1); color: #fca5a5; }

/* Hardware Status Track */
.status-track {
  background: var(--surface-base); border-bottom: 1px solid var(--border-light);
  padding: 12px 32px; display: flex; gap: 12px; flex-wrap: wrap; align-items: center;
  box-shadow: 0 4px 12px rgba(0,0,0,0.2);
}
.status-badge {
  display: inline-flex; align-items: center; gap: 6px;
  background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.1);
  padding: 6px 14px; border-radius: 50px; font-size: 11px; font-weight: 700;
  letter-spacing: 0.5px; text-transform: uppercase; transition: all 0.3s;
}
.status-badge.ok { background: rgba(16, 185, 129, 0.1); border-color: rgba(16, 185, 129, 0.2); color: #34d399; }
.status-badge.bad { background: rgba(239, 68, 68, 0.1); border-color: rgba(239, 68, 68, 0.3); color: #f87171; animation: pulseRed 2s infinite; }
.status-badge.off { color: var(--text-muted); opacity: 0.5; }
.dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
@keyframes pulseRed { 0%,100%{box-shadow:0 0 0 rgba(239,68,68,0)} 50%{box-shadow:0 0 12px rgba(239,68,68,0.5)} }

/* Video Frame PIP */
.cam-frame {
  position: fixed; bottom: 32px; right: 32px; width: 240px; aspect-ratio: 4/3;
  background: #000; border-radius: var(--radius-lg); overflow: hidden;
  box-shadow: 0 24px 48px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.1);
  z-index: 900; transition: transform 0.3s;
}
.cam-frame:hover { transform: scale(1.03); box-shadow: 0 0 0 2px var(--accent-1); }
.cam-frame video { width: 100%; height: 100%; object-fit: cover; transform: scaleX(-1); }
.cam-frame canvas { position: absolute; top:0; left:0; width:100%; height:100%; z-index: 2; pointer-events:none; }
.cam-label {
  position: absolute; bottom: 0; left: 0; width: 100%; z-index: 3;
  background: linear-gradient(to top, rgba(0,0,0,0.8), transparent);
  color: #fff; font-size: 10px; font-weight: 700; text-align: center; padding: 12px 0 6px;
  letter-spacing: 1px;
}
.recording-indicator {
  position: absolute; top: 12px; right: 12px; z-index: 3;
  width: 8px; height: 8px; border-radius: 50%; background: var(--danger);
  box-shadow: 0 0 8px var(--danger); animation: blink 1s infinite alternate;
}
@keyframes blink { from{opacity:1;} to{opacity:0.3;} }

/* UI Toast */
#toast-container {
  position: fixed; top: 88px; left: 50%; transform: translateX(-50%);
  z-index: 2000; display: flex; flex-direction: column; gap: 8px;
}
.toast {
  background: rgba(18, 18, 20, 0.95); border: 1px solid var(--danger); border-left: 4px solid var(--danger);
  color: #fff; padding: 14px 20px; border-radius: 8px; font-size: 14px; font-weight: 500;
  box-shadow: 0 12px 32px rgba(0,0,0,0.5);
  animation: toastIn 0.3s cubic-bezier(0.16,1,0.3,1) forwards;
  max-width: 420px;
}
@keyframes toastIn { from{opacity:0;transform:translateY(-10px) scale(0.95);} to{opacity:1;transform:translateY(0) scale(1);} }

/* Content Area */
.main-content {
  max-width: 840px;
  margin: 0 auto;
  padding: 48px 24px 120px;
  position: relative;
  z-index: 10;
}
.exam-title {
  font-size: 24px; font-weight: 700; margin-bottom: 32px;
  background: linear-gradient(to right, #fff, var(--text-muted));
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
}

/* Questions */
.question-block {
  background: var(--surface-base); border: 1px solid var(--border-light);
  border-radius: var(--radius-xl); padding: 32px; margin-bottom: 24px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.2); transition: border-color 0.3s;
}
.question-block:focus-within { border-color: var(--border-focus); }
.q-meta { color: var(--accent-1); font-size: 12px; font-weight: 700; letter-spacing: 1px; margin-bottom: 12px; }
.q-text { font-size: 18px; font-weight: 500; line-height: 1.5; margin-bottom: 24px; }

.option-btn {
  display: flex; align-items: flex-start; gap: 16px;
  padding: 16px 20px; margin-bottom: 12px;
  background: var(--surface-layer); border: 1px solid var(--border-light);
  border-radius: 12px; cursor: pointer; transition: all 0.2s ease;
}
.option-btn:hover { background: rgba(255,255,255,0.08); border-color: rgba(255,255,255,0.2); }
.option-btn:has(input:checked) {
  background: rgba(99, 102, 241, 0.08); border-color: var(--accent-1);
  box-shadow: inset 0 0 0 1px var(--accent-1);
}
.option-btn input[type="radio"] {
  appearance: none; width: 20px; height: 20px; border: 2px solid var(--text-muted); border-radius: 50%;
  margin-top: 2px; position: relative; flex-shrink: 0; outline: none; transition: border-color 0.2s;
}
.option-btn:has(input:checked) input { border-color: var(--accent-1); }
.option-btn input:checked::after {
  content: ''; position: absolute; top: 4px; left: 4px; width: 8px; height: 8px;
  border-radius: 50%; background: var(--accent-1);
}
.option-label { font-size: 15px; line-height: 1.5; color: var(--text-main); font-weight: 400; }

/* Submit Button */
.btn-submit {
  width: 100%; display: block; margin-top: 48px;
  background: linear-gradient(135deg, var(--accent-1), var(--accent-2)); color: #fff;
  border: none; padding: 20px; border-radius: 16px; font-size: 16px; font-weight: 700;
  cursor: pointer; position: relative; overflow: hidden;
  box-shadow: 0 12px 32px rgba(99, 102, 241, 0.3); transition: transform 0.2s;
}
.btn-submit:hover { transform: translateY(-2px); box-shadow: 0 16px 40px rgba(99, 102, 241, 0.4); }
.btn-submit::after {
  content: ''; position: absolute; top: 0; left: -100%; width: 50%; height: 100%;
  background: linear-gradient(to right, transparent, rgba(255,255,255,0.2), transparent);
  transform: skewX(-20deg); animation: shine 3s infinite;
}
@keyframes shine {
  0% { left: -100%; }
  100% { left: 150%; }
}

/* Lockout Overlay */
#lockout-overlay {
  display: none; position: fixed; inset: 0; z-index: 9999;
  background: rgba(9, 9, 11, 0.95); backdrop-filter: blur(8px);
  justify-content: center; align-items: center; flex-direction: column; gap: 16px;
}
#lockout-overlay.show { display: flex; animation: fadeUp 0.3s forwards; }
#lockout-overlay h2 { color: var(--danger); font-size: 32px; font-weight: 700; }
#lockout-overlay p { color: var(--text-muted); font-size: 16px; }
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Fullscreen Overlay */
#fullscreen-overlay {
  display: none;
  position: fixed;
  inset: 0;
  z-index: 9998;
  background: rgba(9,9,11,0.96);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  justify-content: center;
  align-items: center;
  flex-direction: column;
  gap: 18px;
  text-align: center;
  padding: 24px;
}
#fullscreen-overlay h2 {
  color: var(--danger);
  font-size: 30px;
  font-weight: 700;
  margin: 0;
}
#fullscreen-overlay p {
  color: var(--text-muted);
  font-size: 16px;
  max-width: 520px;
  margin: 0;
}
#resumeFullscreenBtn {
  background: linear-gradient(135deg,#6366f1,#8b5cf6);
  color: #fff;
  border: none;
  padding: 14px 26px;
  border-radius: 14px;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 12px 28px rgba(99,102,241,0.35);
}
</style>
</head>

<body>

<!-- Fullscreen Enforcement Overlay -->
<div id="fullscreen-overlay">
  <svg width="70" height="70" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M8 3H5a2 2 0 0 0-2 2v3"></path>
    <path d="M16 3h3a2 2 0 0 1 2 2v3"></path>
    <path d="M8 21H5a2 2 0 0 1-2-2v-3"></path>
    <path d="M16 21h3a2 2 0 0 0 2-2v-3"></path>
    <path d="M9 9l6 6"></path>
    <path d="M15 9l-6 6"></path>
  </svg>
  <h2>Fullscreen Required</h2>
  <p>This assessment must remain in fullscreen mode. Please return to fullscreen immediately to continue.</p>
  <button id="resumeFullscreenBtn">Return to Fullscreen</button>
</div>

<div id="lockout-overlay">
  <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="var(--danger)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-bottom:16px">
    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
  </svg>
  <h2>Session Terminated</h2>
  <p>Maximum proctoring violations reached. Auto-submitting assessment...</p>
</div>

<div id="toast-container"></div>

<div class="cam-frame">
  <div class="recording-indicator"></div>
  <video id="camVideo" autoplay muted playsinline></video>
  <canvas id="camCanvas"></canvas>
  <div class="cam-label">AI ENGINE ACTIVE · REC</div>
</div>

<header class="exam-header">
  <div class="brand">
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
    </svg>
    Secure Assessment
  </div>
  <div class="hud-meta">
    <div class="hud-pill hud-warns">
      <div class="dot pulsing-dot"></div> Warnings: <span id="warningCount">0</span>/5
    </div>
    <div class="hud-pill hud-timer">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="12" cy="12" r="10"></circle>
        <polyline points="12 6 12 12 16 14"></polyline>
      </svg>
      <span id="timer">--:--</span>
    </div>
  </div>
</header>

<div class="status-track" id="statusBar">
  <div class="status-badge off" id="st-face"><div class="dot"></div>Face Presence</div>
  <div class="status-badge off" id="st-multi"><div class="dot"></div>Multi-Person</div>
  <div class="status-badge off" id="st-head"><div class="dot"></div>Head Track</div>
  <div class="status-badge off" id="st-eye"><div class="dot"></div>Gaze Track</div>
  <div class="status-badge off" id="st-obj"><div class="dot"></div>Objects</div>
  <div class="status-badge off" id="st-audio"><div class="dot"></div>Audio Env</div>
  <div class="status-badge off" id="st-tab"><div class="dot"></div>Browser Lock</div>
</div>

<main class="main-content">
  <div class="exam-title">Please complete the following inquiries:</div>

  <form id="examForm" action="SubmitExamServlet" method="post">
    <input type="hidden" name="examId" value="<%= examId %>">

<%
try (Connection con = DBConnection.getConnection();
     PreparedStatement ps = con.prepareStatement(
       "SELECT question_id, question_text, option_a, option_b, option_c, option_d FROM questions WHERE exam_id=?")) {
    ps.setInt(1, examId);
    ResultSet rs = ps.executeQuery();
    int qno = 1;
    while (rs.next()) {
        int qid = rs.getInt("question_id");
%>
    <div class="question-block">
      <div class="q-meta">QUESTION <%= (qno < 10 ? "0" + qno : qno) %></div>
      <div class="q-text"><%= rs.getString("question_text") %></div>

      <label class="option-btn">
        <input type="radio" name="q<%= qid %>" value="A">
        <span class="option-label"><%= rs.getString("option_a") %></span>
      </label>
      <label class="option-btn">
        <input type="radio" name="q<%= qid %>" value="B">
        <span class="option-label"><%= rs.getString("option_b") %></span>
      </label>
      <label class="option-btn">
        <input type="radio" name="q<%= qid %>" value="C">
        <span class="option-label"><%= rs.getString("option_c") %></span>
      </label>
      <label class="option-btn">
        <input type="radio" name="q<%= qid %>" value="D">
        <span class="option-label"><%= rs.getString("option_d") %></span>
      </label>
    </div>
<%
        qno++;
    }
} catch (Exception e) {}
%>

    <button type="submit" class="btn-submit">Submit Assessment securely</button>
  </form>
</main>

<script>
const EXAM_DURATION_SEC = <%= durationMinutes %> * 60;
const MAX_WARNINGS = 5;
const SCREENSHOT_EVERY = 30;
const PERSON_CHECK_EVERY = 3000;
const OBJECT_CHECK_EVERY = 5000;
const AUDIO_THRESHOLD = 0.05;
const FACE_MISSING_THRESHOLD_MS = 5000;

let warningCount = 0;
let totalTime = EXAM_DURATION_SEC;
const timerEl = document.getElementById('timer');
const examForm = document.getElementById('examForm');

function startTimer() {
  timerEl.textContent = formatTime(totalTime);
  const iv = setInterval(() => {
    totalTime--;
    timerEl.textContent = formatTime(Math.max(totalTime, 0));
    if (totalTime <= 0) {
      clearInterval(iv);
      showToast('⏱ Time expired. Auto-submitting...');
      setTimeout(() => examForm.submit(), 1500);
    }
  }, 1000);
}

function formatTime(sec) {
  const m = Math.floor(sec / 60);
  const s = sec % 60;
  return `${m}:${s < 10 ? '0' : ''}${s}`;
}

function addWarning(type, extra = {}) {
  warningCount++;
  document.getElementById('warningCount').textContent = warningCount;
  showToast('⚠ ' + violationMessage(type));
  sendViolation(type, extra);

  if (warningCount >= MAX_WARNINGS) {
    document.getElementById('lockout-overlay').classList.add('show');
    setTimeout(() => examForm.submit(), 2500);
  }
}

function violationMessage(type) {
  const m = {
    FACE_MISSING: 'Face not detected for 5 seconds',
    MULTIPLE_FACES: 'Multiple persons detected',
    OBJECT_DETECTED: 'Restricted object detected',
    AUDIO_NOISE: 'High background noise detected',
    TAB_SWITCH: 'Tab switch detected',
    WINDOW_SWITCH: 'Window focus lost',
    FULLSCREEN_EXIT: 'Fullscreen exited',
    CAMERA_BLOCKED: 'Camera permission required'
  };
  return m[type] || 'Anomaly detected';
}

async function sendViolation(type, extra = {}) {
  const params = new URLSearchParams({
    eventType: type,
    examId: '<%= examId %>'
  });

  if (extra.object_detected) params.append('object_detected', extra.object_detected);

  try {
    await fetch('LogViolationServlet', {
      method: 'POST',
      body: params
    });
  } catch (e) {}
}

function showToast(msg) {
  const t = document.createElement('div');
  t.className = 'toast';
  t.textContent = msg;
  const c = document.getElementById('toast-container');
  c.appendChild(t);
  setTimeout(() => {
    if (t.parentNode) c.removeChild(t);
  }, 3500);
}

function setBadge(id, state) {
  const el = document.getElementById(id);
  if (el) el.className = `status-badge ${state}`;
}

setBadge('st-tab', 'ok');

// ================= FULLSCREEN ENFORCEMENT =================
let fullscreenWarnLock = false;
let fullscreenRequired = true;

const fsOverlay = document.getElementById('fullscreen-overlay');
const fsResumeBtn = document.getElementById('resumeFullscreenBtn');

function isFullscreenActive() {
  return !!(
    document.fullscreenElement ||
    document.webkitFullscreenElement ||
    document.mozFullScreenElement ||
    document.msFullscreenElement
  );
}

async function enterFullscreen() {
  const elem = document.documentElement;
  try {
    if (elem.requestFullscreen) {
      await elem.requestFullscreen();
    } else if (elem.webkitRequestFullscreen) {
      await elem.webkitRequestFullscreen();
    } else if (elem.mozRequestFullScreen) {
      await elem.mozRequestFullScreen();
    } else if (elem.msRequestFullscreen) {
      await elem.msRequestFullscreen();
    }
    document.body.classList.add('fullscreen-enforced');
    hideFullscreenOverlay();
    return true;
  } catch (e) {
    return false;
  }
}

function showFullscreenOverlay() {
  if (fsOverlay) fsOverlay.style.display = 'flex';
}

function hideFullscreenOverlay() {
  if (fsOverlay) fsOverlay.style.display = 'none';
}

function handleFullscreenViolation() {
  if (!fullscreenRequired) return;

  showFullscreenOverlay();
  setBadge('st-tab', 'bad');

  if (!fullscreenWarnLock) {
    fullscreenWarnLock = true;
    addWarning('FULLSCREEN_EXIT');
    setTimeout(() => { fullscreenWarnLock = false; }, 3000);
  }
}

document.addEventListener('fullscreenchange', () => {
  if (isFullscreenActive()) {
    hideFullscreenOverlay();
    document.body.classList.add('fullscreen-enforced');
    setBadge('st-tab', 'ok');
  } else {
    document.body.classList.remove('fullscreen-enforced');
    handleFullscreenViolation();
  }
});

document.addEventListener('webkitfullscreenchange', () => {
  if (isFullscreenActive()) {
    hideFullscreenOverlay();
    document.body.classList.add('fullscreen-enforced');
    setBadge('st-tab', 'ok');
  } else {
    document.body.classList.remove('fullscreen-enforced');
    handleFullscreenViolation();
  }
});

if (fsResumeBtn) {
  fsResumeBtn.addEventListener('click', async () => {
    const ok = await enterFullscreen();
    if (!ok) {
      showToast('❌ Please allow fullscreen to continue.');
    }
  });
}

async function enforceFullscreenOnStart() {
  if (!fullscreenRequired) return;

  if (!isFullscreenActive()) {
    showFullscreenOverlay();
    const ok = await enterFullscreen();
    if (!ok) {
      showToast('🔒 Click "Return to Fullscreen" to begin.');
      showFullscreenOverlay();
    }
  }
}

if (examForm) {
  examForm.addEventListener('click', async () => {
    if (!isFullscreenActive()) {
      await enterFullscreen();
    }
  }, { once: true });
}

if (examForm) {
  examForm.addEventListener('submit', function(e) {
    if (fullscreenRequired && !isFullscreenActive() && warningCount < MAX_WARNINGS) {
      e.preventDefault();
      showToast('⚠ Please return to fullscreen before submitting.');
      showFullscreenOverlay();
    }
  });
}

// Keyboard restrictions
document.addEventListener('keydown', async (e) => {
  const k = e.key.toLowerCase();

  if (
    e.key === 'F12' ||
    (e.ctrlKey && ['c','v','u','s','p'].includes(k))
  ) {
    e.preventDefault();
  }

  if (e.key === 'F11') {
    e.preventDefault();
    if (!isFullscreenActive()) {
      await enterFullscreen();
    }
  }

  if (e.key === 'Escape' && fullscreenRequired) {
    setTimeout(() => {
      if (!isFullscreenActive()) handleFullscreenViolation();
    }, 150);
  }
});

// Better Tab / Blur handling
let firstBlur = true;
let blurCooldown = false;
let visibilityWarnLock = false;

document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    setBadge('st-tab', 'bad');
    if (!visibilityWarnLock) {
      visibilityWarnLock = true;
      addWarning('TAB_SWITCH');
      setTimeout(() => { visibilityWarnLock = false; }, 3000);
    }
  } else {
    setBadge('st-tab', 'ok');
  }
});

window.addEventListener('blur', () => {
  if (firstBlur) {
    firstBlur = false;
    return;
  }

  if (blurCooldown) return;
  blurCooldown = true;

  setTimeout(() => {
    if (!document.hidden && !isFullscreenActive()) {
      setBadge('st-tab', 'bad');
      addWarning('WINDOW_SWITCH');
    }
    blurCooldown = false;
  }, 300);
});

window.addEventListener('focus', () => {
  setBadge('st-tab', 'ok');
});

document.addEventListener('contextmenu', e => e.preventDefault());

// ================= CAMERA =================
const video = document.getElementById('camVideo');
const canvas = document.getElementById('camCanvas');
const ctx2d = canvas.getContext('2d');

let mediaStream = null;
let cocoModel = null;

async function startCamera() {
  try {
    mediaStream = await navigator.mediaDevices.getUserMedia({
      video: { width: { ideal: 640 }, height: { ideal: 480 }, facingMode: "user" },
      audio: true
    });

    video.srcObject = mediaStream;

    await new Promise((resolve) => {
      video.onloadedmetadata = () => {
        video.play();
        resolve();
      };
    });

    canvas.width = video.videoWidth || 640;
    canvas.height = video.videoHeight || 480;

    return mediaStream;
  } catch (e) {
    addWarning('CAMERA_BLOCKED');
    showToast('❌ Camera + microphone permission required.');
    return null;
  }
}

// ================= COCO-SSD MODEL =================
const BANNED = new Set(['cell phone','book','laptop','remote','keyboard','mouse','tv','monitor']);
let objectWarnLock = false;
let multiWarnLock = false;
let faceMissingStart = null;
let faceMissingWarned = false;

async function loadCocoModel() {
  cocoModel = await cocoSsd.load();
  setBadge('st-obj', 'ok');
  setBadge('st-face', 'ok');
}

// ================= FACE PRESENCE / MULTI PERSON DETECTION =================
// NOTE: We use "person" detection as reliable face presence approximation
async function runPresenceAndObjectChecks() {
  if (!cocoModel || !video || video.readyState < 2) return;

  try {
    const predictions = await cocoModel.detect(video);

    ctx2d.clearRect(0, 0, canvas.width, canvas.height);

    const persons = predictions.filter(p => p.class === 'person' && p.score > 0.50);
    const bannedObjects = predictions.filter(p => BANNED.has(p.class) && p.score > 0.55);

    // Draw boxes
    predictions.forEach(p => {
      const [x, y, w, h] = p.bbox;
      const isPerson = p.class === 'person' && p.score > 0.50;
      const isBanned = BANNED.has(p.class) && p.score > 0.55;

      if (isPerson || isBanned) {
        ctx2d.strokeStyle = isBanned ? 'rgba(239,68,68,0.9)' : 'rgba(16,185,129,0.8)';
        ctx2d.lineWidth = 2;
        ctx2d.strokeRect(x, y, w, h);

        ctx2d.fillStyle = isBanned ? 'rgba(239,68,68,0.9)' : 'rgba(16,185,129,0.9)';
        ctx2d.font = '12px Arial';
        ctx2d.fillText(p.class + ' ' + Math.round(p.score * 100) + '%', x + 4, y > 14 ? y - 4 : y + 14);
      }
    });

    // FACE MISSING (using person presence)
    if (persons.length === 0) {
      setBadge('st-face', 'bad');

      if (faceMissingStart === null) {
        faceMissingStart = Date.now();
      }

      const missingDuration = Date.now() - faceMissingStart;

      if (missingDuration >= FACE_MISSING_THRESHOLD_MS && !faceMissingWarned) {
        addWarning('FACE_MISSING');
        faceMissingWarned = true;
      }

      setBadge('st-multi', 'off');
    } else {
      setBadge('st-face', 'ok');
      faceMissingStart = null;
      faceMissingWarned = false;

      // MULTI PERSON DETECTION
      if (persons.length > 1) {
        setBadge('st-multi', 'bad');
        if (!multiWarnLock) {
          multiWarnLock = true;
          addWarning('MULTIPLE_FACES');
          setTimeout(() => { multiWarnLock = false; }, 5000);
        }
      } else {
        setBadge('st-multi', 'ok');
      }
    }

    // Keep these as visual placeholders (not hard-failing)
    setBadge('st-head', persons.length > 0 ? 'ok' : 'off');
    setBadge('st-eye', persons.length > 0 ? 'ok' : 'off');

    // OBJECT DETECTION
    if (bannedObjects.length > 0) {
      setBadge('st-obj', 'bad');
      if (!objectWarnLock) {
        objectWarnLock = true;
        addWarning('OBJECT_DETECTED', {
          object_detected: bannedObjects.map(x => x.class).join(',')
        });
        setTimeout(() => { objectWarnLock = false; }, 6000);
      }
    } else {
      setBadge('st-obj', 'ok');
    }

  } catch (e) {
    console.error('Detection error:', e);
  }
}

// ================= AUDIO MONITOR =================
let audioWarnLock = false;

async function startAudioMonitor(stream) {
  if (!stream) {
    setBadge('st-audio', 'off');
    return;
  }

  try {
    const audioContext = new (window.AudioContext || window.webkitAudioContext)();
    const src = audioContext.createMediaStreamSource(stream);
    const analyser = audioContext.createAnalyser();

    analyser.fftSize = 512;
    src.connect(analyser);

    const buffer = new Float32Array(analyser.fftSize);
    setBadge('st-audio', 'ok');

    setInterval(() => {
      analyser.getFloatTimeDomainData(buffer);
      let sum = 0;
      for (let i = 0; i < buffer.length; i++) {
        sum += buffer[i] * buffer[i];
      }
      const rms = Math.sqrt(sum / buffer.length);

      if (rms > AUDIO_THRESHOLD) {
        setBadge('st-audio', 'bad');
        if (!audioWarnLock) {
          audioWarnLock = true;
          addWarning('AUDIO_NOISE');
          setTimeout(() => { audioWarnLock = false; }, 8000);
        }
      } else {
        setBadge('st-audio', 'ok');
      }
    }, 1500);

  } catch (e) {
    setBadge('st-audio', 'off');
  }
}

// ================= SCREENSHOT =================
async function captureScreenshot() {
  if (!video.srcObject || video.readyState < 2) return;

  const snap = document.createElement('canvas');
  snap.width = 320;
  snap.height = 240;
  snap.getContext('2d').drawImage(video, 0, 0, 320, 240);

  try {
    await fetch('ScreenshotServlet', {
      method: 'POST',
      body: new URLSearchParams({
        screenshot: snap.toDataURL('image/png'),
        examId: '<%=examId%>'
      })
    });
  } catch (e) {}
}

// ================= INIT =================
(async function init() {
  startTimer();

  await enforceFullscreenOnStart();

  const stream = await startCamera();
  if (!stream) return;

  try {
    await loadCocoModel();
  } catch (e) {
    showToast('❌ AI detection model failed to load.');
    console.error(e);
    return;
  }

  // Start periodic screenshot
  let elapsed = 0;
  setInterval(() => {
    elapsed++;
    if (elapsed % SCREENSHOT_EVERY === 0) {
      captureScreenshot();
    }
  }, 1000);

  // Presence + object detection
  setInterval(runPresenceAndObjectChecks, PERSON_CHECK_EVERY);

  // Audio monitor
  await startAudioMonitor(stream);
})();
</script>
</body>
</html>