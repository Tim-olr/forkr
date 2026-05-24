<%-- _sidebar.jsp — app shell sidebar. Include after opening <div class="app-shell">.
     Requires session attrs: username, isAdmin. Caller sets activeNav (String). --%>
<%
    Object _activeNavObj = pageContext.getAttribute("activeNav");
    String _activeNav = _activeNavObj != null ? _activeNavObj.toString() : "";
    boolean _isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    String _username = (String) session.getAttribute("username");
    String _avatarLetter = (_username != null && !_username.isEmpty())
        ? String.valueOf(_username.charAt(0)).toUpperCase() : "?";
%>
<nav class="sidebar">
    <div class="sidebar-brand">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect x="2" y="18" width="20" height="3" rx="1" fill="#d4a44a"/>
            <rect x="9" y="15" width="6" height="3" rx="0.5" fill="#d4a44a"/>
            <circle cx="12" cy="10" r="4" fill="#d4a44a"/>
            <circle cx="12" cy="10" r="1.5" fill="#14110d"/>
        </svg>
        <span style="font-family:var(--font-display);font-size:18px;letter-spacing:-0.01em">Forkr</span>
    </div>

    <div class="sidebar-group">
        <div class="sidebar-group-title">Play</div>
        <a href="${pageContext.request.contextPath}/online-game" class="nav-item <%= "online".equals(_activeNav) ? "active" : "" %>">
            <span class="nav-icon">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><circle cx="8" cy="8" r="6" stroke="currentColor" stroke-width="1.5"/><path d="M8 4v4l3 2" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
            </span>
            Play Online
        </a>
        <a href="javascript:void(0)" onclick="if(typeof openBotPicker==='function')openBotPicker()" class="nav-item <%= "bots".equals(_activeNav) ? "active" : "" %>">
            <span class="nav-icon">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><rect x="3" y="6" width="10" height="8" rx="2" stroke="currentColor" stroke-width="1.5"/><circle cx="6" cy="10" r="1" fill="currentColor"/><circle cx="10" cy="10" r="1" fill="currentColor"/><path d="M8 2v4M6 3h4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
            </span>
            vs Bots
        </a>
        <a href="${pageContext.request.contextPath}/game?localPlay=true" class="nav-item <%= "local".equals(_activeNav) ? "active" : "" %>">
            <span class="nav-icon">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M2 14h12M4 10h8M8 2v8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
            </span>
            Local Play
        </a>
    </div>

    <div class="sidebar-group">
        <div class="sidebar-group-title">Build</div>
        <a href="${pageContext.request.contextPath}/army-builder" class="nav-item <%= "army".equals(_activeNav) ? "active" : "" %>">
            <span class="nav-icon">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M8 2L3 6v8h10V6L8 2z" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/><path d="M6 14v-4h4v4" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/></svg>
            </span>
            Army Builder
        </a>
        <a href="${pageContext.request.contextPath}/academy" class="nav-item <%= "academy".equals(_activeNav) ? "active" : "" %>">
            <span class="nav-icon">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><polygon points="8,2 15,6 8,10 1,6" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/><path d="M4 8v4c0 1.5 2 2 4 2s4-.5 4-2V8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
            </span>
            Academy
        </a>
    </div>

    <div class="sidebar-group">
        <div class="sidebar-group-title">Account</div>
        <a href="${pageContext.request.contextPath}/profile" class="nav-item <%= "profile".equals(_activeNav) ? "active" : "" %>">
            <span class="nav-icon">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><circle cx="8" cy="5" r="3" stroke="currentColor" stroke-width="1.5"/><path d="M2 14c0-3 2.5-5 6-5s6 2 6 5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
            </span>
            Profile
        </a>
        <a href="${pageContext.request.contextPath}/support" class="nav-item <%= "support".equals(_activeNav) ? "active" : "" %>">
            <span class="nav-icon">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><circle cx="8" cy="8" r="6" stroke="currentColor" stroke-width="1.5"/><path d="M6 6c0-1.1.9-2 2-2s2 .9 2 2c0 1.5-2 1.5-2 3M8 12v.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
            </span>
            Support
        </a>
    </div>

    <% if (_isAdmin) { %>
    <div class="sidebar-group">
        <div class="sidebar-group-title">Admin</div>
        <a href="${pageContext.request.contextPath}/admin" class="nav-item <%= "admin".equals(_activeNav) ? "active" : "" %>">
            <span class="nav-icon">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><rect x="2" y="2" width="5" height="5" rx="1" stroke="currentColor" stroke-width="1.5"/><rect x="9" y="2" width="5" height="5" rx="1" stroke="currentColor" stroke-width="1.5"/><rect x="2" y="9" width="5" height="5" rx="1" stroke="currentColor" stroke-width="1.5"/><rect x="9" y="9" width="5" height="5" rx="1" stroke="currentColor" stroke-width="1.5"/></svg>
            </span>
            Dashboard
        </a>
    </div>
    <% } %>

    <div class="sidebar-foot">
        <div class="avatar" style="width:28px;height:28px;font-size:12px;flex-shrink:0"><%= _avatarLetter %></div>
        <div style="flex:1;min-width:0;overflow:hidden">
            <div class="user-name" style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><%= _username != null ? _username : "" %></div>
            <% if (_isAdmin) { %><div class="user-role">Admin</div><% } %>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="icon-btn" title="Log out">
            <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M6 2H3a1 1 0 00-1 1v10a1 1 0 001 1h3M10 11l3-3-3-3M13 8H6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </a>
    </div>
</nav>
