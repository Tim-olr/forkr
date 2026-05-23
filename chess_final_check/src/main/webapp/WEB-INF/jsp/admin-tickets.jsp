<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.support.SupportTicket, timolr.chess.account.User, java.util.List, java.time.ZoneId, java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Support Tickets - Forkr Admin</title>
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
        <li><a href="${pageContext.request.contextPath}/adminTickets" style="color:var(--green)">Tickets</a></li>
        <li><a href="${pageContext.request.contextPath}/adminBanLogs">Ban Logs</a></li>
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
    String ticketFlash = (String) session.getAttribute("adminTicketFlash");
    if (ticketFlash != null) session.removeAttribute("adminTicketFlash");

    List<SupportTicket> tickets = (List<SupportTicket>) pageContext.findAttribute("allTickets");
    List<User> adminUsers = (List<User>) pageContext.findAttribute("adminUsers");
    Long currentAdminId = (Long) session.getAttribute("userId");
    if (tickets == null) tickets = new java.util.ArrayList<>();
    if (adminUsers == null) adminUsers = new java.util.ArrayList<>();

    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm").withZone(ZoneId.systemDefault());
    long openCount = tickets.stream().filter(t -> "OPEN".equals(t.getStatus())).count();
    long claimedCount = tickets.stream().filter(t -> "CLAIMED".equals(t.getStatus())).count();
    long closedCount = tickets.stream().filter(t -> "CLOSED".equals(t.getStatus())).count();
%>

<div class="admin-panel" style="max-width:1100px;margin:32px auto;padding:0 16px">

    <% if (ticketFlash != null) { %>
    <div class="admin-flash" style="margin-bottom:18px"><%= esc(ticketFlash) %></div>
    <% } %>

    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;flex-wrap:wrap;gap:12px">
        <h2 style="margin:0;font-size:22px">Support Tickets</h2>
        <div style="display:flex;gap:12px;font-size:13px;color:var(--text-muted)">
            <span><strong style="color:var(--accent)"><%= openCount %></strong> open</span>
            <span><strong style="color:var(--warning, #e8a020)"><%= claimedCount %></strong> claimed</span>
            <span><strong style="color:var(--text-muted)"><%= closedCount %></strong> closed</span>
        </div>
    </div>

    <!-- Filter tabs -->
    <div style="display:flex;gap:8px;margin-bottom:18px">
        <button class="btn btn-outline ticket-filter-btn active" onclick="filterTickets('all',this)">All</button>
        <button class="btn btn-outline ticket-filter-btn" onclick="filterTickets('OPEN',this)">Open</button>
        <button class="btn btn-outline ticket-filter-btn" onclick="filterTickets('CLAIMED',this)">Claimed</button>
        <button class="btn btn-outline ticket-filter-btn" onclick="filterTickets('CLOSED',this)">Closed</button>
    </div>

    <% if (tickets.isEmpty()) { %>
    <div style="text-align:center;padding:60px 0;color:var(--text-muted)">No support tickets yet.</div>
    <% } else { %>
    <div class="admin-table-wrap">
    <table class="admin-table" id="ticketTable">
        <thead>
            <tr>
                <th>#</th>
                <th>Status</th>
                <th>Subject</th>
                <th>User</th>
                <th>Email</th>
                <th>Claimed By</th>
                <th>Created</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <% for (SupportTicket t : tickets) { %>
        <tr class="ticket-row" data-status="<%= t.getStatus() %>">
            <td style="color:var(--text-muted);font-size:12px">#<%= t.getId() %></td>
            <td>
                <span class="ticket-status ticket-status-<%= t.getStatus().toLowerCase() %>"><%= t.getStatus() %></span>
            </td>
            <td>
                <button class="btn-link ticket-title-btn" onclick="toggleTicket(<%= t.getId() %>)" style="font-weight:600;text-align:left"><%= esc(t.getTitle()) %></button>
            </td>
            <td><%= t.getSubmittedBy() != null ? esc(t.getSubmittedBy().getUsername()) : "<em style='color:var(--text-muted)'>—</em>" %></td>
            <td><a href="mailto:<%= esc(t.getUserEmail()) %>" style="color:var(--accent)"><%= esc(t.getUserEmail()) %></a></td>
            <td>
                <% if (t.getClaimedBy() != null) { %>
                    <%= esc(t.getClaimedBy().getUsername()) %>
                <% } else { %>
                    <span style="color:var(--text-muted)">—</span>
                <% } %>
            </td>
            <td style="font-size:12px;color:var(--text-muted)"><%= fmt.format(t.getCreatedAt()) %></td>
            <td>
                <div style="display:flex;gap:6px;flex-wrap:wrap;align-items:center">
                <% if ("OPEN".equals(t.getStatus())) { %>
                    <form method="POST" action="${pageContext.request.contextPath}/adminClaimTicket" style="display:inline">
                        <input type="hidden" name="ticketId" value="<%= t.getId() %>">
                        <button type="submit" class="btn btn-outline ab-btn-xs">Claim</button>
                    </form>
                <% } else if ("CLAIMED".equals(t.getStatus())) { %>
                    <% boolean isOwner = t.getClaimedBy() != null && t.getClaimedBy().getId().equals(currentAdminId); %>
                    <% if (isOwner) { %>
                    <form method="POST" action="${pageContext.request.contextPath}/adminUnclaimTicket" style="display:inline">
                        <input type="hidden" name="ticketId" value="<%= t.getId() %>">
                        <button type="submit" class="btn btn-outline ab-btn-xs">Unclaim</button>
                    </form>
                    <% } %>
                    <button class="btn btn-outline ab-btn-xs" onclick="toggleAssign(<%= t.getId() %>)">Reassign</button>
                <% } %>
                <% if (!"CLOSED".equals(t.getStatus())) { %>
                    <form method="POST" action="${pageContext.request.contextPath}/adminCloseTicket" style="display:inline">
                        <input type="hidden" name="ticketId" value="<%= t.getId() %>">
                        <button type="submit" class="btn btn-outline ab-btn-xs" style="color:var(--error)">Close</button>
                    </form>
                <% } else { %>
                    <form method="POST" action="${pageContext.request.contextPath}/adminReopenTicket" style="display:inline">
                        <input type="hidden" name="ticketId" value="<%= t.getId() %>">
                        <button type="submit" class="btn btn-outline ab-btn-xs">Reopen</button>
                    </form>
                <% } %>
                </div>
                <!-- Assign panel -->
                <div id="assign-<%= t.getId() %>" style="display:none;margin-top:8px">
                    <form method="POST" action="${pageContext.request.contextPath}/adminAssignTicket" style="display:flex;gap:6px;align-items:center">
                        <input type="hidden" name="ticketId" value="<%= t.getId() %>">
                        <select name="assignAdminId" class="form-input" style="height:30px;font-size:13px;padding:2px 8px">
                            <% for (User admin : adminUsers) { %>
                            <option value="<%= admin.getId() %>"><%= esc(admin.getUsername()) %></option>
                            <% } %>
                        </select>
                        <button type="submit" class="btn btn-green ab-btn-xs">Assign</button>
                    </form>
                </div>
            </td>
        </tr>
        <!-- Ticket detail row -->
        <tr id="detail-<%= t.getId() %>" style="display:none">
            <td colspan="8" style="padding:12px 24px;background:var(--surface-alt);border-top:none">
                <div style="font-size:13px;line-height:1.6;white-space:pre-wrap;color:var(--text)"><%= esc(t.getMessage()) %></div>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
    </div>
    <% } %>
</div>

<script>
function toggleTicket(id) {
    var row = document.getElementById('detail-' + id);
    if (row) row.style.display = row.style.display === 'none' ? '' : 'none';
}
function toggleAssign(id) {
    var el = document.getElementById('assign-' + id);
    if (el) el.style.display = el.style.display === 'none' ? '' : 'none';
}
function filterTickets(status, btn) {
    document.querySelectorAll('.ticket-filter-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    document.querySelectorAll('.ticket-row').forEach(function(row) {
        row.style.display = (status === 'all' || row.dataset.status === status) ? '' : 'none';
        var detailId = row.querySelector('.ticket-title-btn');
        if (detailId) {
            var id = detailId.getAttribute('onclick').match(/\d+/)[0];
            var detail = document.getElementById('detail-' + id);
            if (detail && row.style.display === 'none') detail.style.display = 'none';
        }
    });
}
</script>

<style>
.ticket-status {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: .5px;
}
.ticket-status-open { background: rgba(80,180,100,0.15); color: #50b464; }
.ticket-status-claimed { background: rgba(232,160,32,0.15); color: #e8a020; }
.ticket-status-closed { background: #ac2c2c9c; color: var(--error); }
.ticket-filter-btn.active { background: var(--accent); color: #fff; border-color: var(--accent); }
.btn-link { background: none; border: none; cursor: pointer; color: var(--text); padding: 0; font-size: inherit; }
.btn-link:hover { color: var(--accent); text-decoration: underline; }
</style>
</body>
</html>
