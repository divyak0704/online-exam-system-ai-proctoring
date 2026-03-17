<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>AI Proctor Exam  Secure Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Premium AI Proctored Online Examination System login">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
:root {
  --bg-dark: #09090b;
  --bg-gradient: linear-gradient(135deg, #09090b 0%, #18181b 100%);
  --accent-1: #6366f1; /* Indigo */
  --accent-2: #a855f7; /* Purple */
  --accent-3: #ec4899; /* Pink */
  --surface-1: rgba(255, 255, 255, 0.03);
  --surface-2: rgba(255, 255, 255, 0.05);
  --border-subtle: rgba(255, 255, 255, 0.08);
  --border-strong: rgba(255, 255, 255, 0.15);
  --text-primary: #f8fafc;
  --text-secondary: #94a3b8;
  --error-bg: rgba(239, 68, 68, 0.1);
  --error-text: #fca5a5;
  --radius-xl: 24px;
  --radius-md: 12px;
}

* { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: 'Plus Jakarta Sans', sans-serif;
  background: var(--bg-dark);
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  color: var(--text-primary);
}

/* Fluid Mesh Gradient Background */
.bg-mesh {
  position: absolute;
  top: 0; left: 0; width: 100%; height: 100%;
  overflow: hidden;
  z-index: 0;
  background: var(--bg-dark);
}
.bg-mesh::before, .bg-mesh::after {
  content: '';
  position: absolute;
  border-radius: 50%;
  filter: blur(120px);
  opacity: 0.3;
  animation: meshFloat 12s ease-in-out infinite alternate;
}
.bg-mesh::before {
  top: -10%; left: -10%;
  width: 60vw; height: 60vw;
  background: var(--accent-1);
}
.bg-mesh::after {
  bottom: -10%; right: -10%;
  width: 50vw; height: 50vw;
  background: var(--accent-2);
  animation-delay: -6s;
}
@keyframes meshFloat {
  0% { transform: translateY(0) scale(1); }
  100% { transform: translateY(-50px) scale(1.1); }
}

/* Glassmorphism Card */
.glass-container {
  position: relative;
  z-index: 10;
  width: 100%;
  max-width: 440px;
  padding: 48px;
  background: var(--surface-1);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-xl);
  backdrop-filter: blur(32px);
  -webkit-backdrop-filter: blur(32px);
  box-shadow: 
    0 24px 64px rgba(0, 0, 0, 0.4),
    inset 0 0 0 1px rgba(255, 255, 255, 0.05); /* Inner glow */
  animation: fadeUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
  opacity: 0;
  transform: translateY(20px);
}
@keyframes fadeUp {
  to { opacity: 1; transform: translateY(0); }
}

.brand-header {
  text-align: center;
  margin-bottom: 40px;
}
.brand-icon {
  width: 64px; height: 64px;
  margin: 0 auto 16px;
  background: linear-gradient(135deg, var(--accent-1), var(--accent-2));
  border-radius: 16px;
  display: flex; align-items: center; justify-content: center;
  font-size: 32px;
  box-shadow: 0 12px 32px rgba(99, 102, 241, 0.3);
}
.brand-title {
  font-size: 26px;
  font-weight: 700;
  letter-spacing: -0.5px;
  background: linear-gradient(to right, #ffffff, #a5b4fc);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 8px;
}
.brand-subtitle {
  font-size: 14px;
  color: var(--text-secondary);
  font-weight: 500;
}

/* Form Styling */
.form-group { margin-bottom: 24px; }
.form-label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: var(--text-secondary);
  margin-bottom: 8px;
  letter-spacing: 0.5px;
  text-transform: uppercase;
}
.form-input {
  width: 100%;
  background: rgba(0, 0, 0, 0.2);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-md);
  padding: 14px 18px;
  font-size: 15px;
  color: var(--text-primary);
  font-family: inherit;
  transition: all 0.3s ease;
}
.form-input:focus {
  outline: none;
  background: rgba(0, 0, 0, 0.4);
  border-color: var(--accent-1);
  box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.15);
}
.form-input::placeholder { color: rgba(255, 255, 255, 0.2); }

/* Error Message */
.error-banner {
  background: var(--error-bg);
  border: 1px solid rgba(239, 68, 68, 0.2);
  color: var(--error-text);
  padding: 12px 16px;
  border-radius: var(--radius-md);
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 24px;
  display: flex;
  align-items: center;
  gap: 8px;
}

/* Premium Button */
.btn-primary {
  width: 100%;
  padding: 16px;
  border: none;
  border-radius: var(--radius-md);
  background: linear-gradient(135deg, var(--accent-1), var(--accent-2));
  color: #fff;
  font-size: 16px;
  font-weight: 600;
  font-family: inherit;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: transform 0.2s, box-shadow 0.2s;
  box-shadow: 0 8px 24px rgba(99, 102, 241, 0.4);
}
.btn-primary::after {
  content: '';
  position: absolute;
  top: 0; left: -100%; width: 50%; height: 100%;
  background: linear-gradient(to right, transparent, rgba(255,255,255,0.2), transparent);
  transform: skewX(-20deg);
  animation: shine 3s infinite;
}
@keyframes shine {
  0% { left: -100%; }
  20% { left: 200%; }
  100% { left: 200%; }
}
.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 32px rgba(99, 102, 241, 0.5);
}
.btn-primary:active { transform: translateY(0); }

/* Footer */
.footer-text {
  text-align: center;
  margin-top: 32px;
  font-size: 12px;
  color: var(--text-secondary);
  line-height: 1.6;
}
.footer-text span {
  color: var(--text-primary);
  font-weight: 500;
}
</style>
</head>

<body>
<div class="bg-mesh"></div>

<main class="glass-container">
  <div class="brand-header">
    <div class="brand-icon">exam proctor�</div>
    <h1 class="brand-title">AI Proctor Gateway</h1>
    <p class="brand-subtitle">automated Online Examination</p>
  </div>

  <form action="<%= request.getContextPath() %>/LoginServlet" method="post">
    
    <% if(request.getAttribute("error") != null){ %>
    <div class="error-banner">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
      <%= request.getAttribute("error") %>
    </div>
    <% } %>

    <div class="form-group">
      <label class="form-label" for="username">Username / ID</label>
      <input type="text" class="form-input" id="username" name="username"
        value="<%= request.getAttribute("usernameValue") != null ? request.getAttribute("usernameValue") : "" %>"
        placeholder="e.g. jdoe123" required autocomplete="username">
    </div>

    <div class="form-group">
      <label class="form-label" for="password">Security Key</label>
      <input type="password" class="form-input" id="password" name="password"
        placeholder="••••••••" required autocomplete="current-password">
    </div>

    <button class="btn-primary" type="submit">login</button>
  </form>

  <div class="footer-text">
    By signing in, you agree to the <span>Proctoring Terms of Service</span> and consent to continuous monitoring via webcam and microphone.
  </div>
</main>
</body>
</html>