<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.account.BanLog, java.util.List, java.time.format.DateTimeFormatter" %>
<%!
    private String escBanLog(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
    }
%>
<%
    pageContext.setAttribute("pageTitle", "Ban Logs");
    pageContext.setAttribute("activeNav", "admin");
    List<BanLog> logs = (List<BanLog>) pageContext.findAttribute("banLogs");
    if (logs == null) logs = new java.util.ArrayList<>();
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    long banCount   = logs.stream().filter(l -> "BAN".equals(l.getAction())).count();
    long unbanCount = logs.stream().filter(l -> "UNBAN".equals(l.getAction())).count();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="_head.jsp" %>
</head>
<body>
<div class="app-shell">
    <%@ include file="_sidebar.jsp" %>

    <main class="page">
        <div class="page-head">
            <div class="crumb">
                <span class="crumb-pre">Admin</span>
                <h2>Ban Logs</h2>
            </div>
            <div class="page-actions">
                <a href="${pageContext.request.contextPath}/admin" class="btn">&#8592; Back to Admin</a>
            </div>
        </div>

        <div class="page-body">
            <div class="kpis" style="grid-template-columns:repeat(3,minmax(0,1fr));margin-bottom:20px">
                <div class="kpi">
                    <div class="label">Total Entries</div>
                    <div class="val"><%= logs.size() %></div>
                </div>
                <div class="kpi">
                    <div class="label">Bans</div>
                    <div class="val" style="color:var(--crimson)"><%= banCount %></div>
                </div>
                <div class="kpi">
                    <div class="label">Unbans</div>
                    <div class="val" style="color:var(--moss)"><%= unbanCount %></div>
                </div>
            </div>

            <div class="card">
                <div class="card-head">
                    <h3>All Ban Events</h3>
                    <input type="text" id="logSearch" style="background:var(--bg);border:1px solid var(--line-strong);color:var(--ink);padding:7px 10px;border-radius:4px;font-size:13px;width:220px"
                           placeholder="Search logs…" oninput="filterTable('logSearch','logsTable')">
                </div>
                <% if (logs.isEmpty()) { %>
                <div style="padding:40px 16px;text-align:center;color:var(--ink-faint);font-size:13px">No ban events recorded yet.</div>
                <% } else { %>
                <div class="table-wrap">
                    <table class="data-table" id="logsTable">
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
                                <td style="white-space:nowrap;font-family:var(--font-mono);font-size:12px;color:var(--ink-faint)">
                                    <%= log.getCreatedAt() != null ? log.getCreatedAt().format(fmt) : "" %>
                                </td>
                                <td>
                                    <% if ("BAN".equals(log.getAction())) { %>
                                        <span class="tag bad">BAN</span>
                                    <% } else { %>
                                        <span class="tag ok">UNBAN</span>
                                    <% } %>
                                </td>
                                <td style="font-weight:500"><%= escBanLog(log.getTargetUsername()) %></td>
                                <td style="color:var(--ink-mute)"><%= escBanLog(log.getAdminUsername()) %></td>
                                <td style="font-size:13px;color:var(--ink-faint);max-width:300px">
                                    <%= log.getReason() != null && !log.getReason().isBlank() ? escBanLog(log.getReason()) : "<em>No reason given</em>" %>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </div>
        </div>
    </main>
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
