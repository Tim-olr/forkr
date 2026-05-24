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
                <span class="crumb-pre">Forkr</span>
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
                            <div class="home-stat-val display"><%= kp %></div>
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
                                <div class="challenge-row">
                                    <div class="challenge-icon"><svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M8 2l1.8 3.6L14 6.2l-3 2.9.7 4.1L8 11.1 4.3 13.2l.7-4.1L2 6.2l4.2-.6L8 2z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/></svg></div>
                                    <div style="flex:1;min-width:0">
                                        <div class="ch-name">Play 3 online games</div>
                                        <div class="ch-meta">+50 KP reward</div>
                                        <div class="ch-bar"><div style="width:33%"></div></div>
                                    </div>
                                    <div class="ch-prog">1/3</div>
                                </div>
                                <div class="challenge-row">
                                    <div class="challenge-icon ok"><svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M3 8l4 4 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></div>
                                    <div style="flex:1;min-width:0">
                                        <div class="ch-name">Win a game with a custom piece</div>
                                        <div class="ch-meta">+75 KP reward — completed</div>
                                        <div class="ch-bar"><div style="width:100%"></div></div>
                                    </div>
                                    <div class="ch-prog" style="color:var(--moss)">✓</div>
                                </div>
                                <div class="challenge-row">
                                    <div class="challenge-icon"><svg width="14" height="14" viewBox="0 0 16 16" fill="none"><circle cx="8" cy="8" r="5" stroke="currentColor" stroke-width="1.4"/><path d="M8 5v3l2 2" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg></div>
                                    <div style="flex:1;min-width:0">
                                        <div class="ch-name">Build an army</div>
                                        <div class="ch-meta">+30 KP reward</div>
                                        <div class="ch-bar"><div style="width:0%"></div></div>
                                    </div>
                                    <div class="ch-prog">0/1</div>
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

<!-- Bot picker modal -->
<div class="modal-backdrop" id="botPickerModal" style="display:none" onclick="if(event.target===this)closeBotPicker()">
    <div class="modal" style="max-width:520px;max-height:82vh;overflow:hidden;display:flex;flex-direction:column">
        <div class="modal-head">
            <span class="modal-title">Play vs Bots</span>
            <button class="modal-close" onclick="closeBotPicker()">✕</button>
        </div>
        <div id="botPickerBody" style="overflow-y:auto;flex:1;padding:16px 20px 20px"></div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/piece-art.js"></script>
<script>
var CTX = "${pageContext.request.contextPath}";
var ALL_BOTS = ${allBotsJson};

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

function openBotPicker() {
    renderBotPicker();
    document.getElementById('botPickerModal').style.display = 'flex';
}
function closeBotPicker() {
    document.getElementById('botPickerModal').style.display = 'none';
}
function renderBotPicker() {
    var container = document.getElementById('botPickerBody');
    container.innerHTML = '';
    if (!ALL_BOTS || ALL_BOTS.length === 0) {
        container.innerHTML = '<div style="color:var(--ink-faint);text-align:center;padding:32px 0;font-size:13px">No bots available yet.</div>';
        return;
    }
    var grouped = {}, order = [];
    ALL_BOTS.forEach(function(b) {
        var col = b.collection || 'Bots';
        if (!grouped[col]) { grouped[col] = []; order.push(col); }
        grouped[col].push(b);
    });
    order.forEach(function(col) {
        var h = document.createElement('div');
        h.style.cssText = 'font-size:11px;letter-spacing:.1em;text-transform:uppercase;color:var(--ink-faint);font-family:var(--font-mono);padding:8px 0 6px';
        h.textContent = col;
        container.appendChild(h);
        grouped[col].forEach(function(bot) {
            var card = document.createElement('div');
            card.style.cssText = 'display:flex;align-items:center;gap:12px;padding:10px 12px;border:1px solid var(--line);border-radius:6px;cursor:pointer;margin-bottom:8px;transition:background .12s';
            card.onmouseenter = function() { this.style.background='var(--bg-elev)'; };
            card.onmouseleave = function() { this.style.background=''; };
            card.onclick = function() { window.location.href = CTX + '/game?botId=' + bot.id; };
            var iw = document.createElement('div');
            iw.style.cssText = 'width:40px;height:40px;border-radius:50%;overflow:hidden;flex-shrink:0;background:var(--bg-elev-2);display:flex;align-items:center;justify-content:center;border:1px solid var(--line)';
            if (bot.imagePath) { var img=document.createElement('img'); img.src=CTX+'/'+bot.imagePath; img.style.cssText='width:100%;height:100%;object-fit:cover'; iw.appendChild(img); }
            else iw.innerHTML='<svg width="22" height="22" viewBox="0 0 45 45"><circle fill="url(#bg0)" stroke="#3a1800" stroke-width="1.5" cx="22.5" cy="11.5" r="5.5"/></svg>';
            var info = document.createElement('div'); info.style.flex='1';
            info.innerHTML='<div style="font-size:13.5px;font-weight:500">'+escHtml(bot.name)+'</div><div style="color:var(--ink-faint);font-size:12px">'+bot.elo+' ELO</div>';
            var btn = document.createElement('button'); btn.className='btn sm'; btn.textContent='Play';
            btn.onclick=function(e){e.stopPropagation();window.location.href=CTX+'/game?botId='+bot.id;};
            card.appendChild(iw); card.appendChild(info); card.appendChild(btn);
            container.appendChild(card);
        });
    });
}
function escHtml(s){if(!s)return'';return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
</script>
</body>
</html>
