<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.account.User, timolr.chess.account.UserRole, java.util.List" %>
<%@ page import="timolr.chess.bot.Bot" %>
<%@ page import="timolr.chess.army.Army" %>
<%@ page import="timolr.chess.game.MatchRecord" %>
<%@ page import="timolr.chess.support.PlayerReport, timolr.chess.support.SupportTicket, timolr.chess.support.PlatformSetting" %>
<%@ page import="timolr.chess.account.BanLog" %>
<%@ page import="timolr.chess.game.pieces.PieceDefinition" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%
    pageContext.setAttribute("pageTitle", "Admin");
    pageContext.setAttribute("activeNav", "admin");

    String curTab = (String) pageContext.findAttribute("tab");
    if (curTab == null || curTab.isEmpty()) curTab = "overview";

    List<User> users = (List<User>) pageContext.findAttribute("allUsers");
    List<Bot> bots = (List<Bot>) pageContext.findAttribute("allBots");
    List<Army> presetArmies = (List<Army>) pageContext.findAttribute("allPresetArmies");
    List<MatchRecord> matchRecords = (List<MatchRecord>) pageContext.findAttribute("matchRecords");
    List<PlayerReport> playerReports = (List<PlayerReport>) pageContext.findAttribute("playerReports");
    List<SupportTicket> supportTickets = (List<SupportTicket>) pageContext.findAttribute("supportTickets");
    List<PlatformSetting> platformSettings = (List<PlatformSetting>) pageContext.findAttribute("platformSettings");
    List<BanLog> banLogs = (List<BanLog>) pageContext.findAttribute("banLogs");

    Long currentUserId = (Long) session.getAttribute("userId");
    String viewerRole    = (String) session.getAttribute("userRole");
    boolean viewerIsOwner   = "OWNER".equals(viewerRole);
    boolean viewerIsCoOwner = "CO_OWNER".equals(viewerRole);
    if (users == null) users = new java.util.ArrayList<>();
    if (bots == null) bots = new java.util.ArrayList<>();
    if (presetArmies == null) presetArmies = new java.util.ArrayList<>();
    if (matchRecords == null) matchRecords = new java.util.ArrayList<>();
    if (playerReports == null) playerReports = new java.util.ArrayList<>();
    if (supportTickets == null) supportTickets = new java.util.ArrayList<>();
    if (platformSettings == null) platformSettings = new java.util.ArrayList<>();
    if (banLogs == null) banLogs = new java.util.ArrayList<>();

    long adminCount = users.stream().filter(User::isAdmin).count();
    long bannedCount = users.stream().filter(User::isBanned).count();
    long ownerCount   = users.stream().filter(User::isOwner).count();
    long coOwnerCount = users.stream().filter(User::isCoOwner).count();
    int openReportsCount = pageContext.findAttribute("openReportsCount") != null ? ((Number) pageContext.findAttribute("openReportsCount")).intValue() : 0;
    int totalMatchCount = pageContext.findAttribute("totalMatchCount") != null ? ((Number) pageContext.findAttribute("totalMatchCount")).intValue() : 0;
    ObjectMapper jsonMapper = new ObjectMapper();

    java.util.Set<String> existingCollections = new java.util.LinkedHashSet<>();
    for (Bot b : bots) {
        if (b.getCollection() != null && !b.getCollection().isBlank()) existingCollections.add(b.getCollection());
    }

    String adminFlash = (String) session.getAttribute("adminFlash");
    if (adminFlash != null) session.removeAttribute("adminFlash");
%>
<%! private String esc(String s) { if(s==null)return""; return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;"); } %>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="_head.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
    <style>
        body { background: var(--bg) !important; overflow: hidden; }
        /* bridge chess.css modal classes to forkr visual tokens */
        .modal-overlay { position:fixed;inset:0;background:rgba(10,8,5,.7);backdrop-filter:blur(4px);display:flex;align-items:center;justify-content:center;z-index:1000;padding:20px }
        .modal-box     { background:var(--bg-elev);border:1px solid var(--line-strong);border-radius:8px;max-width:520px;width:100%;max-height:calc(100vh - 40px);overflow:auto;position:relative;box-shadow:0 20px 60px rgba(0,0,0,.6);padding:24px }
        .modal-header-row { display:flex;align-items:center;justify-content:space-between;margin-bottom:16px }
        .modal-title   { font-family:var(--font-display);font-size:18px;font-weight:400 }
        .modal-close-btn { background:var(--bg-elev-2);border:1px solid var(--line-strong);color:var(--ink-mute);border-radius:4px;width:28px;height:28px;display:grid;place-items:center;cursor:pointer;font-size:18px;line-height:1 }
        .modal-close-btn:hover { color:var(--ink);border-color:var(--ink-faint) }
        .form-group    { margin-bottom:12px }
        .form-label    { display:block;font-size:12px;color:var(--ink-mute);margin-bottom:4px;letter-spacing:.03em }
        .form-input    { width:100%;background:var(--bg);border:1px solid var(--line-strong);border-radius:4px;padding:8px 10px;color:var(--ink);font-size:13px;font-family:inherit }
        .form-input:focus { border-color:var(--amber);outline:none }
        .btn-green  { background:var(--amber)!important;color:#1a1408!important;border-color:var(--amber)!important;font-weight:500 }
        .btn-green:hover { background:#e3b658!important;border-color:#e3b658!important }
        .btn-danger { color:var(--crimson)!important;border-color:rgba(200,85,61,.4)!important }
        .btn-danger:hover { background:rgba(200,85,61,.08)!important;border-color:var(--crimson)!important }
        .btn-outline { background:var(--bg-elev)!important;border-color:var(--line-strong)!important }
        .btn-outline:hover { background:var(--bg-elev-2)!important }
        .admin-section { margin-bottom:28px }
        .admin-section-header { display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;flex-wrap:wrap;gap:8px }
        .admin-section-title { font-family:var(--font-display);font-size:18px;font-weight:400;margin:0 }
        .admin-section-controls { display:flex;gap:8px;align-items:center }
        .admin-table { width:100%;border-collapse:collapse;font-size:13px }
        .admin-table th { text-align:left;padding:8px 10px;border-bottom:1px solid var(--line);font-size:11px;text-transform:uppercase;letter-spacing:.1em;color:var(--ink-faint);font-family:var(--font-mono);font-weight:400;white-space:nowrap }
        .admin-table td { padding:8px 10px;border-bottom:1px solid var(--line);vertical-align:middle }
        .admin-table tbody tr:hover { background:rgba(255,255,255,.02) }
        .admin-toggle-btn { font-size:12px;padding:4px 10px;border-radius:3px;border:1px solid var(--line-strong);background:var(--bg-elev);color:var(--ink-mute);cursor:pointer }
        .admin-toggle-btn:hover { background:var(--bg-elev-2);color:var(--ink) }
        .admin-toggle-btn.danger { color:var(--crimson);border-color:rgba(200,85,61,.3) }
        .admin-toggle-btn.danger:hover { background:rgba(200,85,61,.08) }
        .admin-empty { color:var(--ink-faint);font-size:13px;padding:24px 0;text-align:center }
        .admin-paginator { display:flex;align-items:center;gap:4px;margin-top:10px;flex-wrap:wrap }
        .pg-btn { padding:4px 10px;border:1px solid var(--line-strong);background:var(--bg-elev);color:var(--ink-mute);border-radius:3px;cursor:pointer;font-size:13px }
        .pg-btn:hover:not(.pg-disabled):not(.pg-active) { background:var(--bg-elev-2) }
        .pg-btn.pg-active { background:var(--amber);color:#1a1408;border-color:var(--amber);font-weight:600 }
        .pg-btn.pg-disabled { opacity:.35;cursor:default }
        .pg-ellipsis { padding:0 4px;color:var(--ink-faint);font-size:13px }
        .search-hidden,.pg-hidden { display:none!important }
    </style>
</head>
<body>
<div class="app-shell">
    <%@ include file="_sidebar.jsp" %>

    <main class="page">
        <div class="page-head">
            <div class="crumb">
                <span class="crumb-pre"><% if (viewerIsOwner) { %>Owner<% } else if (viewerIsCoOwner) { %>Co-Owner<% } else { %>Admin<% } %></span>
                <h2>Panel</h2>
            </div>
            <div class="page-actions">
                <a href="${pageContext.request.contextPath}/army-builder" class="btn sm">+ Preset Army</a>
            </div>
        </div>

        <div class="page-body">
            <% if (adminFlash != null) { %>
            <div class="admin-flash"><%= esc(adminFlash) %></div>
            <% } %>

            <!-- KPI row (always visible) -->
            <div class="kpis" style="margin-bottom:20px">
                <div class="kpi">
                    <div class="label">Total Users</div>
                    <div class="val"><%= users.size() %></div>
                </div>
                <div class="kpi">
                    <div class="label">Staff</div>
                    <div class="val"><%= adminCount %></div>
                </div>
                <div class="kpi">
                    <div class="label">Banned</div>
                    <div class="val" style="color:var(--crimson)"><%= bannedCount %></div>
                </div>
                <div class="kpi">
                    <div class="label">Open Reports</div>
                    <div class="val" style="<%= openReportsCount > 0 ? "color:var(--amber)" : "" %>"><%= openReportsCount %></div>
                </div>
            </div>

            <!-- Tab navigation -->
            <div class="admin-tabs">
                <a href="${pageContext.request.contextPath}/admin" class="<%= "overview".equals(curTab) ? "active" : "" %>">Overview</a>
                <a href="${pageContext.request.contextPath}/admin?tab=users" class="<%= "users".equals(curTab) ? "active" : "" %>">Users <span style="margin-left:4px;font-size:10px;color:var(--ink-faint)"><%= users.size() %></span></a>
                <a href="${pageContext.request.contextPath}/admin?tab=bots" class="<%= "bots".equals(curTab) ? "active" : "" %>">Bots <span style="margin-left:4px;font-size:10px;color:var(--ink-faint)"><%= bots.size() %></span></a>
                <a href="${pageContext.request.contextPath}/admin?tab=matches" class="<%= "matches".equals(curTab) ? "active" : "" %>">Matches</a>
                <a href="${pageContext.request.contextPath}/admin?tab=reports" class="<%= "reports".equals(curTab) ? "active" : "" %>">Reports <% if(openReportsCount>0){%><span style="margin-left:4px;font-size:10px;color:var(--amber)"><%= openReportsCount %></span><%}%></a>
                <a href="${pageContext.request.contextPath}/admin?tab=settings" class="<%= "settings".equals(curTab) ? "active" : "" %>">Settings</a>
                <a href="${pageContext.request.contextPath}/admin?tab=banlogs" class="<%= "banlogs".equals(curTab) ? "active" : "" %>">Ban Logs</a>
            </div>

            <!-- ── OVERVIEW TAB ──────────────────────────────────────────── -->
            <% if ("overview".equals(curTab)) { %>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:18px">
                <div class="card" style="padding:18px">
                    <div style="font-size:13px;font-weight:500;margin-bottom:14px">Quick Actions</div>
                    <div style="display:flex;flex-direction:column;gap:8px">
                        <a href="${pageContext.request.contextPath}/admin?tab=users" class="btn ghost" style="justify-content:flex-start">Manage Users (<%= users.size() %>)</a>
                        <a href="${pageContext.request.contextPath}/admin?tab=bots" class="btn ghost" style="justify-content:flex-start">Manage Bots (<%= bots.size() %>)</a>
                        <a href="${pageContext.request.contextPath}/admin?tab=matches" class="btn ghost" style="justify-content:flex-start">View Match Records</a>
                        <a href="${pageContext.request.contextPath}/admin?tab=reports" class="btn ghost" style="justify-content:flex-start">Review Reports (<%= openReportsCount %> open)</a>
                        <a href="${pageContext.request.contextPath}/admin?tab=settings" class="btn ghost" style="justify-content:flex-start">Platform Settings</a>
                        <a href="${pageContext.request.contextPath}/admin?tab=banlogs" class="btn ghost" style="justify-content:flex-start">Ban Logs</a>
                        <a href="${pageContext.request.contextPath}/adminTickets" class="btn ghost" style="justify-content:flex-start">Support Tickets</a>
                    </div>
                </div>
                <div class="card" style="padding:18px">
                    <div style="font-size:13px;font-weight:500;margin-bottom:14px">Platform Status</div>
                    <div style="display:flex;flex-direction:column;gap:10px">
                        <div style="display:flex;justify-content:space-between;font-size:13px;align-items:center">
                            <span style="color:var(--ink-mute)">Total Users</span>
                            <span style="font-family:var(--font-display);font-size:18px"><%= users.size() %></span>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;align-items:center">
                            <span style="color:var(--ink-mute)">Bots</span>
                            <span style="font-family:var(--font-display);font-size:18px"><%= bots.size() %></span>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;align-items:center">
                            <span style="color:var(--ink-mute)">Preset Armies</span>
                            <span style="font-family:var(--font-display);font-size:18px"><%= presetArmies.size() %></span>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;align-items:center">
                            <span style="color:var(--ink-mute)">Banned Players</span>
                            <span style="font-family:var(--font-display);font-size:18px;color:var(--crimson)"><%= bannedCount %></span>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;align-items:center">
                            <span style="color:var(--ink-mute)">Open Reports</span>
                            <span style="font-family:var(--font-display);font-size:18px;color:var(--amber)"><%= openReportsCount %></span>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- ── USERS TAB ─────────────────────────────────────────────── -->
            <% if ("users".equals(curTab)) { %>
            <div class="admin-section">
                <div class="admin-section-header">
                    <h2 class="admin-section-title">Users</h2>
                    <div class="admin-section-controls">
                        <input type="text" id="userSearch" class="form-input" style="max-width:240px" placeholder="Search users…" oninput="filterTable('userSearch','usersTable')">
                    </div>
                </div>
                <% if (users.isEmpty()) { %>
                <div class="admin-empty">No users found.</div>
                <% } else { %>
                <div class="table-wrap" style="overflow:auto">
                <table class="admin-table" id="usersTable">
                    <thead><tr><th>#</th><th>Username</th><th>Email</th><th>ELO</th><th>KP</th><th>Role</th><th>Status</th><th>Joined</th><th>Actions</th></tr></thead>
                    <tbody>
                    <% for (User u : users) {
                        boolean isBanned      = u.isBanned();
                        boolean isOwnerUser   = u.isOwner();
                        boolean isCoOwnerUser = u.isCoOwner();
                        boolean isAdminUser   = u.getRole() == UserRole.ADMIN;
                        boolean isElevated    = u.isAdmin(); // any elevated role
                        boolean isCurrentUser = u.getId().equals(currentUserId);
                        String  profilePic    = u.getProfilePicPath();

                        // Permission flags for this row
                        boolean canBan = !isCurrentUser && !isOwnerUser
                            && (viewerIsOwner || viewerIsCoOwner || !isElevated);
                        boolean canToggleAdmin   = !isCurrentUser && !isOwnerUser && (viewerIsOwner || viewerIsCoOwner);
                        boolean canToggleCoOwner = !isCurrentUser && !isOwnerUser && viewerIsOwner;
                    %>
                    <tr>
                        <td style="color:var(--ink-faint);font-family:var(--font-mono);font-size:11px"><%= u.getId() %></td>
                        <td>
                            <div style="display:flex;align-items:center;gap:8px">
                                <div class="avatar" style="width:32px;height:32px;font-size:12px;flex-shrink:0;<% if (profilePic != null && !profilePic.isEmpty()) { %>border-radius:50%;overflow:hidden;background:none;padding:0;<% } %>">
                                    <% if (profilePic != null && !profilePic.isEmpty()) { %>
                                    <img src="${pageContext.request.contextPath}/<%= esc(profilePic) %>" style="width:100%;height:100%;object-fit:cover;display:block;border-radius:50%" alt="<%= esc(u.getUsername()) %>">
                                    <% } else { %>
                                    <%= u.getUsername() != null && !u.getUsername().isEmpty() ? String.valueOf(u.getUsername().charAt(0)).toUpperCase() : "?" %>
                                    <% } %>
                                </div>
                                <span style="font-weight:500"><%= esc(u.getUsername()) %></span>
                                <% if (isCurrentUser) { %><span class="tag" style="font-size:9px">you</span><% } %>
                            </div>
                        </td>
                        <td style="color:var(--ink-mute);font-size:12px"><%= esc(u.getEmail()) %></td>
                        <td style="font-family:var(--font-mono)"><%= u.getElo() %></td>
                        <td style="font-family:var(--font-mono)"><%= u.getKnowledgePoints() %></td>
                        <td>
                            <% if (isOwnerUser) { %><span class="tag" style="color:#e8b04b;border-color:rgba(232,176,75,.4);font-weight:600">Owner</span>
                            <% } else if (isCoOwnerUser) { %><span class="tag" style="color:#b07de0;border-color:rgba(176,125,224,.4)">Co-Owner</span>
                            <% } else if (isAdminUser) { %><span class="tag" style="color:var(--amber);border-color:rgba(212,164,74,.3)">Admin</span>
                            <% } else { %><span class="tag">Player</span><% } %>
                        </td>
                        <td>
                            <% if (isBanned) { %><span class="tag" style="color:var(--crimson);border-color:rgba(200,85,61,.3)">Banned</span>
                            <% } else { %><span class="tag" style="color:var(--moss);border-color:rgba(122,148,97,.3)">Active</span><% } %>
                        </td>
                        <td style="color:var(--ink-faint);font-size:12px"><%= u.getCreatedAt() != null ? u.getCreatedAt().toLocalDate().toString() : "—" %></td>
                        <td>
                            <div style="display:flex;gap:4px;flex-wrap:wrap">
                                <button type="button" class="admin-toggle-btn" onclick="openEditModal(<%= u.getId() %>,'<%= esc(u.getUsername()) %>','<%= esc(u.getEmail()) %>')">Edit</button>

                                <% if (canBan) { %>
                                <button type="button" class="admin-toggle-btn <%= isBanned ? "" : "danger" %>"
                                    onclick="openBanReasonModal(<%= u.getId() %>,'<%= esc(u.getUsername()) %>',<%= isBanned %>)">
                                    <%= isBanned ? "Unban" : "Ban" %>
                                </button>
                                <% } %>

                                <% if (canToggleAdmin) { %>
                                    <% if (isCoOwnerUser) { /* co-owner: no admin toggle, use co-owner toggle instead */ %>
                                    <% } else if (isAdminUser) { %>
                                    <form method="POST" action="${pageContext.request.contextPath}/adminToggleAdmin" style="display:inline">
                                        <input type="hidden" name="toggleAdminId" value="<%= u.getId() %>">
                                        <input type="hidden" name="toggleAdminValue" value="false">
                                        <button type="submit" class="admin-toggle-btn danger">Remove Admin</button>
                                    </form>
                                    <% } else { %>
                                    <form method="POST" action="${pageContext.request.contextPath}/adminToggleAdmin" style="display:inline">
                                        <input type="hidden" name="toggleAdminId" value="<%= u.getId() %>">
                                        <input type="hidden" name="toggleAdminValue" value="true">
                                        <button type="submit" class="admin-toggle-btn">Make Admin</button>
                                    </form>
                                    <% } %>
                                <% } %>

                                <% if (canToggleCoOwner) { %>
                                    <% if (isCoOwnerUser) { %>
                                    <form method="POST" action="${pageContext.request.contextPath}/adminToggleCoOwner" style="display:inline">
                                        <input type="hidden" name="toggleCoOwnerId" value="<%= u.getId() %>">
                                        <input type="hidden" name="toggleCoOwnerValue" value="false">
                                        <button type="submit" class="admin-toggle-btn danger">Remove Co-Owner</button>
                                    </form>
                                    <% } else if (isAdminUser) { %>
                                    <form method="POST" action="${pageContext.request.contextPath}/adminToggleCoOwner" style="display:inline">
                                        <input type="hidden" name="toggleCoOwnerId" value="<%= u.getId() %>">
                                        <input type="hidden" name="toggleCoOwnerValue" value="true">
                                        <button type="submit" class="admin-toggle-btn" style="color:var(--amber);border-color:rgba(176,125,224,.3)">Make Co-Owner</button>
                                    </form>
                                    <% } %>
                                <% } %>

                                <button type="button" class="admin-toggle-btn" onclick="openAcademyModal(<%= u.getId() %>,'<%= esc(u.getUsername()) %>',<%= u.getKnowledgePoints() %>,'<%= u.getUnlockedPieces() != null ? esc(u.getUnlockedPieces()) : "" %>')">Academy</button>
                                <form method="POST" action="${pageContext.request.contextPath}/adminSendPasswordReset" style="display:inline">
                                    <input type="hidden" name="resetUserId" value="<%= u.getId() %>">
                                    <button type="submit" class="admin-toggle-btn">Reset PW</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                </div>
                <div class="admin-paginator" id="usersTable-paginator"></div>
                <% } %>
            </div>
            <% } %>

            <!-- ── BOTS TAB ──────────────────────────────────────────────── -->
            <% if ("bots".equals(curTab)) { %>
            <div class="admin-section">
                <div class="admin-section-header">
                    <h2 class="admin-section-title">Bots</h2>
                    <div class="admin-section-controls">
                        <input type="text" id="botSearch" class="form-input" style="max-width:200px" placeholder="Search bots…" oninput="filterTable('botSearch','botsTable')">
                        <button type="button" class="btn primary sm" onclick="openCreateBotModal()">+ New Bot</button>
                    </div>
                </div>
                <% if (bots.isEmpty()) { %>
                <div class="admin-empty">No bots found. Create one to get started.</div>
                <% } else { %>
                <div class="table-wrap" style="overflow:auto">
                <table class="admin-table" id="botsTable">
                    <thead><tr><th>Portrait</th><th>Name</th><th>ELO</th><th>Collection</th><th>Armies</th><th>Actions</th></tr></thead>
                    <tbody>
                    <% for (Bot bot : bots) { %>
                    <tr>
                        <td style="width:48px">
                            <% if (bot.getImagePath() != null) { %>
                            <img src="${pageContext.request.contextPath}/<%= esc(bot.getImagePath()) %>" style="width:40px;height:40px;border-radius:6px;object-fit:cover" alt="">
                            <% } else { %>
                            <div style="width:40px;height:40px;border-radius:6px;background:var(--bg-elev-2);display:flex;align-items:center;justify-content:center;font-size:20px">♟</div>
                            <% } %>
                        </td>
                        <td style="font-weight:500"><%= esc(bot.getName()) %></td>
                        <td style="font-family:var(--font-mono)"><%= bot.getElo() %></td>
                        <td style="color:var(--ink-mute)"><%= bot.getCollection() != null && !bot.getCollection().isBlank() ? esc(bot.getCollection()) : "—" %></td>
                        <td style="font-family:var(--font-mono)"><%= bot.getArmies().size() %></td>
                        <td>
                            <div style="display:flex;gap:4px">
                                <button type="button" class="admin-toggle-btn" onclick="openEditBotModal(<%= bot.getId() %>)">Edit</button>
                                <form method="POST" action="${pageContext.request.contextPath}/adminDeleteBot" style="display:inline"
                                    onsubmit="return confirm('Delete bot \'<%= esc(bot.getName()) %>\'?')">
                                    <input type="hidden" name="botId" value="<%= bot.getId() %>">
                                    <button type="submit" class="admin-toggle-btn danger">Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                </div>
                <div class="admin-paginator" id="botsTable-paginator"></div>
                <% } %>
            </div>
            <% } %>

            <!-- ── MATCHES TAB ───────────────────────────────────────────── -->
            <% if ("matches".equals(curTab)) { %>
            <div class="admin-section">
                <div class="admin-section-header">
                    <h2 class="admin-section-title">Match Records</h2>
                    <div class="admin-section-controls">
                        <input type="text" id="matchSearch" class="form-input" style="max-width:220px" placeholder="Search…" oninput="filterTable('matchSearch','matchesTable')">
                    </div>
                </div>
                <% if (matchRecords.isEmpty()) { %>
                <div class="admin-empty">No match records yet.</div>
                <% } else { %>
                <div class="table-wrap" style="overflow:auto">
                <table class="admin-table" id="matchesTable">
                    <thead><tr><th>#</th><th>White</th><th>Black</th><th>Result</th><th>Variant</th><th>Duration</th><th>Moves</th><th>Date</th><th>Flag</th></tr></thead>
                    <tbody>
                    <% for (MatchRecord mr : matchRecords) { %>
                    <tr>
                        <td style="font-family:var(--font-mono);font-size:11px;color:var(--ink-faint)"><%= mr.getId() %></td>
                        <td><%= esc(mr.getWhiteUsername() != null ? mr.getWhiteUsername() : "—") %></td>
                        <td><%= esc(mr.getBlackUsername() != null ? mr.getBlackUsername() : "—") %></td>
                        <td style="font-family:var(--font-mono);font-weight:500">
                            <% String r = mr.getResult(); if("1-0".equals(r)){%><span style="color:var(--moss)"><%}else if("0-1".equals(r)){%><span style="color:var(--crimson)"><%}else{%><span style="color:var(--ink-faint)"><%}%><%= esc(r) %></span>
                        </td>
                        <td style="color:var(--ink-mute)"><%= esc(mr.getVariant() != null ? mr.getVariant() : "—") %></td>
                        <td style="font-family:var(--font-mono);font-size:12px"><%= mr.getFormattedDuration() %></td>
                        <td style="font-family:var(--font-mono)"><%= mr.getMoveCount() %></td>
                        <td style="color:var(--ink-faint);font-size:12px"><%= mr.getPlayedAt() != null ? mr.getPlayedAt().toLocalDate().toString() : "—" %></td>
                        <td>
                            <form method="POST" action="${pageContext.request.contextPath}/adminFlagMatch" style="display:inline">
                                <input type="hidden" name="matchId" value="<%= mr.getId() %>">
                                <input type="hidden" name="flagged" value="<%= !mr.isFlagged() %>">
                                <button type="submit" class="admin-toggle-btn <%= mr.isFlagged() ? "danger" : "" %>">
                                    <%= mr.isFlagged() ? "⚑ Flagged" : "Flag" %>
                                </button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                </div>
                <div class="admin-paginator" id="matchesTable-paginator"></div>
                <% } %>
            </div>
            <% } %>

            <!-- ── REPORTS TAB ───────────────────────────────────────────── -->
            <% if ("reports".equals(curTab)) { %>
            <div style="display:flex;flex-direction:column;gap:24px">
                <!-- Player Reports -->
                <div class="admin-section">
                    <div class="admin-section-header">
                        <h2 class="admin-section-title">Player Reports</h2>
                    </div>
                    <% if (playerReports.isEmpty()) { %>
                    <div class="admin-empty">No player reports.</div>
                    <% } else { %>
                    <div class="table-wrap" style="overflow:auto">
                    <table class="admin-table">
                        <thead><tr><th>#</th><th>Reporter</th><th>Target</th><th>Reason</th><th>State</th><th>Date</th><th>Actions</th></tr></thead>
                        <tbody>
                        <% for (PlayerReport pr : playerReports) { %>
                        <tr>
                            <td style="font-family:var(--font-mono);font-size:11px;color:var(--ink-faint)"><%= pr.getId() %></td>
                            <td><%= esc(pr.getReporterUsername() != null ? pr.getReporterUsername() : "—") %></td>
                            <td style="font-weight:500"><%= esc(pr.getTargetUsername() != null ? pr.getTargetUsername() : "—") %></td>
                            <td><%= esc(pr.getReason() != null ? pr.getReason() : "—") %></td>
                            <td>
                                <% String state = pr.getState() != null ? pr.getState() : "open"; %>
                                <span class="tag" style="<%= "resolved".equals(state) ? "color:var(--moss);border-color:rgba(122,148,97,.3)" : "open".equals(state) ? "color:var(--amber);border-color:rgba(212,164,74,.3)" : "" %>"><%= state %></span>
                            </td>
                            <td style="font-size:12px;color:var(--ink-faint)"><%= pr.getCreatedAt() != null ? pr.getCreatedAt().toLocalDate().toString() : "—" %></td>
                            <td>
                                <div style="display:flex;gap:4px;flex-wrap:wrap">
                                    <% if (!"review".equals(pr.getState())) { %>
                                    <form method="POST" action="${pageContext.request.contextPath}/adminUpdateReport" style="display:inline">
                                        <input type="hidden" name="reportId" value="<%= pr.getId() %>">
                                        <input type="hidden" name="state" value="review">
                                        <button type="submit" class="admin-toggle-btn">Review</button>
                                    </form>
                                    <% } %>
                                    <% if (!"resolved".equals(pr.getState())) { %>
                                    <form method="POST" action="${pageContext.request.contextPath}/adminUpdateReport" style="display:inline">
                                        <input type="hidden" name="reportId" value="<%= pr.getId() %>">
                                        <input type="hidden" name="state" value="resolved">
                                        <button type="submit" class="admin-toggle-btn">Resolve</button>
                                    </form>
                                    <% } %>
                                    <% if (!"open".equals(pr.getState())) { %>
                                    <form method="POST" action="${pageContext.request.contextPath}/adminUpdateReport" style="display:inline">
                                        <input type="hidden" name="reportId" value="<%= pr.getId() %>">
                                        <input type="hidden" name="state" value="open">
                                        <button type="submit" class="admin-toggle-btn">Reopen</button>
                                    </form>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                    </div>
                    <% } %>
                </div>

                <!-- Support Tickets -->
                <div class="admin-section">
                    <div class="admin-section-header">
                        <h2 class="admin-section-title">Support Tickets</h2>
                        <a href="${pageContext.request.contextPath}/adminTickets" class="btn sm">Full View →</a>
                    </div>
                    <% if (supportTickets.isEmpty()) { %>
                    <div class="admin-empty">No support tickets.</div>
                    <% } else { %>
                    <div class="table-wrap" style="overflow:auto">
                    <table class="admin-table">
                        <thead><tr><th>#</th><th>Subject</th><th>From</th><th>Status</th><th>Claimed By</th><th>Date</th></tr></thead>
                        <tbody>
                        <% for (SupportTicket st : supportTickets) { %>
                        <tr>
                            <td style="font-family:var(--font-mono);font-size:11px;color:var(--ink-faint)"><%= st.getId() %></td>
                            <td style="font-weight:500;max-width:240px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><%= esc(st.getTitle() != null ? st.getTitle() : "—") %></td>
                            <td style="color:var(--ink-mute);font-size:12px"><%= esc(st.getUserEmail() != null ? st.getUserEmail() : "—") %></td>
                            <td>
                                <% String ts = st.getStatus() != null ? st.getStatus() : "OPEN"; %>
                                <span class="tag" style="<%= "CLOSED".equals(ts) ? "color:var(--ink-faint)" : "CLAIMED".equals(ts) ? "color:var(--amber);border-color:rgba(212,164,74,.3)" : "color:var(--moss);border-color:rgba(122,148,97,.3)" %>"><%= ts %></span>
                            </td>
                            <td style="color:var(--ink-mute);font-size:12px"><%= st.getClaimedBy() != null ? esc(st.getClaimedBy().getUsername()) : "—" %></td>
                            <td style="font-size:12px;color:var(--ink-faint)"><%= st.getCreatedAt() != null ? st.getCreatedAt().atZone(java.time.ZoneId.systemDefault()).toLocalDate().toString() : "—" %></td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } %>

            <!-- ── SETTINGS TAB ──────────────────────────────────────────── -->
            <% if ("settings".equals(curTab)) { %>
            <div class="admin-section">
                <div class="admin-section-header">
                    <h2 class="admin-section-title">Platform Settings</h2>
                </div>
                <% if (platformSettings.isEmpty()) { %>
                <div class="admin-empty">No platform settings loaded.</div>
                <% } else { %>
                <div style="display:flex;flex-direction:column;gap:0">
                <% for (PlatformSetting ps : platformSettings) {
                    boolean isToggle = "true".equalsIgnoreCase(ps.getValue()) || "false".equalsIgnoreCase(ps.getValue());
                %>
                <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:16px;padding:14px 16px;border:1px solid var(--line);border-top:0;background:var(--bg-elev);<% if(platformSettings.indexOf(ps)==0){%>border-top:1px solid var(--line);border-radius:6px 6px 0 0;<%}if(platformSettings.indexOf(ps)==platformSettings.size()-1){%>border-radius:0 0 6px 6px;<%}%>">
                    <div style="flex:1;min-width:0">
                        <div style="font-family:var(--font-mono);font-size:12px;font-weight:500;color:var(--ink)"><%= esc(ps.getKey()) %></div>
                        <div style="font-size:12px;color:var(--ink-faint);margin-top:2px"><%= esc(ps.getDescription() != null ? ps.getDescription() : "") %></div>
                    </div>
                    <% if (isToggle) { %>
                    <form method="POST" action="${pageContext.request.contextPath}/adminSaveSetting" style="display:flex;align-items:center;gap:8px">
                        <input type="hidden" name="settingKey" value="<%= esc(ps.getKey()) %>">
                        <input type="hidden" name="settingValue" value="<%= ps.isEnabled() ? "false" : "true" %>">
                        <span style="font-family:var(--font-mono);font-size:11px;color:var(--ink-faint)"><%= ps.isEnabled() ? "ON" : "OFF" %></span>
                        <button type="submit" class="toggle-switch <%= ps.isEnabled() ? "on" : "" %>">
                            <div class="toggle-thumb"></div>
                        </button>
                    </form>
                    <% } else { %>
                    <form method="POST" action="${pageContext.request.contextPath}/adminSaveSetting" style="display:flex;align-items:center;gap:8px">
                        <input type="hidden" name="settingKey" value="<%= esc(ps.getKey()) %>">
                        <input type="text" name="settingValue" value="<%= esc(ps.getValue()) %>" class="form-input" style="width:140px">
                        <button type="submit" class="btn sm">Save</button>
                    </form>
                    <% } %>
                </div>
                <% } %>
                </div>
                <% } %>
            </div>

            <% if (viewerIsOwner) { %>
            <div class="admin-section" style="margin-top:16px">
                <div class="admin-section-header">
                    <h2 class="admin-section-title">Policy Update Notification</h2>
                    <span class="tag" style="color:var(--amber);border-color:rgba(212,164,74,.3);font-size:10px">Owner Only</span>
                </div>
                <div style="padding:16px;background:var(--bg-elev);border:1px solid var(--line);border-radius:6px">
                    <div style="font-size:13px;color:var(--ink-faint);margin-bottom:14px">Send an email to all registered users notifying them that a policy has been updated.</div>
                    <form method="POST" action="${pageContext.request.contextPath}/adminSendPolicyEmail" style="display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end">
                        <div style="display:flex;flex-direction:column;gap:4px;min-width:180px">
                            <label style="font-size:11px;color:var(--ink-faint);font-family:var(--font-mono)">Policy</label>
                            <select name="policyType" class="form-input" style="width:180px">
                                <option value="privacy">Privacy Policy</option>
                                <option value="terms">Terms of Service</option>
                            </select>
                        </div>
                        <div style="display:flex;flex-direction:column;gap:4px;flex:1;min-width:220px">
                            <label style="font-size:11px;color:var(--ink-faint);font-family:var(--font-mono)">Link to Policy</label>
                            <input type="url" name="policyLink" class="form-input" placeholder="https://..." required style="width:100%">
                        </div>
                        <button type="submit" class="btn primary" onclick="return confirm('Send policy update email to ALL users?')">Send to All Users</button>
                    </form>
                </div>
            </div>
            <% } %>
            <% } %>

            <!-- ── BAN LOGS TAB ──────────────────────────────────────────── -->
            <% if ("banlogs".equals(curTab)) { %>
            <div class="admin-section">
                <div class="admin-section-header">
                    <h2 class="admin-section-title">Ban Logs</h2>
                </div>
                <% if (banLogs.isEmpty()) { %>
                <div class="admin-empty">No ban log entries.</div>
                <% } else { %>
                <div class="table-wrap" style="overflow:auto">
                <table class="admin-table">
                    <thead><tr><th>#</th><th>Player</th><th>Action</th><th>Reason</th><th>By Admin</th><th>Date</th></tr></thead>
                    <tbody>
                    <% for (BanLog bl : banLogs) { %>
                    <tr>
                        <td style="font-family:var(--font-mono);font-size:11px;color:var(--ink-faint)"><%= bl.getId() %></td>
                        <td style="font-weight:500"><%= esc(bl.getTargetUsername() != null ? bl.getTargetUsername() : "—") %></td>
                        <td>
                            <span class="tag" style="<%= "BAN".equals(bl.getAction()) ? "color:var(--crimson);border-color:rgba(200,85,61,.3)" : "color:var(--moss);border-color:rgba(122,148,97,.3)" %>">
                                <%= "BAN".equals(bl.getAction()) ? "Banned" : "Unbanned" %>
                            </span>
                        </td>
                        <td style="max-width:280px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--ink-mute)"><%= esc(bl.getReason() != null ? bl.getReason() : "—") %></td>
                        <td style="color:var(--ink-mute)"><%= esc(bl.getAdminUsername() != null ? bl.getAdminUsername() : "—") %></td>
                        <td style="font-size:12px;color:var(--ink-faint)"><%= bl.getCreatedAt() != null ? bl.getCreatedAt().toLocalDate().toString() : "—" %></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
    </main>
</div>

<!-- ── Modals ─────────────────────────────────────────────────────────────── -->
<div class="modal-overlay" id="banReasonModal" style="display:none">
    <div class="modal-box" style="max-width:440px">
        <div class="modal-header-row">
            <div class="modal-title" id="banReasonTitle">Ban Player</div>
            <button class="modal-close-btn" onclick="closeBanReasonModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/adminBanUser" id="banReasonForm">
            <input type="hidden" name="banUserId" id="banReasonUserId">
            <input type="hidden" name="banValue" id="banReasonValue">
            <div class="form-group" style="margin-top:8px">
                <label class="form-label" id="banReasonLabel">Ban Reason (shown to the player)</label>
                <textarea name="banReason" id="banReasonText" class="form-input" rows="3" maxlength="500" placeholder="Enter a reason..." style="resize:vertical"></textarea>
            </div>
            <div style="display:flex;gap:8px;margin-top:4px">
                <button type="submit" class="btn danger" style="flex:1" id="banReasonSubmitBtn">Ban Player</button>
                <button type="button" class="btn" onclick="closeBanReasonModal()" style="flex:1">Cancel</button>
            </div>
        </form>
    </div>
</div>

<div class="modal-overlay" id="editUserModal" style="display:none">
    <div class="modal-box" style="max-width:420px">
        <div class="modal-header-row">
            <div class="modal-title">Edit User</div>
            <button class="modal-close-btn" onclick="closeEditModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/adminEditUser" id="editUserForm">
            <input type="hidden" name="editUserId" id="editUserId">
            <div class="form-group" style="margin-top:8px">
                <label class="form-label">Username</label>
                <input type="text" name="editUsername" id="editUsername" class="form-input" maxlength="50" placeholder="Leave blank to keep unchanged">
            </div>
            <div class="form-group">
                <label class="form-label">Email</label>
                <input type="email" name="editEmail" id="editEmail" class="form-input" maxlength="100" placeholder="Leave blank to keep unchanged">
            </div>
            <div class="form-group">
                <label class="form-label">New Password</label>
                <input type="password" name="editPassword" id="editPassword" class="form-input" placeholder="Leave blank to keep unchanged">
            </div>
            <div style="display:flex;gap:8px;margin-top:4px">
                <button type="submit" class="btn primary" style="flex:1">Save Changes</button>
                <button type="button" class="btn" onclick="closeEditModal()" style="flex:1">Cancel</button>
            </div>
        </form>
    </div>
</div>

<div class="modal-overlay" id="createBotModal" style="display:none">
    <div class="modal-box" style="max-width:420px">
        <div class="modal-header-row">
            <div class="modal-title">New Bot</div>
            <button class="modal-close-btn" onclick="closeCreateBotModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/adminCreateBot">
            <div class="form-group" style="margin-top:8px">
                <label class="form-label">Name</label>
                <input type="text" name="botName" class="form-input" required maxlength="100" placeholder="Bot name">
            </div>
            <div class="form-group">
                <label class="form-label">Elo</label>
                <input type="number" name="botElo" class="form-input" value="800" min="0" max="9999">
            </div>
            <div class="form-group">
                <label class="form-label">Collection</label>
                <input type="text" name="botCollection" class="form-input" list="collectionList" maxlength="100" placeholder="e.g. Beginner, Intermediate">
            </div>
            <div style="display:flex;gap:8px;margin-top:4px">
                <button type="submit" class="btn primary" style="flex:1">Create Bot</button>
                <button type="button" class="btn" onclick="closeCreateBotModal()" style="flex:1">Cancel</button>
            </div>
        </form>
    </div>
</div>
<datalist id="collectionList">
    <% for (String col : existingCollections) { %><option value="<%= esc(col) %>"><% } %>
</datalist>

<div class="modal-overlay" id="editBotModal" style="display:none">
    <div class="modal-box" style="max-width:580px;max-height:88vh;overflow-y:auto">
        <div class="modal-header-row" style="position:sticky;top:0;background:var(--bg-elev);z-index:1;padding-bottom:8px">
            <div class="modal-title">Edit Bot</div>
            <button class="modal-close-btn" onclick="closeEditBotModal()">&times;</button>
        </div>
        <div id="botImageSection" style="display:flex;align-items:center;gap:16px;margin:12px 0 16px">
            <div id="botCurrentImage" style="width:72px;height:72px;border-radius:8px;background:var(--bg-elev-2);display:flex;align-items:center;justify-content:center;overflow:hidden;flex-shrink:0;border:1px solid var(--line)">
                <span style="font-size:32px">♟</span>
            </div>
            <form method="POST" action="${pageContext.request.contextPath}/adminUploadBotImage" enctype="multipart/form-data" style="flex:1">
                <input type="hidden" name="botId" id="uploadBotId">
                <label class="form-label" style="margin-bottom:4px;display:block">Bot Portrait (PNG/JPG)</label>
                <div style="display:flex;gap:6px">
                    <input type="file" name="botImage" accept="image/*" class="form-input" style="flex:1;padding:5px">
                    <button type="submit" class="btn sm">Upload</button>
                </div>
            </form>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/adminSaveBot">
            <input type="hidden" name="botId" id="editBotId">
            <div style="display:grid;grid-template-columns:1fr 120px;gap:10px">
                <div class="form-group" style="margin-bottom:0">
                    <label class="form-label">Name</label>
                    <input type="text" name="botName" id="editBotName" class="form-input" required maxlength="100">
                </div>
                <div class="form-group" style="margin-bottom:0">
                    <label class="form-label">Elo</label>
                    <input type="number" name="botElo" id="editBotElo" class="form-input" min="0" max="9999">
                </div>
            </div>
            <div class="form-group" style="margin-top:10px">
                <label class="form-label">Collection</label>
                <input type="text" name="botCollection" id="editBotCollection" class="form-input" list="collectionList" maxlength="100">
            </div>
            <%-- Voicelines / script lines --%>
            <% String[][] lineGroups = {
                {"Idle Lines","editBotVoicelines","voicelines"},
                {"G0 Take Lines","editBotG0Lines","g0capture"},
                {"G1 Take Lines","editBotG1Lines","g1capture"},
                {"G2 Take Lines","editBotG2Lines","g2capture"},
                {"G0 Capture Lines","editBotG0TakeLines","g0take"},
                {"G1 Capture Lines","editBotG1TakeLines","g1take"},
                {"G2 Capture Lines","editBotG2TakeLines","g2take"},
                {"Win Lines","editBotWinLines","winLines"},
                {"Lose Lines","editBotLoseLines","loseLines"}
            }; %>
            <% for (String[] grp : lineGroups) { %>
            <div style="margin-top:12px">
                <div style="font-size:11px;text-transform:uppercase;letter-spacing:.08em;color:var(--ink-faint);font-weight:500;margin-bottom:6px"><%= grp[0] %></div>
                <div id="<%= grp[1] %>" data-field="<%= grp[2] %>"></div>
                <button type="button" class="btn sm ghost" onclick="addLine('<%= grp[1] %>')">+ Add Line</button>
            </div>
            <% } %>
            <hr style="border:none;border-top:1px solid var(--line);margin:14px 0 10px">
            <div style="font-size:11px;text-transform:uppercase;letter-spacing:.08em;color:var(--ink-faint);font-weight:500;margin-bottom:8px">Available Armies</div>
            <div class="form-group">
                <% if (presetArmies.isEmpty()) { %>
                <div style="color:var(--ink-faint);font-size:13px">No preset armies yet.</div>
                <% } else { %>
                <div style="display:flex;flex-direction:column;gap:6px">
                    <% for (Army army : presetArmies) { %>
                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:13px">
                        <input type="checkbox" name="botArmyIds" value="<%= army.getId() %>" class="bot-army-checkbox">
                        <span><%= esc(army.getName()) %> <span style="color:var(--ink-faint);font-size:11px">(<%= esc(army.getTeam()) %>)</span></span>
                    </label>
                    <% } %>
                </div>
                <% } %>
            </div>
            <div style="display:flex;gap:8px;margin-top:12px;position:sticky;bottom:0;background:var(--bg-elev);padding-top:8px">
                <button type="submit" class="btn primary" style="flex:1">Save Changes</button>
                <button type="button" class="btn danger" onclick="closeEditBotModal()" style="flex:1">Cancel</button>
            </div>
        </form>
    </div>
</div>

<div class="modal-overlay" id="academyModal" style="display:none">
    <div class="modal-box" style="max-width:500px;max-height:88vh;overflow-y:auto">
        <div class="modal-header-row">
            <div class="modal-title">Academy — <span id="acadModalUser"></span></div>
            <button class="modal-close-btn" onclick="closeAcademyModal()">&times;</button>
        </div>
        <div style="margin-top:16px">
            <div style="font-size:11px;text-transform:uppercase;letter-spacing:.08em;color:var(--ink-faint);margin-bottom:8px">Knowledge Points</div>
            <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px">
                <span style="font-size:14px;color:var(--ink-mute)">Current KP:</span>
                <span id="acadCurrentKP" style="font-size:20px;font-family:var(--font-display);color:var(--amber)"></span>
            </div>
            <div style="display:flex;gap:8px;align-items:center">
                <input type="number" id="acadKpAmount" class="form-input" value="10" min="1" max="9999" style="width:100px">
                <button class="btn primary sm" onclick="doAcadKP(1)" style="flex:1">+ Give KP</button>
                <button class="btn danger sm" onclick="doAcadKP(-1)" style="flex:1">− Remove KP</button>
            </div>
        </div>
        <hr style="border:none;border-top:1px solid var(--line);margin:16px 0 12px">
        <div>
            <div style="font-size:11px;text-transform:uppercase;letter-spacing:.08em;color:var(--ink-faint);margin-bottom:10px">Piece Unlocks</div>
            <div id="acadUnlockList" style="display:grid;grid-template-columns:repeat(2,1fr);gap:6px;margin-bottom:14px"></div>
            <button class="btn primary sm" onclick="doAcadSaveUnlocks()" style="width:100%">Save Piece Unlocks</button>
        </div>
        <div id="acadModalMsg" style="margin-top:10px;font-size:13px;text-align:center;min-height:20px;color:var(--moss)"></div>
    </div>
</div>

<script>
var CTX = "${pageContext.request.contextPath}";
var botRegistry = {};
<%
try {
    for (Bot bot : bots) {
%>
botRegistry[<%= bot.getId() %>] = {
    name: <%= jsonMapper.writeValueAsString(bot.getName()) %>,
    elo: <%= bot.getElo() %>,
    collection: <%= jsonMapper.writeValueAsString(bot.getCollection() != null ? bot.getCollection() : "") %>,
    imagePath: <%= jsonMapper.writeValueAsString(bot.getImagePath() != null ? bot.getImagePath() : "") %>,
    voicelines: <%= jsonMapper.writeValueAsString(bot.getVoicelines()) %>,
    g0: <%= jsonMapper.writeValueAsString(bot.getG0CaptureLines()) %>,
    g1: <%= jsonMapper.writeValueAsString(bot.getG1CaptureLines()) %>,
    g2: <%= jsonMapper.writeValueAsString(bot.getG2CaptureLines()) %>,
    g0take: <%= jsonMapper.writeValueAsString(bot.getG0TakeLines()) %>,
    g1take: <%= jsonMapper.writeValueAsString(bot.getG1TakeLines()) %>,
    g2take: <%= jsonMapper.writeValueAsString(bot.getG2TakeLines()) %>,
    winLines: <%= jsonMapper.writeValueAsString(bot.getWinLines()) %>,
    loseLines: <%= jsonMapper.writeValueAsString(bot.getLoseLines()) %>,
    armyIds: [<% List<Army> ba = bot.getArmies(); for (int i=0; i<ba.size(); i++) { if(i>0)out.print(","); out.print(ba.get(i).getId()); } %>]
};
<%  }
} catch (Exception e) { /* serialization failed */ }
%>

function openBanReasonModal(id, username, currentlyBanned) {
    document.getElementById('banReasonUserId').value = id;
    document.getElementById('banReasonValue').value = !currentlyBanned;
    document.getElementById('banReasonText').value = '';
    if (currentlyBanned) {
        document.getElementById('banReasonTitle').textContent = 'Unban Player: ' + username;
        document.getElementById('banReasonLabel').textContent = 'Unban Reason (optional note)';
        document.getElementById('banReasonSubmitBtn').textContent = 'Unban Player';
        document.getElementById('banReasonSubmitBtn').className = 'btn primary';
    } else {
        document.getElementById('banReasonTitle').textContent = 'Ban Player: ' + username;
        document.getElementById('banReasonLabel').textContent = 'Ban Reason (shown to the player)';
        document.getElementById('banReasonSubmitBtn').textContent = 'Ban Player';
        document.getElementById('banReasonSubmitBtn').className = 'btn danger';
    }
    document.getElementById('banReasonModal').style.display = 'flex';
}
function closeBanReasonModal() { document.getElementById('banReasonModal').style.display = 'none'; }
document.getElementById('banReasonModal').addEventListener('click', function(e) { if(e.target===this) closeBanReasonModal(); });

function openEditModal(id, username, email) {
    document.getElementById('editUserId').value = id;
    document.getElementById('editUsername').value = username;
    document.getElementById('editEmail').value = email;
    document.getElementById('editPassword').value = '';
    document.getElementById('editUserModal').style.display = 'flex';
}
function closeEditModal() { document.getElementById('editUserModal').style.display = 'none'; }
document.getElementById('editUserModal').addEventListener('click', function(e) { if(e.target===this) closeEditModal(); });

function openCreateBotModal() { document.getElementById('createBotModal').style.display = 'flex'; }
function closeCreateBotModal() { document.getElementById('createBotModal').style.display = 'none'; }
document.getElementById('createBotModal').addEventListener('click', function(e) { if(e.target===this) closeCreateBotModal(); });

function openEditBotModal(id) {
    var data = botRegistry[id];
    if (!data) return;
    document.getElementById('editBotId').value = id;
    document.getElementById('uploadBotId').value = id;
    document.getElementById('editBotName').value = data.name;
    document.getElementById('editBotElo').value = data.elo;
    document.getElementById('editBotCollection').value = data.collection || '';
    var imgEl = document.getElementById('botCurrentImage');
    if (data.imagePath) {
        imgEl.innerHTML = '<img src="' + CTX + '/' + data.imagePath + '" style="width:100%;height:100%;object-fit:cover" alt="">';
    } else {
        imgEl.innerHTML = '<span style="font-size:32px">♟</span>';
    }
    renderLines('editBotVoicelines', data.voicelines);
    renderLines('editBotG0Lines', data.g0);
    renderLines('editBotG1Lines', data.g1);
    renderLines('editBotG2Lines', data.g2);
    renderLines('editBotG0TakeLines', data.g0take);
    renderLines('editBotG1TakeLines', data.g1take);
    renderLines('editBotG2TakeLines', data.g2take);
    renderLines('editBotWinLines', data.winLines);
    renderLines('editBotLoseLines', data.loseLines);
    document.querySelectorAll('.bot-army-checkbox').forEach(function(cb) {
        cb.checked = data.armyIds.indexOf(parseInt(cb.value)) !== -1;
    });
    document.getElementById('editBotModal').style.display = 'flex';
    document.getElementById('editBotModal').querySelector('.modal-box').scrollTop = 0;
}
function closeEditBotModal() { document.getElementById('editBotModal').style.display = 'none'; }
document.getElementById('editBotModal').addEventListener('click', function(e) { if(e.target===this) closeEditBotModal(); });

function renderLines(containerId, lines) {
    var container = document.getElementById(containerId);
    container.innerHTML = '';
    if (lines && lines.length > 0) lines.forEach(function(l) { addLine(containerId, l); });
}

var PG_SIZE = 10;
function filterTable(inputId, tableId) {
    var q = document.getElementById(inputId).value.toLowerCase();
    document.querySelectorAll('#' + tableId + ' tbody tr').forEach(function(row) {
        row.classList.toggle('search-hidden', !row.textContent.toLowerCase().includes(q));
    });
    renderPaginator(tableId, 1);
}
function renderPaginator(tableId, page) {
    var rows = Array.from(document.querySelectorAll('#' + tableId + ' tbody tr:not(.search-hidden)'));
    var total = rows.length, totalPages = Math.max(1, Math.ceil(total / PG_SIZE));
    page = Math.min(Math.max(1, page), totalPages);
    rows.forEach(function(row, i) { row.classList.toggle('pg-hidden', i < (page - 1) * PG_SIZE || i >= page * PG_SIZE); });
    var el = document.getElementById(tableId + '-paginator');
    if (!el) return;
    el.innerHTML = '';
    if (totalPages <= 1) return;
    function mkBtn(label, target, disabled, active) {
        var b = document.createElement('button'); b.type = 'button';
        b.className = 'pg-btn' + (active ? ' pg-active' : '') + (disabled ? ' pg-disabled' : '');
        b.textContent = label;
        if (!disabled) b.onclick = function() { renderPaginator(tableId, target); };
        el.appendChild(b);
    }
    mkBtn('‹', page - 1, page === 1, false);
    var start = Math.max(1, page - 2), end = Math.min(totalPages, page + 2);
    if (start > 1) { mkBtn('1', 1, false, false); if (start > 2) { var sp = document.createElement('span'); sp.className = 'pg-ellipsis'; sp.textContent = '…'; el.appendChild(sp); } }
    for (var p = start; p <= end; p++) mkBtn(p, p, false, p === page);
    if (end < totalPages) { if (end < totalPages - 1) { var sp2 = document.createElement('span'); sp2.className = 'pg-ellipsis'; sp2.textContent = '…'; el.appendChild(sp2); } mkBtn(totalPages, totalPages, false, false); }
    mkBtn('›', page + 1, page === totalPages, false);
}
function addLine(containerId, value) {
    var container = document.getElementById(containerId);
    var fieldName = container.dataset.field;
    var div = document.createElement('div'); div.style.cssText = 'display:flex;gap:6px;margin-bottom:6px';
    var input = document.createElement('input'); input.type = 'text'; input.name = fieldName; input.className = 'form-input'; input.style.flex = '1'; input.value = (value !== undefined && value !== null) ? value : '';
    var btn = document.createElement('button'); btn.type = 'button'; btn.className = 'btn sm'; btn.style.cssText = 'padding:4px 10px;min-width:34px'; btn.textContent = '×'; btn.onclick = function() { div.remove(); };
    div.appendChild(input); div.appendChild(btn); container.appendChild(div);
}

var ACAD_PIECES = ['EVIL_PAWN','SQUIRE','LONGPAW','RETREATER','HOLLOW','CRAWLER','JESTER','LANCER','ECLIPSE','DUKE','BEAST_HANDLER','BIRD','SHIELD','PRINCE','CHOIR','EAGLE','COIL','BOOT','FEATHER','WIZARD','HERBALIST','PRINCESS','HUSK','LANTERN','ORACLE','WARDEN','HYDRA','LIBRARY','FORK'];
var currentAcadUserId = null;
var currentAcadKP = 0;
function openAcademyModal(userId, username, kp, unlockedStr) {
    currentAcadUserId = userId; currentAcadKP = kp;
    document.getElementById('acadModalUser').textContent = username;
    document.getElementById('acadCurrentKP').textContent = kp;
    document.getElementById('acadKpAmount').value = 10;
    document.getElementById('acadModalMsg').textContent = '';
    var unlocked = unlockedStr ? unlockedStr.split(',').map(function(s){return s.trim();}).filter(Boolean) : [];
    var list = document.getElementById('acadUnlockList'); list.innerHTML = '';
    ACAD_PIECES.forEach(function(piece) {
        var label = document.createElement('label');
        label.style.cssText = 'display:flex;align-items:center;gap:6px;cursor:pointer;font-size:12px;padding:4px 6px;border-radius:4px;border:1px solid var(--line);background:var(--bg)';
        var cb = document.createElement('input'); cb.type = 'checkbox'; cb.value = piece; cb.checked = unlocked.indexOf(piece) !== -1; cb.id = 'acad_cb_' + piece;
        label.appendChild(cb); label.appendChild(document.createTextNode(piece.replace(/_/g,' ')));
        list.appendChild(label);
    });
    document.getElementById('academyModal').style.display = 'flex';
}
function closeAcademyModal() { document.getElementById('academyModal').style.display = 'none'; currentAcadUserId = null; }
document.getElementById('academyModal').addEventListener('click', function(e) { if(e.target===this) closeAcademyModal(); });
function setAcadMsg(msg, isError) { var el = document.getElementById('acadModalMsg'); el.textContent = msg; el.style.color = isError ? 'var(--crimson)' : 'var(--moss)'; }
function doAcadKP(sign) {
    if (!currentAcadUserId) return;
    var amount = parseInt(document.getElementById('acadKpAmount').value) || 0;
    if (amount <= 0) { setAcadMsg('Enter a valid amount.', true); return; }
    var delta = sign * amount;
    var fd = new FormData(); fd.append('acadUserId', currentAcadUserId); fd.append('acadKpDelta', delta);
    fetch(CTX + '/adminManageAcademy', {method:'POST', body:fd})
        .then(function(r){return r.json();})
        .then(function(data){ if (data.ok) { currentAcadKP = data.kp; document.getElementById('acadCurrentKP').textContent = data.kp; setAcadMsg((delta > 0 ? '+' : '') + delta + ' KP. New total: ' + data.kp, false); } else { setAcadMsg('Error: ' + (data.error || 'unknown'), true); } })
        .catch(function(){ setAcadMsg('Network error.', true); });
}
function doAcadSaveUnlocks() {
    if (!currentAcadUserId) return;
    var checked = ACAD_PIECES.filter(function(p){ var cb = document.getElementById('acad_cb_' + p); return cb && cb.checked; });
    var fd = new FormData(); fd.append('acadUserId', currentAcadUserId); fd.append('acadKpDelta', 0); fd.append('acadUnlockedPieces', checked.join(','));
    fetch(CTX + '/adminManageAcademy', {method:'POST', body:fd})
        .then(function(r){return r.json();})
        .then(function(data){ if (data.ok) { setAcadMsg('Unlocks saved (' + checked.length + ' pieces).', false); } else { setAcadMsg('Error: ' + (data.error || 'unknown'), true); } })
        .catch(function(){ setAcadMsg('Network error.', true); });
}

(function() {
    var tables = ['usersTable', 'botsTable', 'matchesTable'];
    tables.forEach(function(t) { if (document.getElementById(t)) renderPaginator(t, 1); });
})();
</script>
<%@ include file="_bot-picker.jsp" %>
</body>
</html>
