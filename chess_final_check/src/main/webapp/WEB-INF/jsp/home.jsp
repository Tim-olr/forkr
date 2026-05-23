<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Play Online - Forkr</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
</head>
<body>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/home" class="navbar-logo">
        <span class="logo-icon">&#9816;</span>
        <span class="logo-text">Forkr</span>
    </a>
    <ul class="navbar-links">
        <li><a href="${pageContext.request.contextPath}/online-game">Play Online</a></li>
        <li><a href="#" onclick="openBotPicker();return false;">vs Bots</a></li>
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

<!-- ── Bot Picker Modal ────────────────────────────────────────────────────── -->
<div class="modal-overlay" id="botPickerModal" style="display:none">
    <div class="modal-box" style="max-width:520px;max-height:82vh;overflow-y:auto;padding:0">
        <div style="display:flex;justify-content:space-between;align-items:center;padding:20px 24px 14px;position:sticky;top:0;background:var(--surface);z-index:1;border-bottom:1px solid var(--border)">
            <div class="modal-title" style="margin-bottom:0">Play vs Bots</div>
            <button class="modal-close-btn" onclick="closeBotPicker()">&times;</button>
        </div>
        <div id="botPickerBody" style="padding:16px 24px 24px">
            <div id="botCollections"></div>
        </div>
    </div>
</div>

<section class="home-hero">
    <h1>Welcome to<br><span>Forkr!</span></h1>
    <p>The best place to play chess with unique pieces and custom abilities. Challenge players or practice your strategy.</p>
    <div class="home-cta">
        <a href="${pageContext.request.contextPath}/online-game" class="btn btn-green btn-lg">Play Online</a>
        <button type="button" class="btn btn-outline btn-lg" onclick="openBotPicker()">Play vs Bots</button>
        <a href="${pageContext.request.contextPath}/game?localPlay=true" class="btn btn-outline btn-lg">Local Play</a>
        <a href="${pageContext.request.contextPath}/army-builder" class="btn btn-outline btn-lg">Army Builder</a>
    </div>
</section>

<div class="home-features">
    <div class="feature-card">
        <span class="feature-icon">&#9816;</span>
        <h3>Play Any Time</h3>
        <p>Challenge players instantly or play at your own pace with turn-based games available any time.</p>
    </div>
    <div class="feature-card">
        <span class="feature-icon">&#9822;</span>
        <h3>Train &amp; Improve</h3>
        <p>Sharpen your skills with puzzles, openings, and detailed game analysis after every match.</p>
    </div>
    <div class="feature-card">
        <span class="feature-icon">&#9812;</span>
        <h3>Custom Pieces</h3>
        <p>Experience unique piece abilities and special powers not found anywhere else. Build your deck your way.</p>
    </div>
</div>

<script>
var CTX = "${pageContext.request.contextPath}";
var ALL_BOTS = ${allBotsJson};

function openBotPicker() {
    renderBotPicker();
    document.getElementById('botPickerModal').style.display = 'flex';
}
function closeBotPicker() {
    document.getElementById('botPickerModal').style.display = 'none';
}
document.getElementById('botPickerModal').addEventListener('click', function(e) {
    if (e.target === this) closeBotPicker();
});

function renderBotPicker() {
    var container = document.getElementById('botCollections');
    container.innerHTML = '';

    if (!ALL_BOTS || ALL_BOTS.length === 0) {
        container.innerHTML = '<div style="color:var(--text-muted);text-align:center;padding:32px 0">No bots available yet.</div>';
        return;
    }

    // Group by collection
    var grouped = {};
    var order = [];
    ALL_BOTS.forEach(function(bot) {
        var col = bot.collection || 'Uncategorized';
        if (!grouped[col]) { grouped[col] = []; order.push(col); }
        grouped[col].push(bot);
    });

    order.forEach(function(colName) {
        var bots = grouped[colName];
        var details = document.createElement('details');
        details.className = 'bot-collection';
        details.open = true;
        details.style.cssText = 'margin-bottom:12px;border:1px solid var(--border);border-radius:8px;overflow:hidden';

        var summary = document.createElement('summary');
        summary.style.cssText = 'padding:12px 16px;cursor:pointer;font-weight:600;font-size:15px;list-style:none;display:flex;justify-content:space-between;align-items:center;background:var(--surface-alt);user-select:none';
        summary.innerHTML = '<span>' + escHtml(colName) + '</span><span style="color:var(--text-muted);font-size:13px;font-weight:400">' + bots.length + ' bot' + (bots.length !== 1 ? 's' : '') + '</span>';
        details.appendChild(summary);

        var body = document.createElement('div');
        body.style.cssText = 'padding:12px;display:flex;flex-direction:column;gap:8px';

        bots.forEach(function(bot) {
            var card = document.createElement('div');
            card.style.cssText = 'display:flex;align-items:center;gap:14px;padding:10px 12px;border-radius:6px;border:1px solid var(--border);cursor:pointer;transition:background .15s';
            card.onmouseenter = function() { this.style.background = 'var(--surface-alt)'; };
            card.onmouseleave = function() { this.style.background = ''; };
            card.onclick = function() { window.location.href = CTX + '/game?botId=' + bot.id; };

            var imgWrap = document.createElement('div');
            imgWrap.style.cssText = 'width:48px;height:48px;border-radius:50%;overflow:hidden;flex-shrink:0;background:var(--surface-alt);display:flex;align-items:center;justify-content:center;border:2px solid var(--border)';
            if (bot.imagePath) {
                var img = document.createElement('img');
                img.src = CTX + '/' + bot.imagePath;
                img.style.cssText = 'width:100%;height:100%;object-fit:cover';
                imgWrap.appendChild(img);
            } else {
                imgWrap.innerHTML = '<span style="font-size:22px">&#9816;</span>';
            }

            var info = document.createElement('div');
            info.style.flex = '1';
            info.innerHTML = '<div style="font-weight:600;font-size:15px">' + escHtml(bot.name) + '</div>' +
                             '<div style="color:var(--text-muted);font-size:13px">' + bot.elo + ' ELO</div>';

            var playBtn = document.createElement('button');
            playBtn.className = 'btn btn-green';
            playBtn.textContent = 'Play';
            playBtn.style.cssText = 'font-size:13px;padding:6px 16px';
            playBtn.onclick = function(e) { e.stopPropagation(); window.location.href = CTX + '/game?botId=' + bot.id; };

            card.appendChild(imgWrap);
            card.appendChild(info);
            card.appendChild(playBtn);
            body.appendChild(card);
        });

        details.appendChild(body);
        container.appendChild(details);
    });
}

function escHtml(s) {
    if (!s) return '';
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

</script>
</body>
</html>
