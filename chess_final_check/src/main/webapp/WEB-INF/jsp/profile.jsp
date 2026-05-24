<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.account.User, timolr.chess.army.Army, java.util.List" %>
<%
    pageContext.setAttribute("pageTitle", "Profile");
    pageContext.setAttribute("activeNav", "profile");
    User pu = (User) pageContext.findAttribute("profileUser");
    List<Army> armies = (List<Army>) pageContext.findAttribute("userArmies");
    String msg = (String) pageContext.findAttribute("profileMessage");
    if (armies == null) armies = new java.util.ArrayList<>();
    String avatarLetter = (pu != null && pu.getUsername() != null && !pu.getUsername().isEmpty())
        ? String.valueOf(pu.getUsername().charAt(0)).toUpperCase() : "?";
    String picPath = (pu != null) ? pu.getProfilePicPath() : null;
    String emDisplay = "";
    if (pu != null && pu.getEmail() != null && pu.getEmail().contains("@")) {
        String[] parts = pu.getEmail().split("@", 2);
        String local = parts[0];
        emDisplay = (local.length() > 3 ? local.substring(0, 3) : local) + "***@" + parts[1];
    }
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
                <span class="crumb-pre">Account</span>
                <h2>Profile</h2>
            </div>
        </div>

        <div class="page-body">
            <% if (msg != null && !msg.isEmpty()) { %>
            <div style="background:rgba(122,148,97,0.12);border:1px solid rgba(122,148,97,0.4);border-radius:4px;padding:10px 14px;margin-bottom:16px;font-size:13px;color:var(--moss)"><%= msg %></div>
            <% } %>

            <div style="display:grid;grid-template-columns:260px 1fr;gap:20px;align-items:start">
                <!-- Left: avatar + stats -->
                <div style="display:flex;flex-direction:column;gap:14px">
                    <div class="card" style="padding:24px;display:flex;flex-direction:column;align-items:center;gap:12px">
                        <div class="avatar" style="width:72px;height:72px;font-size:28px;flex-shrink:0;border-radius:50%;overflow:hidden;<% if (picPath != null && !picPath.isEmpty()) { %>background:none;<% } %>">
                            <% if (picPath != null && !picPath.isEmpty()) { %>
                                <img src="${pageContext.request.contextPath}/<%= picPath %>" style="width:100%;height:100%;object-fit:cover;display:block" alt="Avatar">
                            <% } else { %><%= avatarLetter %><% } %>
                        </div>
                        <div style="text-align:center">
                            <div style="font-size:18px;font-weight:600"><%= pu != null ? pu.getUsername() : "" %></div>
                            <% if (pu != null) { %>
                            <div style="font-family:var(--font-mono);font-size:11px;color:var(--amber);letter-spacing:.1em;text-transform:uppercase;margin-top:2px"><%= Boolean.TRUE.equals(session.getAttribute("isAdmin")) ? "Admin" : "Player" %></div>
                            <% } %>
                        </div>
                        <% if (pu != null) { %>
                        <div style="width:100%;border-top:1px solid var(--line);padding-top:12px;display:flex;flex-direction:column;gap:8px">
                            <div style="display:flex;justify-content:space-between;font-size:13px">
                                <span style="color:var(--ink-faint)">ELO Rating</span>
                                <span style="font-family:var(--font-display);font-size:16px"><%= pu.getElo() %></span>
                            </div>
                            <div style="display:flex;justify-content:space-between;font-size:13px">
                                <span style="color:var(--ink-faint)">Joined</span>
                                <span><%= pu.getCreatedAt() != null ? pu.getCreatedAt().toLocalDate().toString() : "—" %></span>
                            </div>
                            <div style="display:flex;justify-content:space-between;font-size:13px">
                                <span style="color:var(--ink-faint)">Email</span>
                                <span style="color:var(--ink-mute);font-size:12px"><%= emDisplay %></span>
                            </div>
                        </div>
                        <% } %>
                    </div>

                    <!-- Upload picture -->
                    <div class="card" style="padding:16px">
                        <div style="font-size:12px;font-weight:500;margin-bottom:10px">Profile Picture</div>
                        <form action="${pageContext.request.contextPath}/uploadProfilePic" method="post" enctype="multipart/form-data">
                            <div class="form-row">
                                <input type="file" name="profilePic" accept="image/*" style="font-size:12px">
                            </div>
                            <button type="submit" class="btn primary" style="width:100%;margin-top:6px">Upload</button>
                        </form>
                    </div>
                </div>

                <!-- Right: forms + armies -->
                <div style="display:flex;flex-direction:column;gap:14px">
                    <!-- Change Password -->
                    <div class="card" style="padding:20px">
                        <div style="font-size:14px;font-weight:500;margin-bottom:16px">Change Password</div>
                        <form action="${pageContext.request.contextPath}/changePassword" method="post">
                            <div class="form-row">
                                <label>Current Password</label>
                                <input type="password" name="oldPassword" placeholder="Current password" required>
                            </div>
                            <div class="form-row">
                                <label>New Password</label>
                                <input type="password" name="newPassword" placeholder="New password (min 6 chars)" required>
                            </div>
                            <div class="form-row">
                                <label>Confirm New Password</label>
                                <input type="password" name="confirmNewPassword" placeholder="Confirm new password" required>
                            </div>
                            <button type="submit" class="btn primary">Update Password</button>
                        </form>
                    </div>

                    <!-- Danger Zone: Delete Account -->
                    <div class="card" style="padding:20px;border-color:rgba(200,85,61,0.3)">
                        <div style="font-size:14px;font-weight:500;margin-bottom:6px;color:var(--crimson)">Danger Zone</div>
                        <div style="font-size:13px;color:var(--ink-faint);margin-bottom:14px">Permanently delete your account and all associated data. This action cannot be undone.</div>
                        <button type="button" class="btn danger" onclick="document.getElementById('deleteAccountModal').style.display='flex'">Delete My Account</button>
                    </div>

                    <!-- My Armies -->
                    <div class="card" style="padding:20px">
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px">
                            <div style="font-size:14px;font-weight:500">My Armies <span style="color:var(--ink-faint);font-size:13px">(<%= armies.size() %>)</span></div>
                            <a href="${pageContext.request.contextPath}/army-builder" class="btn sm primary">+ New Army</a>
                        </div>
                        <% if (armies.isEmpty()) { %>
                        <div style="color:var(--ink-faint);font-size:13px;padding:16px 0;text-align:center">
                            No armies yet. <a href="${pageContext.request.contextPath}/army-builder" style="color:var(--amber)">Create one →</a>
                        </div>
                        <% } else { %>
                        <div style="display:flex;flex-direction:column;gap:8px">
                            <% for (Army a : armies) { %>
                            <div style="display:flex;align-items:center;gap:12px;padding:10px 12px;border:1px solid var(--line);border-radius:5px">
                                <div style="width:28px;height:28px;border-radius:50%;background:var(--bg-elev-2);border:1px solid var(--line-strong);display:grid;place-items:center;font-size:14px;flex-shrink:0">
                                    <%= "WHITE".equals(a.getTeam()) ? "♔" : "♚" %>
                                </div>
                                <div style="flex:1;font-size:13px"><%= a.getName() %></div>
                                <span class="tag" style="font-size:10px"><%= a.getTeam() %></span>
                                <a href="${pageContext.request.contextPath}/army-builder?loadId=<%= a.getId() %>" class="btn sm">Edit</a>
                            </div>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
<%@ include file="_bot-picker.jsp" %>

<div class="modal-overlay" id="deleteAccountModal" style="display:none;align-items:center;justify-content:center">
    <div class="modal-box" style="max-width:420px">
        <div class="modal-header-row">
            <div class="modal-title" style="color:var(--crimson)">Delete Account</div>
            <button class="modal-close-btn" onclick="document.getElementById('deleteAccountModal').style.display='none'">&times;</button>
        </div>
        <p style="font-size:13px;color:var(--ink-mute);margin:8px 0 16px">This will permanently delete your account, all your armies, and all your data. <strong style="color:var(--ink)">This cannot be undone.</strong></p>
        <form method="POST" action="${pageContext.request.contextPath}/deleteAccount">
            <div class="form-group">
                <label class="form-label">Confirm your password to proceed</label>
                <input type="password" name="deletePassword" class="form-input" placeholder="Enter your current password" required autofocus>
            </div>
            <div style="display:flex;gap:8px;margin-top:12px">
                <button type="submit" class="btn danger" style="flex:1">Yes, Delete My Account</button>
                <button type="button" class="btn" onclick="document.getElementById('deleteAccountModal').style.display='none'" style="flex:1">Cancel</button>
            </div>
        </form>
    </div>
</div>
</body>
</html>
