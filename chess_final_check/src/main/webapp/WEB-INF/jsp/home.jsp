<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.game.MatchRecord, java.util.List" %>
<%
    pageContext.setAttribute("pageTitle", "Home");
    pageContext.setAttribute("activeNav", "home");
    List<MatchRecord> recentMatches = (List<MatchRecord>) pageContext.findAttribute("recentMatches");
    if (recentMatches == null) recentMatches = new java.util.ArrayList<>();
    int userElo = pageContext.findAttribute("userElo") != null ? (Integer) pageContext.findAttribute("userElo") : 0;
    int kp      = pageContext.findAttribute("knowledgePoints") != null ? (Integer) pageContext.findAttribute("knowledgePoints") : 0;
    int unlocked   = pageContext.findAttribute("unlockedCount") != null ? (Integer) pageContext.findAttribute("unlockedCount") : 6;
    int totalPieces= pageContext.findAttribute("totalPieces") != null ? (Integer) pageContext.findAttribute("totalPieces") : 35;

    // Daily challenge state
    int  chPlay3Progress = pageContext.findAttribute("chPlay3Progress") != null ? (Integer) pageContext.findAttribute("chPlay3Progress") : 0;
    boolean chPlay3Claimed = pageContext.findAttribute("chPlay3Claimed") != null && (Boolean) pageContext.findAttribute("chPlay3Claimed");
    int  chWin1Progress  = pageContext.findAttribute("chWin1Progress") != null ? (Integer) pageContext.findAttribute("chWin1Progress") : 0;
    boolean chWin1Claimed  = pageContext.findAttribute("chWin1Claimed") != null && (Boolean) pageContext.findAttribute("chWin1Claimed");
    int  chBuildArmyProgress = pageContext.findAttribute("chBuildArmyProgress") != null ? (Integer) pageContext.findAttribute("chBuildArmyProgress") : 0;
    boolean chBuildArmyClaimed = pageContext.findAttribute("chBuildArmyClaimed") != null && (Boolean) pageContext.findAttribute("chBuildArmyClaimed");
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
                <span class="crumb-pre">Gambitonline</span>
                <h2>Dashboard</h2>
            </div>
            <div class="page-actions">
                <a href="${pageContext.request.contextPath}/online-game" class="btn primary">Play Online</a>
            </div>
        </div>

        <div class="page-body">
            <div class="home">
                <!-- Hero strip -->
                <div class="home-hero">
                    <div class="home-hero-left">
                        <div class="tiny-caps">Welcome back</div>
                        <div class="home-title display"><s:property value="loggedInUsername" /></div>
                        <p class="home-sub">Ready to play? Jump straight into a match or keep building your army.</p>
                        <div class="home-cta-row">
                            <a href="${pageContext.request.contextPath}/online-game" class="btn primary lg">Play Online</a>
                            <a href="javascript:void(0)" onclick="openBotPicker()" class="btn lg">vs Bots</a>
                            <a href="${pageContext.request.contextPath}/game?localPlay=true" class="btn lg">Local Play</a>
                            <a href="${pageContext.request.contextPath}/army-builder" class="btn lg">Army Builder</a>
                        </div>
                    </div>
                    <div class="home-hero-right">
                        <div class="home-stat">
                            <div class="tiny-caps">Rating</div>
                            <div class="home-stat-val display"><%= userElo %></div>
                            <div class="home-stat-unit">ELO</div>
                        </div>
                        <div class="home-stat">
                            <div class="tiny-caps">Knowledge Points</div>
                            <div class="home-stat-val display" data-kp="1"><%= kp %></div>
                            <div class="home-stat-unit">KP</div>
                        </div>
                        <div class="home-stat">
                            <div class="tiny-caps">Pieces Unlocked</div>
                            <div class="home-stat-val display"><%= unlocked %><span style="font-size:16px;color:var(--ink-faint)">/<%= totalPieces %></span></div>
                        </div>
                    </div>
                </div>

                <!-- Main grid -->
                <div class="home-grid">
                    <!-- Recent matches -->
                    <div class="card home-card">
                        <div style="display:flex;justify-content:space-between;align-items:center;padding:14px 16px;border-bottom:1px solid var(--line)">
                            <span style="font-size:13px;font-weight:500">Recent Games</span>
                            <span class="tiny-caps">last 5</span>
                        </div>
                        <% if (recentMatches.isEmpty()) { %>
                        <div style="padding:32px 16px;text-align:center;color:var(--ink-faint);font-size:13px">
                            No games played yet. <a href="${pageContext.request.contextPath}/online-game" style="color:var(--amber)">Play your first match →</a>
                        </div>
                        <% } else { %>
                        <div class="table-wrap" style="overflow:auto">
                            <table class="data-table">
                                <thead><tr><th>Opponent</th><th>Result</th><th>Duration</th><th>Date</th></tr></thead>
                                <tbody>
                                <%
                                    Long viewingUserId = (Long) session.getAttribute("userId");
                                    for (MatchRecord mr : recentMatches) {
                                        boolean isWhite = mr.getWhiteUserId() != null && mr.getWhiteUserId().equals(viewingUserId);
                                        String opponent = isWhite ? mr.getBlackUsername() : mr.getWhiteUsername();
                                        String result = mr.getResult();
                                        boolean won = ("1-0".equals(result) && isWhite) || ("0-1".equals(result) && !isWhite);
                                        boolean drew = "1/2-1/2".equals(result);
                                        String rClass = won ? "moss" : (drew ? "ink-faint" : "crimson");
                                        String rLabel = won ? "Win" : (drew ? "Draw" : "Loss");
                                %>
                                <tr>
                                    <td><%= opponent != null ? opponent : "—" %></td>
                                    <td><span style="color:var(--<%= rClass %>);font-weight:500"><%= rLabel %></span>
                                        <span style="color:var(--ink-faint);font-size:11px;margin-left:4px"><%= result %></span></td>
                                    <td style="font-family:var(--font-mono);font-size:12px"><%= mr.getFormattedDuration() %></td>
                                    <td style="color:var(--ink-faint);font-size:12px"><%= mr.getPlayedAt() != null ? mr.getPlayedAt().toLocalDate().toString() : "—" %></td>
                                </tr>
                                <% } %>
                                </tbody>
                            </table>
                        </div>
                        <% } %>
                    </div>

                    <!-- Daily challenges + news -->
                    <div style="display:flex;flex-direction:column;gap:14px">
                        <div class="card">
                            <div style="padding:14px 16px;border-bottom:1px solid var(--line)">
                                <span style="font-size:13px;font-weight:500">Daily Challenges</span>
                            </div>
                            <div style="padding:6px 16px 12px">

                                <%-- Challenge: Play 3 online games --%>
                                <%
                                    boolean p3done = chPlay3Progress >= 3;
                                    boolean p3claimable = p3done && !chPlay3Claimed;
                                    String p3barW = (chPlay3Progress * 100 / 3) + "%";
                                %>
                                <div class="challenge-row" id="ch-play3">
                                    <div class="challenge-icon <%= p3done ? "ok" : "" %>">
                                        <% if (p3done) { %><svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M3 8l4 4 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                        <% } else { %><svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M8 2l1.8 3.6L14 6.2l-3 2.9.7 4.1L8 11.1 4.3 13.2l.7-4.1L2 6.2l4.2-.6L8 2z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/></svg>
                                        <% } %>
                                    </div>
                                    <div style="flex:1;min-width:0">
                                        <div class="ch-name">Play 3 online games</div>
                                        <div class="ch-meta">+50 KP reward<% if (chPlay3Claimed) { %> — <span style="color:var(--moss)">claimed</span><% } %></div>
                                        <div class="ch-bar"><div style="width:<%= p3barW %>"></div></div>
                                    </div>
                                    <% if (chPlay3Claimed) { %>
                                    <div class="ch-prog" style="color:var(--moss)">✓</div>
                                    <% } else if (p3claimable) { %>
                                    <button class="btn primary" style="padding:3px 10px;font-size:11px" onclick="claimChallenge('play3',this)">Claim</button>
                                    <% } else { %>
                                    <div class="ch-prog"><%= chPlay3Progress %>/3</div>
                                    <% } %>
                                </div>

                                <%-- Challenge: Win a game --%>
                                <%
                                    boolean w1done = chWin1Progress >= 1;
                                    boolean w1claimable = w1done && !chWin1Claimed;
                                %>
                                <div class="challenge-row" id="ch-win1">
                                    <div class="challenge-icon <%= w1done ? "ok" : "" %>">
                                        <% if (w1done) { %><svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M3 8l4 4 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                        <% } else { %><svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M8 2l1.8 3.6L14 6.2l-3 2.9.7 4.1L8 11.1 4.3 13.2l.7-4.1L2 6.2l4.2-.6L8 2z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/></svg>
                                        <% } %>
                                    </div>
                                    <div style="flex:1;min-width:0">
                                        <div class="ch-name">Win a game today</div>
                                        <div class="ch-meta">+75 KP reward<% if (chWin1Claimed) { %> — <span style="color:var(--moss)">claimed</span><% } %></div>
                                        <div class="ch-bar"><div style="width:<%= w1done ? "100" : "0" %>%"></div></div>
                                    </div>
                                    <% if (chWin1Claimed) { %>
                                    <div class="ch-prog" style="color:var(--moss)">✓</div>
                                    <% } else if (w1claimable) { %>
                                    <button class="btn primary" style="padding:3px 10px;font-size:11px" onclick="claimChallenge('win1',this)">Claim</button>
                                    <% } else { %>
                                    <div class="ch-prog"><%= chWin1Progress %>/1</div>
                                    <% } %>
                                </div>

                                <%-- Challenge: Build an army --%>
                                <%
                                    boolean badone = chBuildArmyProgress >= 1;
                                    boolean baclaimable = badone && !chBuildArmyClaimed;
                                %>
                                <div class="challenge-row" id="ch-build_army">
                                    <div class="challenge-icon <%= badone ? "ok" : "" %>">
                                        <% if (badone) { %><svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M3 8l4 4 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                        <% } else { %><svg width="14" height="14" viewBox="0 0 16 16" fill="none"><circle cx="8" cy="8" r="5" stroke="currentColor" stroke-width="1.4"/><path d="M8 5v3l2 2" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>
                                        <% } %>
                                    </div>
                                    <div style="flex:1;min-width:0">
                                        <div class="ch-name">Build an army</div>
                                        <div class="ch-meta">+30 KP reward<% if (chBuildArmyClaimed) { %> — <span style="color:var(--moss)">claimed</span><% } %></div>
                                        <div class="ch-bar"><div style="width:<%= badone ? "100" : "0" %>%"></div></div>
                                    </div>
                                    <% if (chBuildArmyClaimed) { %>
                                    <div class="ch-prog" style="color:var(--moss)">✓</div>
                                    <% } else if (baclaimable) { %>
                                    <button class="btn primary" style="padding:3px 10px;font-size:11px" onclick="claimChallenge('build_army',this)">Claim</button>
                                    <% } else { %>
                                    <div class="ch-prog"><%= chBuildArmyProgress %>/1</div>
                                    <% } %>
                                </div>

                            </div>
                        </div>

                        <div class="card">
                            <div style="padding:14px 16px;border-bottom:1px solid var(--line)">
                                <span style="font-size:13px;font-weight:500">Quick Links</span>
                            </div>
                            <div style="padding:10px 14px;display:flex;flex-direction:column;gap:6px">
                                <a href="${pageContext.request.contextPath}/academy" class="btn ghost" style="justify-content:flex-start;gap:10px">
                                    <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><polygon points="8,2 15,6 8,10 1,6" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/><path d="M4 8v4c0 1.5 2 2 4 2s4-.5 4-2V8" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>
                                    Academy — unlock more pieces
                                </a>
                                <a href="${pageContext.request.contextPath}/army-builder" class="btn ghost" style="justify-content:flex-start;gap:10px">
                                    <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M8 2L3 6v8h10V6L8 2z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/></svg>
                                    Build or edit your army
                                </a>
                                <a href="${pageContext.request.contextPath}/profile" class="btn ghost" style="justify-content:flex-start;gap:10px">
                                    <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><circle cx="8" cy="5" r="3" stroke="currentColor" stroke-width="1.4"/><path d="M2 14c0-3 2.5-5 6-5s6 2 6 5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>
                                    Edit profile &amp; change password
                                </a>
                                <a href="${pageContext.request.contextPath}/support" class="btn ghost" style="justify-content:flex-start;gap:10px">
                                    <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><circle cx="8" cy="8" r="6" stroke="currentColor" stroke-width="1.4"/><path d="M6 6c0-1.1.9-2 2-2s2 .9 2 2c0 1.5-2 1.5-2 3M8 12v.5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>
                                    Submit a support ticket
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Featured pieces row -->
                <div class="card">
                    <div style="padding:14px 16px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center">
                        <span style="font-size:13px;font-weight:500">Featured Pieces</span>
                        <a href="${pageContext.request.contextPath}/academy" style="font-size:12px;color:var(--amber);text-decoration:none">View Academy →</a>
                    </div>
                    <div style="padding:16px">
                        <div class="featured-row" id="featuredPieces">
                            <!-- populated by JS -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script src="${pageContext.request.contextPath}/js/piece-art.js"></script>
<script>
var CTX = "${pageContext.request.contextPath}";

function claimChallenge(id, btn) {
    btn.disabled = true;
    btn.textContent = '…';
    fetch(CTX + '/claimChallenge?challengeId=' + id, {method:'POST'})
        .then(function(r){ return r.json(); })
        .then(function(data) {
            if (!data.ok) { btn.disabled = false; btn.textContent = 'Claim'; return; }
            var row = document.getElementById('ch-' + id);
            // Mark icon as complete
            var icon = row.querySelector('.challenge-icon');
            icon.classList.add('ok');
            icon.innerHTML = '<svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M3 8l4 4 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';
            // Fill bar
            var bar = row.querySelector('.ch-bar div');
            if (bar) bar.style.width = '100%';
            // Update meta text
            var meta = row.querySelector('.ch-meta');
            if (meta) meta.innerHTML = meta.innerHTML.replace(/\+\d+ KP reward/, function(m){ return m; }) + ' — <span style="color:var(--moss)">claimed</span>';
            // Replace button with checkmark
            btn.parentNode.replaceChild(Object.assign(document.createElement('div'), {
                className: 'ch-prog', style: 'color:var(--moss)', textContent: '✓'
            }), btn);
            // Update KP display
            var kpEl = document.querySelector('.home-stat-val[data-kp]');
            if (kpEl) kpEl.textContent = data.kp;
        })
        .catch(function(){ btn.disabled = false; btn.textContent = 'Claim'; });
}

// Featured pieces
(function() {
    var featured = ['q','r','b','n','k','fk','wz','sc','cy'];
    var labels   = {q:'Queen',r:'Rook',b:'Bishop',n:'Knight',k:'King',fk:'Fork',wz:'Wizard',sc:'Scout',cy:'Cyclops'};
    var row = document.getElementById('featuredPieces');
    featured.slice(0,8).forEach(function(ch) {
        var a = document.createElement('a');
        a.href = CTX + '/academy';
        a.className = 'featured-piece';
        var glyph = document.createElement('div');
        glyph.className = 'featured-glyph';
        glyph.appendChild(window.buildPieceSVG(ch, true));
        a.appendChild(glyph);
        var nm = document.createElement('div');
        nm.className = 'featured-name';
        nm.textContent = labels[ch] || ch.toUpperCase();
        a.appendChild(nm);
        row.appendChild(a);
    });
}());

</script>
<%@ include file="_bot-picker.jsp" %>
</body>
</html>
