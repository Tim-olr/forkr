<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.account.BanLog, java.util.List, java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ban Logs - Forkr Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
</head>
<body>
<%! private String esc(String s) { if(s==null)return""; return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;"); } %>

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
        <li><a href="${pageContext.request.contextPath}/admin">Admin</a></li>
        <li><a href="${pageContext.request.contextPath}/adminTickets">Tickets</a></li>
        <li><a href="${pageContext.request.contextPath}/adminBanLogs" style="color:var(--green)">Ban Logs</a></li>
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

<%
    List<BanLog> logs = (List<BanLog>) pageContext.findAttribute("banLogs");
    if (logs == null) logs = new java.util.ArrayList<>();
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
%>

<div class="admin-page">
    <div class="admin-header">
        <div>
            <h1 class="admin-title">&#128220; Ban Logs</h1>
        </div>
        <a href="${pageContext.request.contextPath}/admin" class="btn btn-outline">&#8592; Back to Admin</a>
    </div>

    <div class="admin-stats">
        <div class="admin-stat-card">
            <div class="admin-stat-num"><%= logs.size() %></div>
            <div class="admin-stat-label">Total Entries</div>
        </div>
        <div class="admin-stat-card">
            <div class="admin-stat-num" style="color:var(--error)">
                <%= logs.stream().filter(l -> "BAN".equals(l.getAction())).count() %>
            </div>
            <div class="admin-stat-label">Bans</div>
        </div>
        <div class="admin-stat-card">
            <div class="admin-stat-num" style="color:var(--green)">
                <%= logs.stream().filter(l -> "UNBAN".equals(l.getAction())).count() %>
            </div>
            <div class="admin-stat-label">Unbans</div>
        </div>
    </div>

    <div class="admin-section">
        <div class="admin-section-header">
            <h2 class="admin-section-title" style="margin-bottom:0">All Ban Events</h2>
            <input type="text" id="logSearch" class="form-input" style="max-width:260px" placeholder="Search logs…" oninput="filterTable('logSearch','logsTable')">
        </div>
        <% if (logs.isEmpty()) { %>
        <div class="admin-empty">No ban events recorded yet.</div>
        <% } else { %>
        <table class="admin-table" id="logsTable">
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Action</th>
                    <th>Player</th>
                    <th>Admin</th>
                    <th>Reason</th>
                </tr>
            </thead>
            <tbody>
            <% for (BanLog log : logs) { %>
                <tr>
                    <td class="admin-td-owner" style="white-space:nowrap">
                        <%= log.getCreatedAt() != null ? log.getCreatedAt().format(fmt) : "" %>
                    </td>
                    <td>
                        <% if ("BAN".equals(log.getAction())) { %>
                            <span class="admin-banned-badge">BAN</span>
                        <% } else { %>
                            <span class="admin-preset-badge" style="font-size:11px;background:rgba(42,157,143,0.18);color:var(--green)">UNBAN</span>
                        <% } %>
                    </td>
                    <td class="admin-td-name"><%= esc(log.getTargetUsername()) %></td>
                    <td class="admin-td-owner"><%= esc(log.getAdminUsername()) %></td>
                    <td style="font-size:13px;color:var(--text-muted);max-width:300px">
                        <%= log.getReason() != null && !log.getReason().isBlank() ? esc(log.getReason()) : "<em>No reason given</em>" %>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </div>
</div>

<script>
function filterTable(inputId, tableId) {
    var q = document.getElementById(inputId).value.toLowerCase();
    document.querySelectorAll('#' + tableId + ' tbody tr').forEach(function(row) {
        row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}
</script>
</body>
</html>
