<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.account.User, java.util.List" %>
<%@ page import="timolr.chess.bot.Bot" %>
<%@ page import="timolr.chess.army.Army" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - Forkr</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
    <style>
        .search-hidden,.pg-hidden{display:none!important}
        .admin-paginator{display:flex;align-items:center;gap:4px;margin-top:10px;flex-wrap:wrap}
        .pg-btn{padding:4px 10px;border:1px solid var(--border);background:var(--surface);color:var(--text);border-radius:6px;cursor:pointer;font-size:13px;transition:background .15s}
        .pg-btn:hover:not(.pg-disabled):not(.pg-active){background:var(--surface-alt)}
        .pg-btn.pg-active{background:var(--green);color:#fff;border-color:var(--green);font-weight:600}
        .pg-btn.pg-disabled{opacity:.35;cursor:default}
        .pg-ellipsis{padding:0 4px;color:var(--text-muted);font-size:13px}
    </style>
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
        <li><a href="${pageContext.request.contextPath}/admin" style="color:var(--green)">Admin</a></li>
        <li><a href="${pageContext.request.contextPath}/adminTickets">Tickets</a></li>
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
    String adminFlash = (String) session.getAttribute("adminFlash");
    if (adminFlash != null) session.removeAttribute("adminFlash");
%>
<%
    List<User> users = (List<User>) pageContext.findAttribute("allUsers");
    List<Bot> bots = (List<Bot>) pageContext.findAttribute("allBots");
    List<Army> presetArmies = (List<Army>) pageContext.findAttribute("allPresetArmies");
    Long currentUserId = (Long) session.getAttribute("userId");
    if (users == null) users = new java.util.ArrayList<>();
    if (bots == null) bots = new java.util.ArrayList<>();
    if (presetArmies == null) presetArmies = new java.util.ArrayList<>();
    long adminCount = users.stream().filter(User::isAdmin).count();
    long bannedCount = users.stream().filter(User::isBanned).count();
    ObjectMapper jsonMapper = new ObjectMapper();

    // Collect existing collection names for datalist
    java.util.Set<String> existingCollections = new java.util.LinkedHashSet<>();
    for (Bot b : bots) {
        if (b.getCollection() != null && !b.getCollection().isBlank()) {
            existingCollections.add(b.getCollection());
        }
    }
%>

<!-- ── Ban Reason Modal ───────────────────────────────────────────────────── -->
<div class="modal-overlay" id="banReasonModal" style="display:none">
    <div class="modal-box" style="max-width:440px">
        <div class="modal-header-row">
            <div class="modal-title" style="margin-bottom:0" id="banReasonTitle">Ban Player</div>
            <button class="modal-close-btn" onclick="closeBanReasonModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/adminBanUser" id="banReasonForm">
            <input type="hidden" name="banUserId" id="banReasonUserId">
            <input type="hidden" name="banValue" id="banReasonValue">
            <div class="form-group" style="margin-top:16px">
                <label class="form-label" id="banReasonLabel">Ban Reason <span style="color:var(--text-muted);font-weight:400">(shown to the player)</span></label>
                <textarea name="banReason" id="banReasonText" class="form-input" rows="3" maxlength="500" placeholder="Enter a reason..." style="resize:vertical"></textarea>
            </div>
            <div style="display:flex;gap:8px;margin-top:4px">
                <button type="submit" class="btn btn-danger" style="flex:1" id="banReasonSubmitBtn">Ban Player</button>
                <button type="button" class="btn btn-outline" onclick="closeBanReasonModal()" style="flex:1">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- ── Edit User Modal ─────────────────────────────────────────────────────── -->
<div class="modal-overlay" id="editUserModal" style="display:none">
    <div class="modal-box" style="max-width:420px">
        <div class="modal-header-row">
            <div class="modal-title" style="margin-bottom:0">Edit User</div>
            <button class="modal-close-btn" onclick="closeEditModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/adminEditUser" id="editUserForm">
            <input type="hidden" name="editUserId" id="editUserId">
            <div class="form-group" style="margin-top:16px">
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
                <button type="submit" class="btn btn-green" style="flex:1">Save Changes</button>
                <button type="button" class="btn btn-outline" onclick="closeEditModal()" style="flex:1">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- ── Create Bot Modal ────────────────────────────────────────────────────── -->
<div class="modal-overlay" id="createBotModal" style="display:none">
    <div class="modal-box" style="max-width:420px">
        <div class="modal-header-row">
            <div class="modal-title" style="margin-bottom:0">New Bot</div>
            <button class="modal-close-btn" onclick="closeCreateBotModal()">&times;</button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/adminCreateBot">
            <div class="form-group" style="margin-top:16px">
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
                <button type="submit" class="btn btn-green" style="flex:1">Create Bot</button>
                <button type="button" class="btn btn-outline" onclick="closeCreateBotModal()" style="flex:1">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- datalist for collection autocomplete -->
<datalist id="collectionList">
    <% for (String col : existingCollections) { %>
    <option value="<%= esc(col) %>">
    <% } %>
</datalist>

<!-- ── Edit Bot Modal ─────────────────────────────────────────────────────── -->
<div class="modal-overlay" id="editBotModal" style="display:none">
    <div class="modal-box" style="max-width:580px;max-height:88vh;overflow-y:auto">
        <div class="modal-header-row" style="position:sticky;top:0;background:var(--surface);z-index:1;padding-bottom:8px">
            <div class="modal-title" style="margin-bottom:0">Edit Bot</div>
            <button class="modal-close-btn" onclick="closeEditBotModal()">&times;</button>
        </div>

        <!-- Image upload (separate multipart form) -->
        <div id="botImageSection" style="display:flex;align-items:center;gap:16px;margin:12px 0 16px">
            <div id="botCurrentImage" style="width:72px;height:72px;border-radius:8px;background:var(--surface-alt);display:flex;align-items:center;justify-content:center;overflow:hidden;flex-shrink:0;border:1px solid var(--border)">
                <span style="font-size:32px">&#9816;</span>
            </div>
            <form method="POST" action="${pageContext.request.contextPath}/adminUploadBotImage" enctype="multipart/form-data" style="flex:1">
                <input type="hidden" name="botId" id="uploadBotId">
                <label class="form-label" style="margin-bottom:4px;display:block">Bot Portrait (PNG/JPG)</label>
                <div style="display:flex;gap:6px">
                    <input type="file" name="botImage" accept="image/*" class="form-input" style="flex:1;padding:5px">
                    <button type="submit" class="btn btn-outline">Upload</button>
                </div>
            </form>
        </div>

        <!-- Main edit form -->
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
                <input type="text" name="botCollection" id="editBotCollection" class="form-input" list="collectionList" maxlength="100" placeholder="e.g. Beginner, Intermediate">
            </div>

            <hr style="border:none;border-top:1px solid var(--border);margin:14px 0 10px">
            <div style="color:var(--text-muted);font-size:12px;margin-bottom:10px;font-weight:600;text-transform:uppercase;letter-spacing:.05em">General Voicelines</div>

            <div class="form-group">
                <label class="form-label">Periodic <span style="color:var(--text-muted);font-weight:400">(shown randomly during play)</span></label>
                <div id="editBotVoicelines" data-field="botVoicelines"></div>
                <button type="button" class="btn btn-outline" onclick="addLine('editBotVoicelines')" style="margin-top:4px;font-size:13px">+ Add Line</button>
            </div>

            <hr style="border:none;border-top:1px solid var(--border);margin:14px 0 10px">
            <div style="color:var(--text-muted);font-size:12px;margin-bottom:10px;font-weight:600;text-transform:uppercase;letter-spacing:.05em">When opponent takes a bot piece</div>

            <div class="form-group">
                <label class="form-label">G0 piece captured <span style="color:var(--text-muted);font-weight:400">(Pawn-grade)</span></label>
                <div id="editBotG0Lines" data-field="botG0Lines"></div>
                <button type="button" class="btn btn-outline" onclick="addLine('editBotG0Lines')" style="margin-top:4px;font-size:13px">+ Add Line</button>
            </div>
            <div class="form-group">
                <label class="form-label">G1 piece captured <span style="color:var(--text-muted);font-weight:400">(Knight/Rook/Bishop-grade)</span></label>
                <div id="editBotG1Lines" data-field="botG1Lines"></div>
                <button type="button" class="btn btn-outline" onclick="addLine('editBotG1Lines')" style="margin-top:4px;font-size:13px">+ Add Line</button>
            </div>
            <div class="form-group">
                <label class="form-label">G2 piece captured <span style="color:var(--text-muted);font-weight:400">(Queen-grade)</span></label>
                <div id="editBotG2Lines" data-field="botG2Lines"></div>
                <button type="button" class="btn btn-outline" onclick="addLine('editBotG2Lines')" style="margin-top:4px;font-size:13px">+ Add Line</button>
            </div>

            <hr style="border:none;border-top:1px solid var(--border);margin:14px 0 10px">
            <div style="color:var(--text-muted);font-size:12px;margin-bottom:10px;font-weight:600;text-transform:uppercase;letter-spacing:.05em">When bot takes an opponent piece</div>

            <div class="form-group">
                <label class="form-label">Takes G0 piece <span style="color:var(--text-muted);font-weight:400">(Pawn-grade)</span></label>
                <div id="editBotG0TakeLines" data-field="botG0TakeLines"></div>
                <button type="button" class="btn btn-outline" onclick="addLine('editBotG0TakeLines')" style="margin-top:4px;font-size:13px">+ Add Line</button>
            </div>
            <div class="form-group">
                <label class="form-label">Takes G1 piece <span style="color:var(--text-muted);font-weight:400">(Knight/Rook/Bishop-grade)</span></label>
                <div id="editBotG1TakeLines" data-field="botG1TakeLines"></div>
                <button type="button" class="btn btn-outline" onclick="addLine('editBotG1TakeLines')" style="margin-top:4px;font-size:13px">+ Add Line</button>
            </div>
            <div class="form-group">
                <label class="form-label">Takes G2 piece <span style="color:var(--text-muted);font-weight:400">(Queen-grade)</span></label>
                <div id="editBotG2TakeLines" data-field="botG2TakeLines"></div>
                <button type="button" class="btn btn-outline" onclick="addLine('editBotG2TakeLines')" style="margin-top:4px;font-size:13px">+ Add Line</button>
            </div>

            <hr style="border:none;border-top:1px solid var(--border);margin:14px 0 10px">
            <div style="color:var(--text-muted);font-size:12px;margin-bottom:10px;font-weight:600;text-transform:uppercase;letter-spacing:.05em">Game Result</div>

            <div class="form-group">
                <label class="form-label">Win lines <span style="color:var(--text-muted);font-weight:400">(bot wins by checkmate)</span></label>
                <div id="editBotWinLines" data-field="botWinLines"></div>
                <button type="button" class="btn btn-outline" onclick="addLine('editBotWinLines')" style="margin-top:4px;font-size:13px">+ Add Line</button>
            </div>
            <div class="form-group">
                <label class="form-label">Lose lines <span style="color:var(--text-muted);font-weight:400">(opponent wins by checkmate)</span></label>
                <div id="editBotLoseLines" data-field="botLoseLines"></div>
                <button type="button" class="btn btn-outline" onclick="addLine('editBotLoseLines')" style="margin-top:4px;font-size:13px">+ Add Line</button>
            </div>

            <hr style="border:none;border-top:1px solid var(--border);margin:14px 0 10px">
            <div style="color:var(--text-muted);font-size:12px;margin-bottom:10px;font-weight:600;text-transform:uppercase;letter-spacing:.05em">Available Armies</div>

            <div class="form-group">
                <% if (presetArmies.isEmpty()) { %>
                <div style="color:var(--text-muted);font-size:13px">No preset armies yet.</div>
                <% } else { %>
                <div style="display:flex;flex-direction:column;gap:6px">
                    <% for (Army army : presetArmies) { %>
                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer">
                        <input type="checkbox" name="botArmyIds" value="<%= army.getId() %>" class="bot-army-checkbox">
                        <span><%= esc(army.getName()) %> <span style="color:var(--text-muted);font-size:12px">(<%= esc(army.getTeam()) %>)</span></span>
                    </label>
                    <% } %>
                </div>
                <% } %>
            </div>

            <div style="display:flex;gap:8px;margin-top:12px;position:sticky;bottom:0;background:var(--surface);padding-top:8px">
                <button type="submit" class="btn btn-green" style="flex:1">Save Changes</button>
                <button type="button" class="btn btn-danger" onclick="closeEditBotModal()" style="flex:1">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- ── Academy Management Modal ───────────────────────────────────────────── -->
<div class="modal-overlay" id="academyModal" style="display:none">
    <div class="modal-box" style="max-width:500px;max-height:88vh;overflow-y:auto">
        <div class="modal-header-row">
            <div class="modal-title" style="margin-bottom:0">Academy — <span id="acadModalUser"></span></div>
            <button class="modal-close-btn" onclick="closeAcademyModal()">&times;</button>
        </div>

        <!-- KP section -->
        <div style="margin-top:18px">
            <div style="font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:.05em;color:var(--text-muted);margin-bottom:8px">Knowledge Points</div>
            <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px">
                <span style="font-size:15px">Current KP:</span>
                <span id="acadCurrentKP" style="font-size:18px;font-weight:700;color:#d4af37"></span>
            </div>
            <div style="display:flex;gap:8px;align-items:center">
                <input type="number" id="acadKpAmount" class="form-input" value="10" min="1" max="9999" style="width:100px">
                <button class="btn btn-green" onclick="doAcadKP(1)" style="flex:1">+ Give KP</button>
                <button class="btn btn-danger" onclick="doAcadKP(-1)" style="flex:1">− Remove KP</button>
            </div>
        </div>

        <hr style="border:none;border-top:1px solid var(--border);margin:18px 0 12px">

        <!-- Unlock section -->
        <div>
            <div style="font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:.05em;color:var(--text-muted);margin-bottom:10px">Piece Unlocks</div>
            <div style="font-size:12px;color:var(--text-muted);margin-bottom:10px">Base pieces (Pawn, Knight, Rook, Bishop, Queen, King) are always available.</div>
            <div id="acadUnlockList" style="display:grid;grid-template-columns:repeat(2,1fr);gap:6px;margin-bottom:14px"></div>
            <button class="btn btn-green" onclick="doAcadSaveUnlocks()" style="width:100%">Save Piece Unlocks</button>
        </div>

        <div id="acadModalMsg" style="margin-top:10px;font-size:13px;text-align:center;min-height:20px;color:var(--green)"></div>
    </div>
</div>

<% if (adminFlash != null) { %>
<div style="background:var(--surface-alt);border:1px solid var(--border);border-left:4px solid var(--accent);border-radius:6px;padding:12px 18px;margin:16px auto;max-width:1100px;font-size:14px;word-break:break-all">
    <%= esc(adminFlash) %>
</div>
<% } %>

<div class="admin-page">
    <div class="admin-header">
        <div>
            <h1 class="admin-title">&#9876; Admin Panel</h1>
        </div>
        <a href="${pageContext.request.contextPath}/army-builder" class="btn btn-green">+ New Preset Army</a>
    </div>

    <!-- Stats -->
    <div class="admin-stats">
        <div class="admin-stat-card">
            <div class="admin-stat-num"><%= users.size() %></div>
            <div class="admin-stat-label">Total Users</div>
        </div>
        <div class="admin-stat-card">
            <div class="admin-stat-num"><%= adminCount %></div>
            <div class="admin-stat-label">Admins</div>
        </div>
        <div class="admin-stat-card">
            <div class="admin-stat-num" style="color:var(--error)"><%= bannedCount %></div>
            <div class="admin-stat-label">Banned</div>
        </div>
        <div class="admin-stat-card">
            <div class="admin-stat-num"><%= bots.size() %></div>
            <div class="admin-stat-label">Bots</div>
        </div>
    </div>

    <!-- ── Users Section ─────────────────────────────── -->
    <div class="admin-section">
        <div class="admin-section-header">
            <h2 class="admin-section-title" style="margin-bottom:0">Users</h2>
            <input type="text" id="userSearch" class="form-input" style="max-width:240px" placeholder="Search users…" oninput="filterTable('userSearch','usersTable')">
        </div>
        <% if (users.isEmpty()) { %>
        <div class="admin-empty">No users found.</div>
        <% } else { %>
        <table class="admin-table" id="usersTable">
            <thead>
                <tr>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Joined</th>
                    <th>Role</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% for (User u : users) {
                boolean isSelf = u.getId().equals(currentUserId);
            %>
                <tr class="<%= u.isBanned() ? "admin-row-banned" : (u.isAdmin() ? "admin-row-preset" : "") %>">
                    <td class="admin-td-name">
                        <%= esc(u.getUsername()) %>
                        <% if (isSelf) { %><span class="admin-owner-admin">you</span><% } %>
                    </td>
                    <td class="admin-td-owner"><%= esc(u.getEmail()) %></td>
                    <td class="admin-td-owner" style="white-space:nowrap"><%= u.getCreatedAt() != null ? u.getCreatedAt().toLocalDate().toString() : "" %></td>
                    <td>
                        <% if (u.isAdmin()) { %>
                            <span class="admin-preset-badge" style="font-size:11px">ADMIN</span>
                        <% } else { %>
                            <span style="color:var(--text-muted);font-size:12px">User</span>
                        <% } %>
                    </td>
                    <td>
                        <% if (u.isBanned()) { %>
                            <span class="admin-banned-badge">BANNED</span>
                        <% } else { %>
                            <span style="color:var(--text-muted);font-size:12px">Active</span>
                        <% } %>
                    </td>
                    <td class="admin-td-actions">
                        <% if (!isSelf) { %>
                        <button type="button" class="admin-toggle-btn"
                            onclick="openEditModal(<%= u.getId() %>, '<%= esc(u.getUsername()) %>', '<%= esc(u.getEmail()) %>')">
                            Edit
                        </button>
                        <form method="POST" action="${pageContext.request.contextPath}/adminToggleAdmin" style="display:inline">
                            <input type="hidden" name="toggleAdminId" value="<%= u.getId() %>">
                            <input type="hidden" name="toggleAdminValue" value="<%= !u.isAdmin() %>">
                            <button type="submit" class="admin-toggle-btn <%= u.isAdmin() ? "active" : "" %>">
                                <%= u.isAdmin() ? "Revoke Admin" : "Make Admin" %>
                            </button>
                        </form>
                        <button type="button" class="admin-toggle-btn <%= u.isBanned() ? "active" : "danger" %>"
                            onclick="openBanReasonModal(<%= u.getId() %>, '<%= esc(u.getUsername()) %>', <%= u.isBanned() %>)">
                            <%= u.isBanned() ? "Unban" : "Ban" %>
                        </button>
                        <form method="POST" action="${pageContext.request.contextPath}/adminSendPasswordReset" style="display:inline">
                            <input type="hidden" name="resetUserId" value="<%= u.getId() %>">
                            <button type="submit" class="admin-toggle-btn"
                                title="Send password reset email to <%= esc(u.getEmail()) %>">
                                Reset PW
                            </button>
                        </form>
                        <button type="button" class="admin-toggle-btn"
                            onclick="openAcademyModal(<%= u.getId() %>, '<%= esc(u.getUsername()) %>', <%= u.getKnowledgePoints() %>, '<%= u.getUnlockedPieces() != null ? esc(u.getUnlockedPieces()) : "" %>')">
                            Academy
                        </button>
                        <% } else { %>
                        <span style="color:var(--text-muted);font-size:12px">—</span>
                        <% } %>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
        <div class="admin-paginator" id="usersTable-paginator"></div>
    </div>

    <!-- ── Bots Section ──────────────────────────────── -->
    <div class="admin-section">
        <div class="admin-section-header">
            <h2 class="admin-section-title" style="margin-bottom:0">Bots</h2>
            <div class="admin-section-controls">
                <input type="text" id="botSearch" class="form-input" style="max-width:200px" placeholder="Search bots…" oninput="filterTable('botSearch','botsTable')">
                <button type="button" class="btn btn-green" onclick="openCreateBotModal()">+ New Bot</button>
            </div>
        </div>
        <% if (bots.isEmpty()) { %>
        <div class="admin-empty">No bots found. Create one to get started.</div>
        <% } else { %>
        <table class="admin-table" id="botsTable">
            <thead>
                <tr>
                    <th>Portrait</th>
                    <th>Name</th>
                    <th>Elo</th>
                    <th>Collection</th>
                    <th>Lines</th>
                    <th>Armies</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% for (Bot bot : bots) { %>
                <tr>
                    <td style="width:48px">
                        <% if (bot.getImagePath() != null) { %>
                        <img src="${pageContext.request.contextPath}/<%= esc(bot.getImagePath()) %>"
                             style="width:40px;height:40px;border-radius:6px;object-fit:cover" alt="">
                        <% } else { %>
                        <div style="width:40px;height:40px;border-radius:6px;background:var(--surface-alt);display:flex;align-items:center;justify-content:center;font-size:20px">&#9816;</div>
                        <% } %>
                    </td>
                    <td class="admin-td-name"><%= esc(bot.getName()) %></td>
                    <td class="admin-td-owner"><%= bot.getElo() %></td>
                    <td class="admin-td-owner">
                        <%= bot.getCollection() != null ? esc(bot.getCollection()) : "<span style='color:var(--text-muted);font-size:12px'>—</span>" %>
                    </td>
                    <td class="admin-td-owner" style="font-size:12px;color:var(--text-muted)">
                        <%= bot.getVoicelines().size() %>g /
                        <%= bot.getG0CaptureLines().size() + bot.getG0TakeLines().size() %>g0 /
                        <%= bot.getG1CaptureLines().size() + bot.getG1TakeLines().size() %>g1 /
                        <%= bot.getG2CaptureLines().size() + bot.getG2TakeLines().size() %>g2
                    </td>
                    <td class="admin-td-owner"><%= bot.getArmies().size() %></td>
                    <td class="admin-td-actions">
                        <button type="button" class="admin-toggle-btn"
                            onclick="openEditBotModal(<%= bot.getId() %>)">Edit</button>
                        <form method="POST" action="${pageContext.request.contextPath}/adminDeleteBot" style="display:inline"
                            onsubmit="return confirm('Delete bot \'<%= esc(bot.getName()) %>\'?')">
                            <input type="hidden" name="botId" value="<%= bot.getId() %>">
                            <button type="submit" class="admin-toggle-btn danger">Delete</button>
                        </form>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
        <div class="admin-paginator" id="botsTable-paginator"></div>
    </div>
</div>

<script>
// ── Bot data registry ──────────────────────────────────────────────────────
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
<%
    }
} catch (Exception e) { /* serialization failed */ }
%>

// ── Ban reason modal ───────────────────────────────────────────────────────
function openBanReasonModal(id, username, currentlyBanned) {
    document.getElementById('banReasonUserId').value = id;
    document.getElementById('banReasonValue').value = !currentlyBanned;
    document.getElementById('banReasonText').value = '';
    if (currentlyBanned) {
        document.getElementById('banReasonTitle').textContent = 'Unban Player: ' + username;
        document.getElementById('banReasonLabel').innerHTML = 'Unban Reason <span style="color:var(--text-muted);font-weight:400">(optional note for the player)</span>';
        document.getElementById('banReasonSubmitBtn').textContent = 'Unban Player';
        document.getElementById('banReasonSubmitBtn').className = 'btn btn-green';
    } else {
        document.getElementById('banReasonTitle').textContent = 'Ban Player: ' + username;
        document.getElementById('banReasonLabel').innerHTML = 'Ban Reason <span style="color:var(--text-muted);font-weight:400">(shown to the player)</span>';
        document.getElementById('banReasonSubmitBtn').textContent = 'Ban Player';
        document.getElementById('banReasonSubmitBtn').className = 'btn btn-danger';
    }
    document.getElementById('banReasonModal').style.display = 'flex';
}
function closeBanReasonModal() { document.getElementById('banReasonModal').style.display = 'none'; }
document.getElementById('banReasonModal').addEventListener('click', function(e) { if(e.target===this) closeBanReasonModal(); });

// ── User modal ─────────────────────────────────────────────────────────────
function openEditModal(id, username, email) {
    document.getElementById('editUserId').value = id;
    document.getElementById('editUsername').value = username;
    document.getElementById('editEmail').value = email;
    document.getElementById('editPassword').value = '';
    document.getElementById('editUserModal').style.display = 'flex';
}
function closeEditModal() { document.getElementById('editUserModal').style.display = 'none'; }
document.getElementById('editUserModal').addEventListener('click', function(e) { if(e.target===this) closeEditModal(); });

// ── Create bot modal ───────────────────────────────────────────────────────
function openCreateBotModal() { document.getElementById('createBotModal').style.display = 'flex'; }
function closeCreateBotModal() { document.getElementById('createBotModal').style.display = 'none'; }
document.getElementById('createBotModal').addEventListener('click', function(e) { if(e.target===this) closeCreateBotModal(); });

// ── Edit bot modal ─────────────────────────────────────────────────────────
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
        imgEl.innerHTML = '<img src="${pageContext.request.contextPath}/' + data.imagePath + '" style="width:100%;height:100%;object-fit:cover" alt="">';
    } else {
        imgEl.innerHTML = '<span style="font-size:32px">&#9816;</span>';
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

// ── Voiceline helpers ──────────────────────────────────────────────────────
function renderLines(containerId, lines) {
    var container = document.getElementById(containerId);
    container.innerHTML = '';
    if (lines && lines.length > 0) lines.forEach(function(l) { addLine(containerId, l); });
}

// ── Table pagination + search ──────────────────────────────────────────────
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
    var total = rows.length;
    var totalPages = Math.max(1, Math.ceil(total / PG_SIZE));
    page = Math.min(Math.max(1, page), totalPages);

    rows.forEach(function(row, i) {
        row.classList.toggle('pg-hidden', i < (page - 1) * PG_SIZE || i >= page * PG_SIZE);
    });

    var el = document.getElementById(tableId + '-paginator');
    if (!el) return;
    el.innerHTML = '';
    if (totalPages <= 1) return;

    function mkBtn(label, target, disabled, active) {
        var b = document.createElement('button');
        b.type = 'button';
        b.className = 'pg-btn' + (active ? ' pg-active' : '') + (disabled ? ' pg-disabled' : '');
        b.textContent = label;
        if (!disabled) b.onclick = function() { renderPaginator(tableId, target); };
        el.appendChild(b);
    }

    mkBtn('‹', page - 1, page === 1, false);
    var start = Math.max(1, page - 2), end = Math.min(totalPages, page + 2);
    if (start > 1) { mkBtn('1', 1, false, false); if (start > 2) { var sp=document.createElement('span'); sp.className='pg-ellipsis'; sp.textContent='…'; el.appendChild(sp); } }
    for (var p = start; p <= end; p++) mkBtn(p, p, false, p === page);
    if (end < totalPages) { if (end < totalPages - 1) { var sp2=document.createElement('span'); sp2.className='pg-ellipsis'; sp2.textContent='…'; el.appendChild(sp2); } mkBtn(totalPages, totalPages, false, false); }
    mkBtn('›', page + 1, page === totalPages, false);
}

function addLine(containerId, value) {
    var container = document.getElementById(containerId);
    var fieldName = container.dataset.field;
    var div = document.createElement('div');
    div.style.cssText = 'display:flex;gap:6px;margin-bottom:6px';
    var input = document.createElement('input');
    input.type = 'text'; input.name = fieldName; input.className = 'form-input';
    input.style.flex = '1'; input.value = (value !== undefined && value !== null) ? value : '';
    var btn = document.createElement('button');
    btn.type = 'button'; btn.className = 'btn btn-outline';
    btn.style.cssText = 'padding:4px 10px;min-width:34px'; btn.textContent = '×';
    btn.onclick = function() { div.remove(); };
    div.appendChild(input); div.appendChild(btn);
    container.appendChild(div);
}

// ── Academy modal ──────────────────────────────────────────────────────────
var ACAD_PIECES = [
    'EVIL_PAWN','SQUIRE','LONGPAW','RETREATER','HOLLOW','CRAWLER',
    'JESTER','LANCER','ECLIPSE','DUKE','BEAST_HANDLER','BIRD','SHIELD',
    'PRINCE','CHOIR','EAGLE','COIL','BOOT','FEATHER','WIZARD','HERBALIST','PRINCESS',
    'HUSK','LANTERN','ORACLE','WARDEN','HYDRA','LIBRARY','FORK'
];
var currentAcadUserId = null;
var currentAcadKP = 0;

function openAcademyModal(userId, username, kp, unlockedStr) {
    currentAcadUserId = userId;
    currentAcadKP = kp;
    document.getElementById('acadModalUser').textContent = username;
    document.getElementById('acadCurrentKP').textContent = kp;
    document.getElementById('acadKpAmount').value = 10;
    document.getElementById('acadModalMsg').textContent = '';

    var unlocked = unlockedStr ? unlockedStr.split(',').map(function(s){return s.trim();}).filter(Boolean) : [];
    var list = document.getElementById('acadUnlockList');
    list.innerHTML = '';
    ACAD_PIECES.forEach(function(piece) {
        var label = document.createElement('label');
        label.style.cssText = 'display:flex;align-items:center;gap:6px;cursor:pointer;font-size:13px;padding:4px 6px;border-radius:6px;border:1px solid var(--border);background:var(--bg-primary)';
        var cb = document.createElement('input');
        cb.type = 'checkbox';
        cb.value = piece;
        cb.checked = unlocked.indexOf(piece) !== -1;
        cb.id = 'acad_cb_' + piece;
        label.appendChild(cb);
        label.appendChild(document.createTextNode(piece.replace(/_/g,' ')));
        list.appendChild(label);
    });

    document.getElementById('academyModal').style.display = 'flex';
}

function closeAcademyModal() {
    document.getElementById('academyModal').style.display = 'none';
    currentAcadUserId = null;
}
document.getElementById('academyModal').addEventListener('click', function(e) { if(e.target===this) closeAcademyModal(); });

function setAcadMsg(msg, isError) {
    var el = document.getElementById('acadModalMsg');
    el.textContent = msg;
    el.style.color = isError ? 'var(--error)' : 'var(--green)';
}

function doAcadKP(sign) {
    if (!currentAcadUserId) return;
    var amount = parseInt(document.getElementById('acadKpAmount').value) || 0;
    if (amount <= 0) { setAcadMsg('Enter a valid amount.', true); return; }
    var delta = sign * amount;
    var fd = new FormData();
    fd.append('acadUserId', currentAcadUserId);
    fd.append('acadKpDelta', delta);
    fetch('${pageContext.request.contextPath}/adminManageAcademy', {method:'POST', body:fd})
        .then(function(r){return r.json();})
        .then(function(data){
            if (data.ok) {
                currentAcadKP = data.kp;
                document.getElementById('acadCurrentKP').textContent = data.kp;
                setAcadMsg((delta > 0 ? '+' : '') + delta + ' KP applied. New total: ' + data.kp, false);
            } else {
                setAcadMsg('Error: ' + (data.error || 'unknown'), true);
            }
        }).catch(function(){ setAcadMsg('Network error.', true); });
}

function doAcadSaveUnlocks() {
    if (!currentAcadUserId) return;
    var checked = [];
    ACAD_PIECES.forEach(function(piece) {
        var cb = document.getElementById('acad_cb_' + piece);
        if (cb && cb.checked) checked.push(piece);
    });
    var fd = new FormData();
    fd.append('acadUserId', currentAcadUserId);
    fd.append('acadKpDelta', 0);
    fd.append('acadUnlockedPieces', checked.join(','));
    fetch('${pageContext.request.contextPath}/adminManageAcademy', {method:'POST', body:fd})
        .then(function(r){return r.json();})
        .then(function(data){
            if (data.ok) {
                setAcadMsg('Unlocks saved (' + checked.length + ' pieces).', false);
            } else {
                setAcadMsg('Error: ' + (data.error || 'unknown'), true);
            }
        }).catch(function(){ setAcadMsg('Network error.', true); });
}

// ── Init paginators on load ────────────────────────────────────────────────
(function() {
    var tables = ['usersTable', 'botsTable'];
    tables.forEach(function(t) { if (document.getElementById(t)) renderPaginator(t, 1); });
})();
</script>
</body>
</html>
