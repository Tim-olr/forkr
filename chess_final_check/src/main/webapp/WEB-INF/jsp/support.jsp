<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.account.User, timolr.chess.account.UserDAO" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Support - Forkr</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
</head>
<body>
<%
    Long uid = (Long) session.getAttribute("userId");
    String userEmail = "";
    if (uid != null) {
        User u = new UserDAO().findById(uid);
        if (u != null && u.getEmail() != null) userEmail = u.getEmail();
    }
    String supportFlash = (String) session.getAttribute("supportFlash");
    if (supportFlash != null) session.removeAttribute("supportFlash");
%>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/home" class="navbar-logo">
        <span class="logo-icon">&#9816;</span>
        <span class="logo-text">Forkr</span>
    </a>
    <ul class="navbar-links">
        <li><a href="${pageContext.request.contextPath}/online-game">Play Online</a></li>
        <li><a href="${pageContext.request.contextPath}/game">vs Bots</a></li>
        <li><a href="${pageContext.request.contextPath}/game?localPlay=true">Local Play</a></li>
        <li><a href="${pageContext.request.contextPath}/army-builder">Army Builder</a></li>
        <% if (Boolean.TRUE.equals(session.getAttribute("isAdmin"))) { %>
        <li><a href="${pageContext.request.contextPath}/admin">Admin</a></li>
        <li><a href="${pageContext.request.contextPath}/adminTickets">Tickets</a></li>
        <li><a href="${pageContext.request.contextPath}/adminBanLogs">Ban Logs</a></li>
        <% } %>
    </ul>
    <div class="navbar-right">
        <a href="${pageContext.request.contextPath}/profile" class="navbar-username" style="text-decoration:none"><s:property value="loggedInUsername" /></a>
        <a href="${pageContext.request.contextPath}/support" class="btn btn-outline" style="margin-right:6px">Support</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline">Log Out</a>
    </div>
    <button class="nav-hamburger" onclick="this.closest('.navbar').classList.toggle('nav-open')" aria-label="Menu">
        <span></span><span></span><span></span>
    </button>
</nav>

<div style="max-width:560px;margin:48px auto;padding:0 16px">
    <h2 style="margin-bottom:6px">Contact Support</h2>
    <p style="color:var(--text-muted);margin-bottom:24px">Have a question, found a bug, or need help? Fill out the form below and our team will get back to you.</p>

    <% if (supportFlash != null) {
        boolean isOk = supportFlash.startsWith("ok:");
        String msg = supportFlash.replaceFirst("^(ok:|error:)", "");
    %>
    <div style="padding:12px 16px;border-radius:6px;margin-bottom:20px;font-size:14px;
        background:<%= isOk ? "rgba(80,180,100,0.12)" : "rgba(232,97,97,0.12)" %>;
        border:1px solid <%= isOk ? "rgba(80,180,100,0.4)" : "rgba(232,97,97,0.4)" %>;
        color:<%= isOk ? "#50b464" : "var(--error)" %>">
        <%= isOk ? "&#10003; " : "&#9888; " %><%= msg %>
    </div>
    <% } %>

    <div class="modal-box" style="padding:28px 32px;box-shadow:var(--shadow-md,0 2px 16px rgba(0,0,0,.15))">
        <form method="POST" action="${pageContext.request.contextPath}/submitTicket">
            <div class="form-group">
                <label class="form-label">Your Email <span style="color:var(--text-muted);font-weight:400">(we'll reply here)</span></label>
                <input type="email" name="ticketEmail" class="form-input" value="<%= userEmail.replace("\"","&quot;") %>" placeholder="email@example.com" required>
            </div>
            <div class="form-group">
                <label class="form-label">Subject</label>
                <input type="text" name="ticketTitle" class="form-input" placeholder="Brief description of your issue..." maxlength="200" required>
            </div>
            <div class="form-group">
                <label class="form-label">Message</label>
                <textarea name="ticketMessage" class="form-input" rows="6" placeholder="Describe your issue in detail..." style="resize:vertical" required></textarea>
            </div>
            <button type="submit" class="btn btn-green btn-full btn-lg" style="margin-top:8px">Submit Ticket</button>
        </form>
    </div>
</div>
</body>
</html>
