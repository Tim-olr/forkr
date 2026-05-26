<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.support.SupportTicket, timolr.chess.account.User, java.util.List, java.time.ZoneId, java.time.format.DateTimeFormatter" %>
<%!
    private String escTicket(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
    }
%>
<%
    pageContext.setAttribute("pageTitle", "Support Tickets");
    pageContext.setAttribute("activeNav", "admin");

    String ticketFlash = (String) session.getAttribute("adminTicketFlash");
    if (ticketFlash != null) session.removeAttribute("adminTicketFlash");

    List<SupportTicket> tickets = (List<SupportTicket>) pageContext.findAttribute("allTickets");
    List<User> adminUsers = (List<User>) pageContext.findAttribute("adminUsers");
    Long currentAdminId = (Long) session.getAttribute("userId");
    if (tickets == null) tickets = new java.util.ArrayList<>();
    if (adminUsers == null) adminUsers = new java.util.ArrayList<>();

    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm").withZone(ZoneId.systemDefault());
    long openCount   = tickets.stream().filter(t -> "OPEN".equals(t.getStatus())).count();
    long claimedCount = tickets.stream().filter(t -> "CLAIMED".equals(t.getStatus())).count();
    long closedCount  = tickets.stream().filter(t -> "CLOSED".equals(t.getStatus())).count();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="_head.jsp" %>
    <style>
    .ticket-status { display:inline-block; padding:2px 8px; border-radius:3px; font-family:var(--font-mono); font-size:10px; font-weight:700; letter-spacing:.06em; text-transform:uppercase; }
    .ticket-status-open    { background:rgba(122,148,97,0.15); color:var(--moss); border:1px solid rgba(122,148,97,0.35); }
    .ticket-status-claimed { background:rgba(212,164,74,0.15); color:var(--amber); border:1px solid rgba(212,164,74,0.35); }
    .ticket-status-closed  { background:rgba(200,85,61,0.12);  color:var(--crimson); border:1px solid rgba(200,85,61,0.35); }
    .ticket-filter-btn.active { background:var(--amber); color:#1a1408; border-color:var(--amber); }
    .btn-link { background:none; border:none; cursor:pointer; color:var(--ink); padding:0; font-size:inherit; font-weight:600; text-align:left; }
    .btn-link:hover { color:var(--amber); }
    </style>
</head>
<body>
<div class="app-shell">
    <%@ include file="_sidebar.jsp" %>

    <main class="page">
        <div class="page-head">
            <div class="crumb">
                <span class="crumb-pre">Admin</span>
                <h2>Support Tickets</h2>
            </div>
            <div class="page-actions" style="display:flex;gap:12px;align-items:center;font-size:13px;color:var(--ink-faint)">
                <span><strong style="color:var(--moss)"><%= openCount %></strong> open</span>
                <span><strong style="color:var(--amber)"><%= claimedCount %></strong> claimed</span>
                <span><strong style="color:var(--ink-faint)"><%= closedCount %></strong> closed</span>
            </div>
        </div>

        <div class="page-body">
            <% if (ticketFlash != null) { %>
            <div class="admin-flash"><%= escTicket(ticketFlash) %></div>
            <% } %>

            <div style="display:flex;gap:8px;margin-bottom:16px;flex-wrap:wrap">
                <button class="btn sm ticket-filter-btn active" onclick="filterTickets('all',this)">All</button>
                <button class="btn sm ticket-filter-btn" onclick="filterTickets('OPEN',this)">Open</button>
                <button class="btn sm ticket-filter-btn" onclick="filterTickets('CLAIMED',this)">Claimed</button>
                <button class="btn sm ticket-filter-btn" onclick="filterTickets('CLOSED',this)">Closed</button>
            </div>

            <% if (tickets.isEmpty()) { %>
            <div style="text-align:center;padding:60px 0;color:var(--ink-faint);font-size:13px">No support tickets yet.</div>
            <% } else { %>
            <div class="card">
                <div class="table-wrap">
                    <table class="data-table" id="ticketTable">
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
                            <td style="color:var(--ink-faint);font-family:var(--font-mono);font-size:12px">#<%= t.getId() %></td>
                            <td><span class="ticket-status ticket-status-<%= t.getStatus().toLowerCase() %>"><%= t.getStatus() %></span></td>
                            <td>
                                <button class="btn-link" onclick="toggleTicket(<%= t.getId() %>)"><%= escTicket(t.getTitle()) %></button>
                            </td>
                            <td><%= t.getSubmittedBy() != null ? escTicket(t.getSubmittedBy().getUsername()) : "<span style='color:var(--ink-faint)'>—</span>" %></td>
                            <td><a href="mailto:<%= escTicket(t.getUserEmail()) %>" style="color:var(--amber)"><%= escTicket(t.getUserEmail()) %></a></td>
                            <td>
                                <% if (t.getClaimedBy() != null) { %>
                                    <%= escTicket(t.getClaimedBy().getUsername()) %>
                                <% } else { %>
                                    <span style="color:var(--ink-faint)">—</span>
                                <% } %>
                            </td>
                            <td style="font-family:var(--font-mono);font-size:12px;color:var(--ink-faint);white-space:nowrap"><%= fmt.format(t.getCreatedAt()) %></td>
                            <td>
                                <div style="display:flex;gap:6px;flex-wrap:wrap;align-items:center">
                                <% if ("OPEN".equals(t.getStatus())) { %>
                                    <form method="POST" action="${pageContext.request.contextPath}/adminClaimTicket" style="display:inline">
                                        <input type="hidden" name="ticketId" value="<%= t.getId() %>">
                                        <button type="submit" class="btn sm">Claim</button>
                                    </form>
                                <% } else if ("CLAIMED".equals(t.getStatus())) { %>
                                    <% boolean isOwner = t.getClaimedBy() != null && t.getClaimedBy().getId().equals(currentAdminId); %>
                                    <% if (isOwner) { %>
                                    <form method="POST" action="${pageContext.request.contextPath}/adminUnclaimTicket" style="display:inline">
                                        <input type="hidden" name="ticketId" value="<%= t.getId() %>">
                                        <button type="submit" class="btn sm">Unclaim</button>
                                    </form>
                                    <% } %>
                                    <button class="btn sm" onclick="toggleAssign(<%= t.getId() %>)">Reassign</button>
                                <% } %>
                                <% if (!"CLOSED".equals(t.getStatus())) { %>
                                    <form method="POST" action="${pageContext.request.contextPath}/adminCloseTicket" style="display:inline">
                                        <input type="hidden" name="ticketId" value="<%= t.getId() %>">
                                        <button type="submit" class="btn sm danger">Close</button>
                                    </form>
                                <% } else { %>
                                    <form method="POST" action="${pageContext.request.contextPath}/adminReopenTicket" style="display:inline">
                                        <input type="hidden" name="ticketId" value="<%= t.getId() %>">
                                        <button type="submit" class="btn sm">Reopen</button>
                                    </form>
                                <% } %>
                                </div>
                                <div id="assign-<%= t.getId() %>" style="display:none;margin-top:8px">
                                    <form method="POST" action="${pageContext.request.contextPath}/adminAssignTicket" style="display:flex;gap:6px;align-items:center">
                                        <input type="hidden" name="ticketId" value="<%= t.getId() %>">
                                        <select name="assignAdminId" style="background:var(--bg);border:1px solid var(--line-strong);color:var(--ink);border-radius:4px;padding:4px 8px;font-size:13px">
                                            <% for (User admin : adminUsers) { %>
                                            <option value="<%= admin.getId() %>"><%= escTicket(admin.getUsername()) %></option>
                                            <% } %>
                                        </select>
                                        <button type="submit" class="btn sm primary">Assign</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <tr id="detail-<%= t.getId() %>" style="display:none">
                            <td colspan="8" style="padding:12px 24px;background:var(--bg-elev-2);border-top:none">
                                <div style="font-size:13px;line-height:1.6;white-space:pre-wrap;color:var(--ink)"><%= escTicket(t.getMessage()) %></div>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            <% } %>
        </div>
    </main>
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
        if (row.style.display === 'none') {
            var titleBtn = row.querySelector('.btn-link');
            if (titleBtn) {
                var m = titleBtn.getAttribute('onclick').match(/\d+/);
                if (m) {
                    var detail = document.getElementById('detail-' + m[0]);
                    if (detail) detail.style.display = 'none';
                }
            }
        }
    });
}
</script>
</body>
</html>
