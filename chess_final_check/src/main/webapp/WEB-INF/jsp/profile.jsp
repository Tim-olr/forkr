<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.account.User, timolr.chess.army.Army, java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - Forkr</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
</head>
<body>
<%
    User pu = (User) pageContext.findAttribute("profileUser");
    List<Army> armies = (List<Army>) pageContext.findAttribute("userArmies");
    String msg = (String) pageContext.findAttribute("profileMessage");
    if (armies == null) armies = new java.util.ArrayList<>();
    String avatarLetter = (pu != null && pu.getUsername() != null && !pu.getUsername().isEmpty())
        ? String.valueOf(pu.getUsername().charAt(0)).toUpperCase() : "?";
    String picPath = (pu != null) ? pu.getProfilePicPath() : null;
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
        <li><a href="${pageContext.request.contextPath}/academy">Academy</a></li>
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

<div class="profile-page">

    <!-- Left column: avatar + info -->
    <div class="profile-sidebar">
        <div class="profile-avatar-wrap">
            <% if (picPath != null && !picPath.isEmpty()) { %>
                <img src="${pageContext.request.contextPath}/<%= picPath %>"
                     class="profile-avatar-img" alt="Avatar">
            <% } else { %>
                <div class="profile-avatar-letter"><%= avatarLetter %></div>
            <% } %>
        </div>
        <div class="profile-username"><%= pu != null ? pu.getUsername() : "" %></div>
        <% if (pu != null) { %>
        <div class="profile-info-row"><span class="profile-info-label">ELO</span><span class="profile-elo"><%= pu.getElo() %></span></div>
        <div class="profile-info-row"><span class="profile-info-label">Joined</span>
            <span><%= pu.getCreatedAt() != null ? pu.getCreatedAt().toLocalDate().toString() : "—" %></span></div>
        <div class="profile-info-row"><span class="profile-info-label">Email</span>
            <span style="color:var(--text-muted);font-size:13px">
                <%-- Show only first 3 chars + domain for privacy --%>
                <%
                    String em = pu.getEmail();
                    String emDisplay = "";
                    if (em != null && em.contains("@")) {
                        String[] parts = em.split("@", 2);
                        String local = parts[0];
                        emDisplay = (local.length() > 3 ? local.substring(0, 3) : local) + "***@" + parts[1];
                    }
                %>
                <%= emDisplay %>
            </span>
        </div>
        <% } %>

        <!-- Upload picture -->
        <div class="profile-card" style="margin-top:20px">
            <div class="profile-card-title">Profile Picture</div>
            <form action="${pageContext.request.contextPath}/uploadProfilePic"
                  method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <input type="file" name="profilePic" accept="image/*" class="form-input" style="padding:6px">
                </div>
                <button type="submit" class="btn btn-green btn-full">Upload</button>
            </form>
        </div>
    </div>

    <!-- Right column: password + armies -->
    <div class="profile-main">

        <% if (msg != null && !msg.isEmpty()) { %>
        <div class="profile-message <%= msg.contains("success") || msg.contains("updated") ? "profile-msg-ok" : "profile-msg-err" %>">
            <%= msg %>
        </div>
        <% } %>

        <!-- Change Password -->
        <div class="profile-card">
            <div class="profile-card-title">Change Password</div>
            <form action="${pageContext.request.contextPath}/changePassword" method="post">
                <div class="form-group">
                    <label class="form-label">Current Password</label>
                    <input type="password" name="oldPassword" class="form-input" placeholder="Current password" required>
                </div>
                <div class="form-group">
                    <label class="form-label">New Password</label>
                    <input type="password" name="newPassword" class="form-input" placeholder="New password (min 6 chars)" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Confirm New Password</label>
                    <input type="password" name="confirmNewPassword" class="form-input" placeholder="Confirm new password" required>
                </div>
                <button type="submit" class="btn btn-green">Update Password</button>
            </form>
        </div>

        <!-- My Armies -->
        <div class="profile-card">
            <div class="profile-card-title">My Armies <span style="color:var(--text-muted);font-size:13px">(<%= armies.size() %>)</span></div>
            <% if (armies.isEmpty()) { %>
                <div style="color:var(--text-muted);font-size:14px">No armies yet. <a href="${pageContext.request.contextPath}/army-builder">Create one!</a></div>
            <% } else { %>
            <div class="profile-army-list">
                <% for (Army a : armies) { %>
                <div class="profile-army-row">
                    <span class="profile-army-team-badge <%= a.getTeam().toLowerCase() %>">
                        <%= "WHITE".equals(a.getTeam()) ? "&#9812;" : "&#9818;" %>
                    </span>
                    <span class="profile-army-name"><%= a.getName() %></span>
                    <a href="${pageContext.request.contextPath}/army-builder?loadId=<%= a.getId() %>"
                       class="btn btn-outline" style="padding:4px 12px;font-size:12px">Edit</a>
                </div>
                <% } %>
            </div>
            <% } %>
            <div style="margin-top:14px">
                <a href="${pageContext.request.contextPath}/army-builder" class="btn btn-green">+ New Army</a>
            </div>
        </div>

    </div>
</div>
</body>
</html>
