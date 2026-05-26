<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.game.pieces.PieceDefinition, timolr.chess.game.pieces.PieceRegistry, java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chess - Play Online</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Newsreader:ital,opsz,wght@0,6..72,300..700;1,6..72,300..700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/forkr.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
    <style>body{background:var(--bg)!important;overflow:hidden}</style>
    <script src="${pageContext.request.contextPath}/js/piece-art.js"></script>
    <style>
    @keyframes lanternFlash {
        0%   { opacity: 0; transform: scale(0.4); }
        25%  { opacity: 1; }
        100% { opacity: 0; transform: scale(2.8); }
    }
    .lantern-flash-effect {
        position: absolute; inset: 0; border-radius: 50%; pointer-events: none; z-index: 50;
        background: radial-gradient(circle, rgba(255,220,40,0.95) 0%, rgba(255,140,0,0.75) 45%, transparent 72%);
        animation: lanternFlash 0.75s ease-out forwards;
    }
    @keyframes curseTrigger {
        0%   { opacity: 0; transform: scale(0.6); }
        20%  { opacity: 1; }
        100% { opacity: 0; transform: scale(2.2); }
    }
    .oracle-curse-trigger-effect {
        position: absolute; inset: 0; border-radius: 50%; pointer-events: none; z-index: 50;
        background: radial-gradient(circle, rgba(180,0,255,0.9) 0%, rgba(80,0,160,0.6) 50%, transparent 75%);
        animation: curseTrigger 0.7s ease-out forwards;
    }
    @keyframes oracleStartReveal {
        0%   { opacity: 0; transform: scale(0.3); }
        30%  { opacity: 1; }
        70%  { opacity: 0.9; transform: scale(1.6); }
        100% { opacity: 0; transform: scale(2.8); }
    }
    .oracle-start-reveal {
        position: absolute; inset: 0; pointer-events: none; z-index: 50;
        background: radial-gradient(circle, rgba(220,60,255,1) 0%, rgba(120,0,200,0.7) 40%, transparent 70%);
        animation: oracleStartReveal 1.1s ease-out forwards;
    }
    @keyframes cursePulse {
        0%,100%{box-shadow:inset 0 0 0 2px rgba(180,0,255,0.5),inset 0 0 12px rgba(140,0,220,0.25);}
        50%{box-shadow:inset 0 0 0 3px rgba(220,80,255,0.95),inset 0 0 20px rgba(180,0,255,0.55);}
    }
    @keyframes skullFloat {
        0%,100%{transform:translate(-50%,-50%) scale(1);opacity:0.88;}
        50%{transform:translate(-50%,-57%) scale(1.13);opacity:1;}
    }
    @keyframes boardShake {
        0%,100%{transform:translateX(0) rotate(0)}
        15%{transform:translateX(-10px) rotate(-0.5deg)}
        30%{transform:translateX(10px) rotate(0.5deg)}
        45%{transform:translateX(-7px) rotate(-0.3deg)}
        60%{transform:translateX(7px) rotate(0.3deg)}
        75%{transform:translateX(-4px)}
        90%{transform:translateX(4px)}
    }
    @keyframes kingDefeatedPulse {
        0%{background:rgba(220,30,30,0);}
        18%{background:rgba(220,30,30,0.75);}
        45%{background:rgba(220,30,30,0.2);}
        68%{background:rgba(220,30,30,0.7);}
        100%{background:rgba(220,30,30,0);}
    }
    .board-shake { animation: boardShake 0.55s ease-out; }
    .king-defeated { animation: kingDefeatedPulse 0.9s ease forwards !important; }
    .oracle-cursed { position: relative; animation: cursePulse 1.5s ease-in-out infinite; }
    .curse-marker {
        position: absolute; top: 50%; left: 50%;
        font-size: 1.55em; pointer-events: none; z-index: 10;
        filter: drop-shadow(0 0 6px rgba(210,0,255,1)) drop-shadow(0 0 14px rgba(180,0,255,0.75));
        animation: skullFloat 1.5s ease-in-out infinite;
    }
    .cell.curse-valid { background: rgba(160,0,220,0.22) !important; }
    .cell.lantern-immobilized::after {
        content: ''; position: absolute; inset: 0;
        background: rgba(40,80,180,0.18); pointer-events: none;
    }
    #ogCursePanel { margin-top: 8px; }
    .player-clock {
        font-family: var(--font-mono, monospace);
        font-size: 20px;
        font-weight: 600;
        background: var(--bg-elev, #1a1612);
        border: 1px solid var(--line, rgba(255,255,255,0.12));
        border-radius: 4px;
        padding: 5px 10px;
        min-width: 68px;
        text-align: center;
        letter-spacing: 2px;
        color: var(--ink, #fefbf2);
        flex-shrink: 0;
    }
    .player-clock.clock-active {
        border-color: var(--amber, #d4a44a);
        color: var(--amber, #d4a44a);
    }
    .player-clock.clock-low {
        color: var(--crimson, #c8553d) !important;
        border-color: rgba(200,85,61,0.55) !important;
        animation: clockPulse 0.8s ease-in-out infinite;
    }
    @keyframes clockPulse {
        0%,100% { background: var(--bg-elev, #1a1612); }
        50% { background: rgba(200,85,61,0.18); }
    }
    </style>
</head>
<body>
<div class="app-shell">
<% pageContext.setAttribute("activeNav", "online"); %>
<%@ include file="_sidebar.jsp" %>
<main class="page" style="overflow:auto;min-height:0">

<!-- Searching screen -->
<div id="searchingScreen" class="og-searching">
    <div class="og-search-box">
        <div class="og-spinner"></div>
        <h2 class="og-search-title">Finding Opponent&hellip;</h2>
        <p class="og-search-sub">Your ELO: <strong><s:property value="loggedInElo" /></strong></p>
        <p class="og-search-sub" id="waitTimer">Searching for 0s</p>
        <button class="btn btn-outline" onclick="cancelSearch()">Cancel</button>
    </div>
</div>

<!-- Game screen (hidden until matched) -->
<div id="gameScreen" class="game-container" style="display:none">
    <div class="game-panel-left">
        <div class="player-info" id="topPlayerInfo">
            <div class="player-avatar" id="topAvatar">&#9812;</div>
            <div style="flex:1">
                <div class="player-name" id="topName">Opponent</div>
                <div class="player-rating" id="topRating">600</div>
            </div>
            <div class="player-clock" id="topClock">10:00</div>
        </div>
        <div class="game-status" id="statusBox">Waiting&hellip;</div>
        <div class="game-actions">
            <button class="btn btn-outline" id="resignBtn" style="flex:1">Resign</button>
        </div>
    </div>

    <div class="board-container">
        <div class="board" id="chessBoard"></div>
        <svg id="arrowSVG" class="arrow-svg" viewBox="0 0 560 560" xmlns="http://www.w3.org/2000/svg"></svg>
        <div class="game-over-overlay" id="gameOverlay" style="display:none">
            <div class="game-over-msg" id="gameOverMsg"></div>
            <div id="eloChangeMsg" style="font-size:18px;margin:8px 0;color:#81b64c"></div>
            <button class="btn btn-green btn-lg" onclick="location.href='${pageContext.request.contextPath}/online-game'">Play Again</button>
        </div>
    </div>

    <div class="game-panel-right">
        <div class="player-info" id="bottomPlayerInfo">
            <div class="player-avatar" id="bottomAvatar">&#9818;</div>
            <div style="flex:1">
                <div class="player-name" id="bottomName"><s:property value="loggedInUsername" /></div>
                <div class="player-rating" id="bottomRating"><s:property value="loggedInElo" /></div>
            </div>
            <div class="player-clock" id="bottomClock">10:00</div>
        </div>
        <div class="move-history" id="moveHistory">
            <h4>Move History</h4>
            <table class="move-list" id="moveList"></table>
        </div>
        <div class="game-controls">
            <button class="ctrl-btn" id="btnFirst" title="Start">&#9664;&#9664;</button>
            <button class="ctrl-btn" id="btnPrev"  title="Back">&#9664;</button>
            <button class="ctrl-btn" id="btnNext"  title="Forward">&#9654;</button>
            <button class="ctrl-btn" id="btnLast"  title="End">&#9654;&#9654;</button>
        </div>
    </div>
</div>

<div class="modal-overlay" id="promotionModal" style="display:none">
    <div class="modal-box" style="max-width:340px">
        <div class="promo-title">Promote Pawn</div>
        <div class="promo-options" id="promoOptions"></div>
    </div>
</div>

<script>
var CTX = '${pageContext.request.contextPath}';
var MY_USERNAME = '<s:property value="loggedInUsername" />';
var MY_ELO = <s:property value="loggedInElo" />;

<%-- Piece registry from PieceRegistry.java --%>
<%  List<PieceDefinition> ogPieceDefs = PieceRegistry.getAll(); %>
var PIECE_REGISTRY = [
<% for (PieceDefinition pd : ogPieceDefs) { %>
    { type: "<%= pd.getType() %>", sprite: <%= pd.getSprite() != null ? "\"" + pd.getSprite() + "\"" : "null" %>, gameChar: "<%= pd.getGameChar() %>", whiteUnicode: "<%= pd.getWhiteUnicode() %>", blackUnicode: "<%= pd.getBlackUnicode() %>", special: <%= pd.isSpecial() %>, fwd: <%= pd.isCanMoveForwards() %>, bwd: <%= pd.isCanMoveBackwards() %>, side: <%= pd.isCanMoveSideways() %>, diag: <%= pd.isCanMoveDiagonally() %>, jump: <%= pd.isCanJump() %>, lshape: <%= pd.isCanMoveInLShape() %>, range: <%= pd.getRange() %> },
<% } %>
];

var searchStart = Date.now();
var searchTimer = setInterval(function() {
    var sec = Math.floor((Date.now() - searchStart) / 1000);
    var el = document.getElementById('waitTimer');
    if (el) el.textContent = 'Searching for ' + sec + 's';
}, 1000);

var _SFX_CTX=new(window.AudioContext||window.webkitAudioContext)();
var _SFX_BUFS={};
(function(){var base='${pageContext.request.contextPath}/sounds/';['move','take','check','game_end','game_start'].forEach(function(n){fetch(base+n+'.mp3').then(function(r){return r.arrayBuffer();}).then(function(b){return _SFX_CTX.decodeAudioData(b);}).then(function(d){_SFX_BUFS[n]=d;}).catch(function(){});});})();
function playSound(name){var b=_SFX_BUFS[name];if(!b)return;if(_SFX_CTX.state==='suspended')_SFX_CTX.resume();var s=_SFX_CTX.createBufferSource();s.buffer=b;s.connect(_SFX_CTX.destination);s.start(0);}

var gameId = null, myColor = null;
var queueInterval = setInterval(pollQueue, 1200);
var gameInterval = null;
var inactivityTimer = null;

// Chess clock state (synced from server each poll)
var clkWt = 600000, clkBt = 600000, clkTurn = 'w', clkSyncAt = 0;

function syncTimer(data) {
    if (data.wt !== undefined) clkWt = data.wt;
    if (data.bt !== undefined) clkBt = data.bt;
    if (data.tt !== undefined) clkTurn = data.tt;
    clkSyncAt = Date.now();
}
function clkGet(color) {
    var base = color === 'w' ? clkWt : clkBt;
    if (clkTurn === color && clkSyncAt > 0) {
        base = Math.max(0, base - (Date.now() - clkSyncAt));
    }
    return base;
}
function clkFmt(ms) {
    var s = Math.ceil(ms / 1000);
    var m = Math.floor(s / 60); s = s % 60;
    return m + ':' + (s < 10 ? '0' + s : s);
}
function renderClocks() {
    if (!gs || !gs.board || gs.gameOver) return;
    var flip = gs.playerColor === 'b';
    // topClock = opponent's clock, bottomClock = my clock
    var oppColor = gs.playerColor === 'w' ? 'b' : 'w';
    var myTime = clkGet(gs.playerColor);
    var oppTime = clkGet(oppColor);
    var myTurn = gs.turn === gs.playerColor;
    var oppTurn = !myTurn;
    var bc = document.getElementById('bottomClock');
    var tc = document.getElementById('topClock');
    if (bc) {
        bc.textContent = clkFmt(myTime);
        bc.className = 'player-clock' + (myTurn ? ' clock-active' : '') + (myTime < 30000 ? ' clock-low' : '');
    }
    if (tc) {
        tc.textContent = clkFmt(oppTime);
        tc.className = 'player-clock' + (oppTurn ? ' clock-active' : '') + (oppTime < 30000 ? ' clock-low' : '');
    }
}
setInterval(function() { if (gs && gs.board && !gs.gameOver) renderClocks(); }, 100);

function pollQueue() {
    fetch(CTX + '/onlineQueue', {method:'POST'})
        .then(function(r){ return r.json(); })
        .then(function(msg){
            if (msg.status === 'matched') {
                clearInterval(queueInterval);
                onMatched(msg);
            }
        })
        .catch(function(){});
}

function cancelSearch() {
    clearInterval(queueInterval);
    clearInterval(searchTimer);
    fetch(CTX + '/onlineCancel', {method:'POST'}).catch(function(){});
    location.href = CTX + '/home';
}

function onMatched(msg) {
    clearInterval(searchTimer);
    gameId = msg.gameId;
    myColor = msg.color;
    MY_ELO = msg.myElo;
    // Reset chess clock display
    clkWt = 600000; clkBt = 600000; clkTurn = 'w'; clkSyncAt = Date.now();

    document.getElementById('searchingScreen').style.display = 'none';
    document.getElementById('gameScreen').style.display = '';

    startOnlineGame(msg.color, msg.whiteArmy, msg.blackArmy,
                    MY_USERNAME, msg.myElo, msg.opponentUsername, msg.opponentElo);

    gameInterval = setInterval(pollGame, 800);
}

function pollGame() {
    if (!gameId || !myColor) return;
    fetch(CTX + '/onlinePoll?gameId=' + encodeURIComponent(gameId) + '&color=' + myColor)
        .then(function(r){ return r.json(); })
        .then(function(msg){
            syncTimer(msg);
            if (msg.type === 'move') {
                handleOpponentMove(msg.move);
            } else if (msg.type === 'gameover') {
                clearInterval(gameInterval);
                handleGameOver(msg);
            }
        })
        .catch(function(){});
}

function handleOpponentMove(move) {
    if (gs.gameOver) return;
    gs.viewIdx = -1; // snap back to live position when opponent moves
    execMove(move.from, move.to, move.promo || null, false, false);
}

function handleGameOver(msg) {
    var wasOver = gs.gameOver;
    gs.gameOver = true;
    if (!wasOver) playSound('game_end');
    if (!wasOver || !gs.result) {
        var map = {white:'White wins!', black:'Black wins!', draw:'Draw!'};
        gs.result = map[msg.result] || msg.result;
    }
    MY_ELO = msg.newElo;
    document.getElementById('navElo').textContent = msg.newElo;
    document.getElementById('bottomRating').textContent = msg.newElo + ' ELO';
    var sign = msg.eloChange >= 0 ? '+' : '';
    document.getElementById('eloChangeMsg').textContent =
        'ELO: ' + (msg.newElo - msg.eloChange) + ' → ' + msg.newElo +
        ' (' + sign + msg.eloChange + ')';
    render();
    renderOverlay();
}

(function() {

function copyBoard(b) { return b.map(function(r){return r.slice();}); }
function isW(p) { return p && p === p.toUpperCase(); }
function col(p) { return p ? (isW(p) ? 'w' : 'b') : null; }
function opp(c) { return c === 'w' ? 'b' : 'w'; }
function inB(r,c) { return r>=0&&r<8&&c>=0&&c<8; }
function tp(p) { return p ? p.toLowerCase() : null; }
function mkp(t,c) { return c==='w' ? t.toUpperCase() : t.toLowerCase(); }

function allyPrincessBoost(board, row, c2, c) {
    for(var r=0;r<8;r++) for(var c3=0;c3<8;c3++){
        var p=board[r][c3];
        if(!p||col(p)!==c||tp(p)!=='s') continue;
        var dr=Math.abs(r-row), dc=Math.abs(c3-c2);
        if((dr===1&&dc===1)||(dr===2&&dc===0)||(dr===0&&dc===2)) return 1;
    }
    return 0;
}

function pseudoMoves(board, row, c2) {
    var p=board[row][c2]; if(!p) return [];
    var c=col(p), t=tp(p), ms=[];
    var def=PIECE_DEFS_MAP[t];
    if(!def&&t!=='v') return ms;

    if(def.special){
        // Pawn: forward-only, diagonal capture only
        var d=c==='w'?-1:1, sr=c==='w'?6:1;
        if(inB(row+d,c2)&&!board[row+d][c2]){
            ms.push([row+d,c2]);
            if(row===sr&&!board[row+2*d][c2]) ms.push([row+2*d,c2]);
        }
        for(var dc of[-1,1]){
            if(inB(row+d,c2+dc)){var tgt=board[row+d][c2+dc]; if(tgt&&col(tgt)!==c) ms.push([row+d,c2+dc]);}
        }
        return ms;
    }

    // ── Custom pieces: unique movement not expressible by flags alone ──────────
    if(t==='l'){
        // Lancer: slide forward (move≤3, capture≤4), step back 1 (no capture)
        var fwd=c==='w'?-1:1;
        for(var i=1;i<=4;i++){
            var nr=row+fwd*i,nc=c2;
            if(!inB(nr,nc)) break;
            if(board[nr][nc]){if(col(board[nr][nc])!==c) ms.push([nr,nc]); break;}
            if(i<=3) ms.push([nr,nc]);
        }
        var br=row-fwd;
        if(inB(br,c2)&&!board[br][c2]) ms.push([br,c2]);
        return ms;
    }
    if(t==='e'){
        // Evil Pawn: move to empty forward-diagonals, capture straight forward
        var fwd=c==='w'?-1:1;
        for(var dc of[-1,1]){var nr=row+fwd,nc=c2+dc; if(inB(nr,nc)&&!board[nr][nc]) ms.push([nr,nc]);}
        var nr=row+fwd;
        if(inB(nr,c2)&&board[nr][c2]&&col(board[nr][c2])!==c) ms.push([nr,c2]);
        return ms;
    }
    if(t==='y'){
        // Prince: forward-left diagonal, forward-right diagonal, backward straight (unlimited)
        var fwd=c==='w'?-1:1;
        for(var dir of[[fwd,-1],[fwd,1],[-fwd,0]]){
            for(var i=1;i<8;i++){
                var nr=row+dir[0]*i,nc=c2+dir[1]*i;
                if(!inB(nr,nc)) break;
                if(board[nr][nc]){if(col(board[nr][nc])!==c) ms.push([nr,nc]); break;}
                ms.push([nr,nc]);
            }
        }
        return ms;
    }
    if(t==='d'){
        // Duke: Z-jump — 8 fixed destinations (2 rows ± 1 or 3 cols), can jump
        for(var o of[[-2,3],[-2,1],[-2,-1],[-2,-3],[2,3],[2,1],[2,-1],[2,-3]]){
            var nr=row+o[0],nc=c2+o[1];
            if(inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if(t==='z'){
        // Warden: 5x5 move range (all 8 dirs up to 2), capture only within 1 square
        for(var dir of[[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]){
            for(var i=1;i<=2;i++){
                var nr=row+dir[0]*i,nc=c2+dir[1]*i;
                if(!inB(nr,nc)) break;
                if(board[nr][nc]){if(col(board[nr][nc])!==c&&i===1) ms.push([nr,nc]); break;}
                ms.push([nr,nc]);
            }
        }
        return ms;
    }
    if(t==='h'){
        for(var o of[[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]){
            var nr=row+o[0],nc=c2+o[1];
            if(inB(nr,nc)&&board[nr][nc]&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if(t==='s'){
        for(var o of[[-1,-1],[-1,1],[1,-1],[1,1]]){var nr=row+o[0],nc=c2+o[1]; if(inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);}
        for(var o of[[-2,0],[2,0],[0,-2],[0,2]]){var nr=row+o[0],nc=c2+o[1]; if(inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);}
        return ms;
    }
    if(t==='f'){
        for(var o of[[-1,0],[1,0],[0,-1],[0,1]]){var nr=row+o[0],nc=c2+o[1]; if(inB(nr,nc)&&board[nr][nc]&&col(board[nr][nc])!==c) ms.push([nr,nc]);}
        for(var dir of[[-1,0],[1,0],[0,-1],[0,1]]){
            var er=row+dir[0],ec=c2+dir[1],lastEmpty=null;
            while(inB(er,ec)){if(!board[er][ec]) lastEmpty=[er,ec]; er+=dir[0]; ec+=dir[1];}
            if(lastEmpty) ms.push(lastEmpty);
        }
        return ms;
    }
    if(t==='a'){
        for(var o of[[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]){
            var nr=row+o[0],nc=c2+o[1];
            if(inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if(t==='o'){
        for(var r=0;r<8;r++) for(var c3=0;c3<8;c3++){if(r===row&&c3===c2) continue; if(!board[r][c3]) ms.push([r,c3]);}
        for(var o of[[-1,0],[1,0],[0,-1],[0,1]]){var nr=row+o[0],nc=c2+o[1]; if(inB(nr,nc)&&board[nr][nc]&&col(board[nr][nc])!==c) ms.push([nr,nc]);}
        return ms;
    }
    if(t==='i'){
        var fwd=c==='w'?-1:1;
        for(var dc2 of[-1,1]){
            for(var i=1;i<8;i++){
                var nc=c2+dc2*i; if(!inB(row,nc)) break;
                if(board[row][nc]){if(col(board[row][nc])!==c) ms.push([row,nc]);}
                else ms.push([row,nc]);
            }
        }
        if(inB(row+fwd,c2)&&!board[row+fwd][c2]) ms.push([row+fwd,c2]);
        for(var o of[[-fwd,-1],[-fwd,0],[-fwd*2,0],[-fwd,1]]){var nr=row+o[0],nc=c2+o[1]; if(inB(nr,nc)&&!board[nr][nc]) ms.push([nr,nc]);}
        return ms;
    }
    if(t==='g'){
        for(var o of[[-3,0],[3,0],[0,-3],[0,3]]){var nr=row+o[0],nc=c2+o[1]; if(inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);}
        return ms;
    }
    if(t==='v'){
        var fwd=c==='w'?-1:1, nr=row+fwd;
        if(inB(nr,c2)&&!board[nr][c2]) ms.push([nr,c2]);
        if(inB(nr,c2)&&board[nr][c2]&&col(board[nr][c2])!==c) ms.push([nr,c2]);
        return ms;
    }
    if(t==='c'){ // Feather: checkers-style diagonal
        for(var o of[[-1,-1],[-1,1],[1,-1],[1,1]]){
            var nr=row+o[0],nc=c2+o[1];
            if(inB(nr,nc)&&!board[nr][nc]) ms.push([nr,nc]);
            var jr=row+2*o[0],jc=c2+2*o[1];
            if(inB(nr,nc)&&inB(jr,jc)&&board[nr][nc]&&col(board[nr][nc])!==c&&!board[jr][jc]) ms.push([jr,jc]);
        }
        return ms;
    }
    if(t==='m'){ // Lantern: diagonal jumper range 2
        for(var o of[[-1,-1],[-1,1],[1,-1],[1,1]]){
            var nr1=row+o[0],nc1=c2+o[1];
            if(inB(nr1,nc1)&&col(board[nr1][nc1])!==c) ms.push([nr1,nc1]);
            var nr2=row+2*o[0],nc2=c2+2*o[1];
            if(inB(nr2,nc2)&&col(board[nr2][nc2])!==c) ms.push([nr2,nc2]);
        }
        return ms;
    }
    if(t==='t'){ // Wizard: same-color squares in 5x5, swap with enemy
        var myColor=(row+c2)%2;
        for(var dr=-2;dr<=2;dr++) for(var dc=-2;dc<=2;dc++){
            if(dr===0&&dc===0) continue;
            var nr=row+dr,nc=c2+dc;
            if(!inB(nr,nc)) continue;
            if((nr+nc)%2!==myColor) continue;
            if(!board[nr][nc]||col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if(t==='u'){ // Oracle: moves like king
        for(var o of[[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]){
            var nr=row+o[0],nc=c2+o[1];
            if(inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if(t==='w'){ // Eclipse: rook on dark, bishop on light
        var isDark=(row+c2)%2===1;
        if(isDark){
            for(var dir of[[-1,0],[1,0],[0,-1],[0,1]]){
                for(var i=1;i<8;i++){var nr=row+dir[0]*i,nc=c2+dir[1]*i; if(!inB(nr,nc)) break; if(board[nr][nc]){if(col(board[nr][nc])!==c) ms.push([nr,nc]); break;} ms.push([nr,nc]);}
            }
        } else {
            for(var dir of[[-1,-1],[-1,1],[1,-1],[1,1]]){
                for(var i=1;i<8;i++){var nr=row+dir[0]*i,nc=c2+dir[1]*i; if(!inB(nr,nc)) break; if(board[nr][nc]){if(col(board[nr][nc])!==c) ms.push([nr,nc]); break;} ms.push([nr,nc]);}
            }
        }
        return ms;
    }
    if(t==='fk'){ // Fork: T-pattern + king diagonals; paralyzed when attacked
        for(var o of[[-1,-1],[-1,1],[1,-1],[1,1]]){var nr=row+o[0],nc=c2+o[1]; if(inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);}
        for(var dir of[[-1,0],[1,0],[0,-1],[0,1]]){
            var perpDirs=dir[0]===0?[[-1,0],[1,0]]:[[0,-1],[0,1]];
            var ar1=row+dir[0],ac1=c2+dir[1];
            if(!inB(ar1,ac1)) continue;
            if(board[ar1][ac1]){if(col(board[ar1][ac1])!==c) ms.push([ar1,ac1]); continue;}
            ms.push([ar1,ac1]);
            var ar2=row+2*dir[0],ac2=c2+2*dir[1];
            if(!inB(ar2,ac2)) continue;
            if(board[ar2][ac2]){if(col(board[ar2][ac2])!==c) ms.push([ar2,ac2]);}
            else{
                ms.push([ar2,ac2]);
                for(var pd2 of perpDirs){
                    for(var i=1;i<=2;i++){var pr=ar2+pd2[0]*i,pc=ac2+pd2[1]*i; if(!inB(pr,pc)) break; if(board[pr][pc]){if(col(board[pr][pc])!==c) ms.push([pr,pc]); break;} ms.push([pr,pc]);}
                }
            }
        }
        return ms;
    }
    if(!def) return ms;
    // ── Generic flag-based movement (standard pieces + simple custom pieces) ──

    if(def.lshape){
        for(var o of[[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]){
            var nr=row+o[0],nc=c2+o[1];
            if(inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
    }

    var dirs=[];
    var fwd=c==='w'?-1:1;
    if(def.fwd)  dirs.push([fwd,0]);
    if(def.bwd)  dirs.push([-fwd,0]);
    if(def.side){ dirs.push([0,-1]); dirs.push([0,1]); }
    if(def.diag){ dirs.push([-1,-1]); dirs.push([-1,1]); dirs.push([1,-1]); dirs.push([1,1]); }
    var baseR=def.range===0?7:def.range;
    var maxR=def.range===0?7:baseR+allyPrincessBoost(board,row,c2,c);

    for(var dir of dirs){
        for(var i=1;i<=maxR;i++){
            var nr=row+dir[0]*i,nc=c2+dir[1]*i;
            if(!inB(nr,nc)) break;
            if(board[nr][nc]){
                if(col(board[nr][nc])!==c) ms.push([nr,nc]);
                if(!def.jump) break;
            } else {
                ms.push([nr,nc]);
            }
        }
    }
    return ms;
}

function isAttacked(board,row,c2,byColor){
    for(var r=0;r<8;r++) for(var c=0;c<8;c++){
        var p=board[r][c];
        if(p&&col(p)===byColor){
            if(pseudoMoves(board,r,c).some(function(m){return m[0]===row&&m[1]===c2;})) return true;
        }
    }
    return false;
}

function inCheck(board,c){
    for(var r=0;r<8;r++) for(var c2=0;c2<8;c2++){
        var p=board[r][c2];
        if(p&&col(p)===c&&(tp(p)==='k'||tp(p)==='u'||tp(p)==='hk'||tp(p)==='hy'||tp(p)==='lb'||tp(p)==='fk')&&isAttacked(board,r,c2,opp(c))) return true;
    }
    return false;
}

function applyMove(board,from,to,ep,castling,promo){
    var nb=copyBoard(board);
    var fr=from[0],fc=from[1],tr=to[0],tc=to[1];
    var p=nb[fr][fc], t=tp(p), c=col(p);
    var captured=nb[tr][tc];
    nb[tr][tc]=p; nb[fr][fc]=null;
    if(t==='p'&&ep&&tr===ep[0]&&tc===ep[1]) nb[fr][tc]=null;
    if(t==='k'){
        if(fc===4&&tc===6){nb[fr][7]=null; nb[fr][5]=mkp('r',c);}
        else if(fc===4&&tc===2){nb[fr][0]=null; nb[fr][3]=mkp('r',c);}
    }
    if(t==='p'&&(tr===0||tr===7)) nb[tr][tc]=mkp(promo||'q',c);
    if(captured&&tp(captured)==='h') nb[tr][tc]=null;
    if(t==='c'&&Math.abs(tr-fr)===2&&Math.abs(tc-fc)===2){var mr=(fr+tr)/2,mc=(fc+tc)/2; if(nb[mr][mc]&&col(nb[mr][mc])!==c) nb[mr][mc]=null;}
    if(t==='t'&&captured&&col(captured)!==c) nb[fr][fc]=captured;
    return nb;
}

function newCastling(castling,from,board){
    var c=Object.assign({},castling), r=from[0], fc=from[1], p=board[r][fc];
    if(!p) return c;
    var t=tp(p), cl=col(p);
    if(t==='k'){if(cl==='w'){c.wK=false;c.wQ=false;}else{c.bK=false;c.bQ=false;}}
    else if(t==='r'){
        if(cl==='w'){if(r===7&&fc===7)c.wK=false;if(r===7&&fc===0)c.wQ=false;}
        else{if(r===0&&fc===7)c.bK=false;if(r===0&&fc===0)c.bQ=false;}
    }
    return c;
}

function newEP(board,from,to){
    var fr=from[0],fc=from[1],tr=to[0],tc=to[1],p=board[fr][fc];
    if(!p||tp(p)!=='p') return null;
    if(Math.abs(tr-fr)===2) return [(fr+tr)/2,tc];
    return null;
}

function legalMoves(board,row,c2,castling,ep,turn){
    var p=board[row][c2]; if(!p||col(p)!==turn) return [];
    var c=col(p), t=tp(p), ms=[];
    if(t==='fk'&&isAttacked(board,row,c2,opp(c))) return [];
    pseudoMoves(board,row,c2).forEach(function(m){
        var nb=applyMove(board,[row,c2],m,ep,castling);
        if(!inCheck(nb,c)) ms.push(m);
    });
    if(t==='p'&&ep){
        var d=c==='w'?-1:1;
        if(row+d===ep[0]&&Math.abs(c2-ep[1])===1){
            var nb=applyMove(board,[row,c2],[ep[0],ep[1]],ep,castling);
            if(!inCheck(nb,c)) ms.push([ep[0],ep[1]]);
        }
    }
    if(t==='k'&&!inCheck(board,c)){
        var br=c==='w'?7:0;
        if(row===br&&c2===4){
            var canKS=c==='w'?castling.wK:castling.bK;
            if(canKS&&!board[br][5]&&!board[br][6]&&!isAttacked(board,br,5,opp(c))&&!isAttacked(board,br,6,opp(c))){
                var nb=applyMove(board,[row,c2],[br,6],ep,castling);
                if(!inCheck(nb,c)) ms.push([br,6]);
            }
            var canQS=c==='w'?castling.wQ:castling.bQ;
            if(canQS&&!board[br][3]&&!board[br][2]&&!board[br][1]&&!isAttacked(board,br,3,opp(c))&&!isAttacked(board,br,2,opp(c))){
                var nb=applyMove(board,[row,c2],[br,2],ep,castling);
                if(!inCheck(nb,c)) ms.push([br,2]);
            }
        }
    }
    return ms;
}

function allLegal(board,castling,ep,turn){
    var ms=[];
    for(var r=0;r<8;r++) for(var c2=0;c2<8;c2++){
        var p=board[r][c2];
        if(p&&col(p)===turn){
            if(gs&&gs.lanternImmobileFor===turn&&gs.lanternImmobile&&gs.lanternImmobile.some(function(x){return x[0]===r&&x[1]===c2;})) continue;
            legalMoves(board,r,c2,castling,ep,turn).forEach(function(m){ms.push({from:[r,c2],to:m});});
        }
    }
    return ms;
}

var FILES='abcdefgh';
var UNI=(function(){var m={};PIECE_REGISTRY.forEach(function(pd){var lo=pd.gameChar,hi=lo.toUpperCase();if(!m[lo])m[lo]=pd.blackUnicode;if(!m[hi])m[hi]=pd.whiteUnicode;});m['v']='♟';m['V']='♙';return m;})();

function toNotation(board,from,to,ep,promo){
    var fr=from[0],fc=from[1],tr=to[0],tc=to[1],p=board[fr][fc];
    if(!p) return '';
    var t=tp(p);
    if(t==='k'&&Math.abs(fc-tc)===2) return tc>fc?'O-O':'O-O-O';
    var capture=board[tr][tc]||(t==='p'&&ep&&tr===ep[0]&&tc===ep[1]);
    var n=t==='p'?'':t.toUpperCase();
    if(t==='p'&&capture) n=FILES[fc];
    if(capture) n+='x';
    n+=FILES[tc]+(8-tr);
    if(promo) n+='='+promo.toUpperCase();
    return n;
}

var ARMY_PIECE_MAP = (function(){
    var m={};
    PIECE_REGISTRY.forEach(function(pd){ m[pd.type]=pd.gameChar; });
    return m;
})();

var SPRITE_MAP = (function(){
    var m={};
    PIECE_REGISTRY.forEach(function(pd){ if(pd.sprite&&!m[pd.gameChar]) m[pd.gameChar]=pd.sprite; });
    return m;
})();

var PIECE_DEFS_MAP = (function(){
    var m={};
    PIECE_REGISTRY.forEach(function(pd){ if(!m[pd.gameChar]) m[pd.gameChar]=pd; });
    return m;
})();

function createOnlinePieceEl(p){
    return buildPieceSVG(tp(p), isW(p));
}

var STD_WHITE_ROWS = {7:['R','N','B','Q','K','B','N','R'],6:['P','P','P','P','P','P','P','P']};
var STD_BLACK_ROWS = {0:['r','n','b','q','k','b','n','r'],1:['p','p','p','p','p','p','p','p']};

function buildSide(army, isWhite){
    if(!army||!army.length) return null;
    var rows={}, hasKing=false;
    army.forEach(function(p){
        var ci=p.col.charCodeAt(0)-65, ri=8-p.rank;
        if(ri<0||ri>7||ci<0||ci>7) return;
        var t=ARMY_PIECE_MAP[p.pieceType]||'p';
        if(t==='k'||t==='u'||t==='hk'||t==='hy'||t==='lb') hasKing=true;
        if(!rows[ri]) rows[ri]=[null,null,null,null,null,null,null,null];
        rows[ri][ci]=isWhite?t.toUpperCase():t;
    });
    return hasKing?rows:null;
}

window.gs = {
    board:null, turn:'w',
    castling:{wK:true,wQ:true,bK:true,bQ:true},
    ep:null, selected:null, selMoves:[],
    history:[], gameOver:false, result:'',
    playerColor:'w', pendingPromo:null,
    lastFrom:null, lastTo:null
};

// ── Drag state ──────────────────────────────────────────────────────────────────
var ogPointerStart=null, ogIsDragging=false;
var OG_DRAG_THRESHOLD=5, OG_CELL_SIZE=70;
// ── Arrow / highlight state ─────────────────────────────────────────────────────
var ogArrows=[], ogHighlights=[], ogRightDragStart=null;

function applyOracleAutoStart() {
    for (var _or = 0; _or < 8; _or++) {
        for (var _oc = 0; _oc < 8; _oc++) {
            var _op = gs.board[_or][_oc];
            if (!_op || tp(_op) !== 'u') continue;
            var _oColor = col(_op);
            if (gs.oracleHasCursed[_oColor]) continue;
            var _candidates = [];
            for (var _tr = 2; _tr <= 5; _tr++) {
                for (var _tc = 0; _tc < 8; _tc++) {
                    if (!gs.board[_tr][_tc]) _candidates.push([_tr, _tc]);
                }
            }
            if (!_candidates.length) continue;
            var _pick = _candidates[Math.floor(Math.random() * _candidates.length)];
            gs.oracleCursedTile = _pick;
            gs.oracleHasCursed[_oColor] = true;
            (function(rr, cc) {
                setTimeout(function() {
                    var boardEl = document.getElementById('chessBoard'); if (!boardEl) return;
                    var cell = boardEl.querySelector('[data-row="'+rr+'"][data-col="'+cc+'"]'); if (!cell) return;
                    var flash = document.createElement('div'); flash.className = 'oracle-start-reveal';
                    cell.style.position = 'relative'; cell.appendChild(flash);
                    flash.addEventListener('animationend', function() { flash.remove(); }, {once:true});
                }, 700);
            })(_pick[0], _pick[1]);
        }
    }
}

window.startOnlineGame = function(color, whiteArmy, blackArmy, myName, myElo, oppName, oppElo) {
    var board=[];
    for(var i=0;i<8;i++) board.push([null,null,null,null,null,null,null,null]);
    var wRows=buildSide(whiteArmy,true)||STD_WHITE_ROWS;
    var bRows=buildSide(blackArmy,false)||STD_BLACK_ROWS;
    Object.keys(wRows).forEach(function(ri){board[parseInt(ri)]=wRows[ri].slice();});
    Object.keys(bRows).forEach(function(ri){board[parseInt(ri)]=bRows[ri].slice();});
    var castling={
        wK:board[7][4]==='K'&&board[7][7]==='R',
        wQ:board[7][4]==='K'&&board[7][0]==='R',
        bK:board[0][4]==='k'&&board[0][7]==='r',
        bQ:board[0][4]==='k'&&board[0][0]==='r'
    };
    gs={board:board,turn:'w',castling:castling,ep:null,selected:null,selMoves:[],
        history:[],gameOver:false,result:'',playerColor:color,
        pendingPromo:null,lastFrom:null,lastTo:null,
        bhCounts:{},beasts:[],beastExpiry:-1,
        lanternImmobile:[],lanternImmobileFor:null,
        oracleCursedTile:null,oracleHasCursed:{w:false,b:false},curseMode:false,
        viewIdx:-1};
    applyOracleAutoStart();
    updatePanels(color, myName, myElo, oppName, oppElo);
    render();
    playSound('game_start');
};

function updatePanels(color, myName, myElo, oppName, oppElo){
    document.getElementById('topAvatar').textContent    = color==='b'?'♔':'♚';
    document.getElementById('topName').textContent      = oppName + ' (' + oppElo + ')';
    document.getElementById('topRating').textContent    = oppElo + ' ELO';
    document.getElementById('bottomAvatar').textContent = color==='b'?'♚':'♔';
    document.getElementById('bottomName').textContent   = myName;
    document.getElementById('bottomRating').textContent = myElo + ' ELO';
}

function ogDoAnimateMove(from, to, piece, onDone) {
    if(!piece){ if(onDone) onDone(); return; }
    var container=document.querySelector('.board-container');
    if(!container){ if(onDone) onDone(); return; }
    var flip=gs.playerColor==='b';
    var fci=flip?7-from[1]:from[1], fri=flip?7-from[0]:from[0];
    var tci=flip?7-to[1]:to[1],   tri=flip?7-to[0]:to[0];
    var fx=2+fci*OG_CELL_SIZE, fy=2+fri*OG_CELL_SIZE;
    var dx=(tci-fci)*OG_CELL_SIZE, dy=(tri-fri)*OG_CELL_SIZE;
    var boardEl=document.getElementById('chessBoard');
    var destCell=boardEl&&boardEl.querySelector('[data-row="'+to[0]+'"][data-col="'+to[1]+'"]');
    var destEl=destCell&&destCell.querySelector('span.piece-white,span.piece-black,img.piece-sprite,svg.piece-svg');
    if(destEl) destEl.style.opacity='0';
    var el=document.createElement('div');
    el.className='anim-piece-overlay';
    el.style.cssText='position:absolute;left:'+fx+'px;top:'+fy+'px;width:'+OG_CELL_SIZE+'px;height:'+OG_CELL_SIZE+'px;display:flex;align-items:center;justify-content:center;pointer-events:none;z-index:30;';
    el.appendChild(createOnlinePieceEl(piece));
    container.appendChild(el);
    var done=false;
    function finish(){
        if(done) return; done=true;
        el.remove();
        if(destEl) destEl.style.opacity='';
        if(onDone) onDone();
    }
    el.addEventListener('transitionend',finish,{once:true});
    setTimeout(finish,300);
    requestAnimationFrame(function(){
        requestAnimationFrame(function(){
            el.style.transition='transform 0.15s ease';
            el.style.transform='translate('+dx+'px,'+dy+'px)';
        });
    });
}

window.execMove = function(from, to, promo, sendToServer, skipAnimation){
    if(sendToServer===undefined) sendToServer=true;
    var piece=gs.board[from[0]][from[1]];
    var capturedPiece=gs.board[to[0]][to[1]];
    ogClearAnnotations();
    var notation=toNotation(gs.board,from,to,gs.ep,promo);
    var nb=applyMove(gs.board,from,to,gs.ep,gs.castling,promo);
    var nc=newCastling(gs.castling,from,gs.board);
    var ne=newEP(gs.board,from,to);
    gs.history.push({board:gs.board,castling:gs.castling,ep:gs.ep,notation:notation,from:from.slice(),to:to.slice()});
    gs.board=nb; gs.castling=nc; gs.ep=ne;
    gs.lastFrom=from.slice(); gs.lastTo=to.slice();
    gs.curseMode=false;
    gs.turn=opp(gs.turn); gs.selected=null; gs.selMoves=[];
    if(gs.lanternImmobileFor===opp(gs.turn)){gs.lanternImmobile=[];gs.lanternImmobileFor=null;}

    // Beast Handler ability
    if(gs.bhCounts&&tp(piece)==='a'){
        var fromKey=from[0]+','+from[1],toKey=to[0]+','+to[1];
        var cnt=(gs.bhCounts[fromKey]||0)+1;
        delete gs.bhCounts[fromKey]; gs.bhCounts[toKey]=cnt;
        if(cnt%5===0){
            var beastChar=isW(piece)?'V':'v';
            for(var bo of[[-1,0],[1,0],[0,-1],[0,1]]){
                var br=to[0]+bo[0],bc=to[1]+bo[1];
                if(inB(br,bc)&&!gs.board[br][bc]){gs.board[br][bc]=beastChar; gs.beasts.push([br,bc]);}
            }
            gs.beastExpiry=gs.history.length+1;
        }
    }
    if(gs.beasts&&gs.beasts.length>0&&gs.beastExpiry>=0&&gs.history.length>=gs.beastExpiry){
        gs.beasts.forEach(function(bpos){if(gs.board[bpos[0]][bpos[1]]&&tp(gs.board[bpos[0]][bpos[1]])==='v') gs.board[bpos[0]][bpos[1]]=null;});
        gs.beasts=[]; gs.beastExpiry=-1;
    }
    if(tp(piece)==='m'&&capturedPiece&&col(capturedPiece)!==col(piece)){
        gs.lanternImmobile=[];
        for(var ldr of[[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]){
            var ir=to[0]+ldr[0],ic=to[1]+ldr[1]; if(inB(ir,ic)) gs.lanternImmobile.push([ir,ic]);
        }
        gs.lanternImmobileFor=gs.turn;
        ogShowLanternEffect(to[0],to[1]);
    }
    if(gs.oracleCursedTile){
        var cr=gs.oracleCursedTile[0],cc=gs.oracleCursedTile[1];
        if(to[0]===cr&&to[1]===cc&&gs.board[cr][cc]){
            gs.board[cr][cc]=null; gs.oracleCursedTile=null; ogShowOracleCurseEffect(cr,cc);
        }
    }

    var nextMs=allLegal(gs.board,gs.castling,gs.ep,gs.turn);
    var gameoverResult=null;
    if(!nextMs.length){
        gs.gameOver=true;
        var isCheck=inCheck(gs.board,gs.turn);
        if(isCheck){
            gs.result=opp(gs.turn)==='w'?'White wins by checkmate!':'Black wins by checkmate!';
            gameoverResult=opp(gs.turn)==='w'?'white':'black';
            triggerCheckmateEffect();
        } else {
            gs.result='Draw by stalemate!';
            gameoverResult='draw';
        }
    }

    if(gs.gameOver) playSound('game_end');
    else if(inCheck(gs.board,gs.turn)) playSound('check');
    else if(notation.includes('x')) playSound('take');
    else playSound('move');

    // Optimistically advance local clock turn
    clkTurn = gs.turn; // gs.turn was already flipped by execMove above
    clkSyncAt = Date.now();

    if(sendToServer){
        var body=new URLSearchParams();
        body.append('gameId', gameId);
        body.append('from', JSON.stringify(from));
        body.append('to', JSON.stringify(to));
        if(promo) body.append('promo', promo);
        if(gameoverResult) body.append('gameoverResult', gameoverResult);
        fetch(CTX+'/onlineMove', {method:'POST', body:body})
            .then(function(r){return r.json();})
            .then(function(msg){
                syncTimer(msg);
                if(msg.gameover && msg.newElo !== undefined){
                    clearInterval(gameInterval);
                    MY_ELO=msg.newElo;
                    document.getElementById('navElo').textContent=msg.newElo;
                    document.getElementById('bottomRating').textContent=msg.newElo+' ELO';
                    var sign=msg.eloChange>=0?'+':'';
                    document.getElementById('eloChangeMsg').textContent=
                        'ELO: '+(msg.newElo-msg.eloChange)+' → '+msg.newElo+
                        ' ('+sign+msg.eloChange+')';
                    if (msg.eloChange > 0) awardKP('online_win');
                    renderOverlay();
                }
            })
            .catch(function(){});
    }

    render();
    if(!skipAnimation) ogDoAnimateMove(from,to,piece,null);
};

function ogShowLanternEffect(row, c){
    var boardEl=document.getElementById('chessBoard'); if(!boardEl) return;
    var cell=boardEl.querySelector('[data-row="'+row+'"][data-col="'+c+'"]'); if(!cell) return;
    var flash=document.createElement('div'); flash.className='lantern-flash-effect';
    cell.style.position='relative'; cell.appendChild(flash);
    flash.addEventListener('animationend',function(){flash.remove();},{once:true});
}
function ogShowOracleCurseEffect(row, c){
    var boardEl=document.getElementById('chessBoard'); if(!boardEl) return;
    var cell=boardEl.querySelector('[data-row="'+row+'"][data-col="'+c+'"]'); if(!cell) return;
    var flash=document.createElement('div'); flash.className='oracle-curse-trigger-effect';
    cell.style.position='relative'; cell.appendChild(flash);
    flash.addEventListener('animationend',function(){flash.remove();},{once:true});
}
function awardKP(reason) {
    var fd = new FormData();
    fd.append('reason', reason);
    fetch(CTX + '/awardKP', {method:'POST', body:fd}).catch(function(){});
}

function triggerCheckmateEffect(){
    var boardEl=document.getElementById('chessBoard'); if(!boardEl) return;
    boardEl.classList.add('board-shake');
    boardEl.addEventListener('animationend',function(){boardEl.classList.remove('board-shake');},{once:true});
    setTimeout(function(){
        var king=boardEl.querySelector('.in-check'); if(!king) return;
        king.classList.add('king-defeated');
    },40);
}
window.render = function(){ renderBoard(); renderMoveList(); renderStatus(); renderOverlay(); };

window.renderBoard = function(){
    var el=document.getElementById('chessBoard');
    el.innerHTML='';
    var flip=gs.playerColor==='b';
    // In view mode, show historical position; interaction is disabled
    var viewing=(gs.viewIdx!==undefined&&gs.viewIdx>=0&&gs.viewIdx<gs.history.length);
    var dispBoard=viewing?gs.history[gs.viewIdx].board:gs.board;
    var dispLastFrom=viewing?gs.history[gs.viewIdx].from:gs.lastFrom;
    var dispLastTo=viewing?gs.history[gs.viewIdx].to:gs.lastTo;
    var ogDragMoves=(!viewing&&ogIsDragging&&ogPointerStart&&gs.board&&gs.turn===gs.playerColor)
        ?legalMoves(gs.board,ogPointerStart.row,ogPointerStart.col,gs.castling,gs.ep,gs.turn):[];
    for(var ri=0;ri<8;ri++) for(var ci=0;ci<8;ci++){
        var row=flip?7-ri:ri, c=flip?7-ci:ci;
        var cell=document.createElement('div');
        var light=(row+c)%2===0;
        cell.className='cell '+(light?'light':'dark');
        cell.dataset.row=row; cell.dataset.col=c;
        if(dispLastFrom&&dispLastTo&&((row===dispLastFrom[0]&&c===dispLastFrom[1])||(row===dispLastTo[0]&&c===dispLastTo[1])))
            cell.classList.add('last-move');
        if(!viewing){
            if(gs.selected&&gs.selected[0]===row&&gs.selected[1]===c) cell.classList.add('selected');
            if(ogIsDragging&&ogPointerStart&&row===ogPointerStart.row&&c===ogPointerStart.col) cell.classList.add('dragging-from');
            var isDragLegal=ogIsDragging&&ogPointerStart&&ogDragMoves.some(function(m){return m[0]===row&&m[1]===c;});
            var isLegal=gs.selMoves.some(function(m){return m[0]===row&&m[1]===c;})||isDragLegal;
            if(gs.curseMode&&!gs.board[row][c]) cell.classList.add('curse-valid');
            if(isLegal) cell.classList.add(gs.board[row][c]?'legal-capture':'legal-move');
            if(gs.lanternImmobileFor===gs.turn&&gs.lanternImmobile&&gs.lanternImmobile.some(function(x){return x[0]===row&&x[1]===c;})&&gs.board[row][c]) cell.classList.add('lantern-immobilized');
            if(gs.oracleCursedTile&&gs.oracleCursedTile[0]===row&&gs.oracleCursedTile[1]===c){
                cell.classList.add('oracle-cursed');
                var skull=document.createElement('span'); skull.className='curse-marker'; skull.textContent='☠'; cell.appendChild(skull);
            }
        }
        var p=dispBoard[row][c];
        if(p&&(tp(p)==='k'||tp(p)==='u')&&inCheck(dispBoard,col(p))) cell.classList.add('in-check');
        if(p){ cell.appendChild(createOnlinePieceEl(p)); }
        if((!flip&&ci===0)||(flip&&ci===7)){
            var lbl=document.createElement('span');
            lbl.className='coord-rank'; lbl.textContent=8-row; cell.appendChild(lbl);
        }
        if((!flip&&ri===7)||(flip&&ri===0)){
            var lbl=document.createElement('span');
            lbl.className='coord-file'; lbl.textContent=FILES[c]; cell.appendChild(lbl);
        }
        el.appendChild(cell);
    }
    // Visual indicator when viewing history
    var boardContainer=document.querySelector('.board-container');
    if(boardContainer){
        if(viewing) boardContainer.classList.add('viewing-history');
        else boardContainer.classList.remove('viewing-history');
    }
};

window.renderMoveList = function(){
    var tbl=document.getElementById('moveList'); tbl.innerHTML='';
    for(var i=0;i<gs.history.length;i+=2){
        var tr=document.createElement('tr');
        var nd=document.createElement('td'); nd.className='move-num'; nd.textContent=(i/2+1)+'.'; tr.appendChild(nd);
        var wd=document.createElement('td'); wd.className='move-item'; wd.textContent=gs.history[i].notation; tr.appendChild(wd);
        var bd=document.createElement('td'); bd.className='move-item';
        if(gs.history[i+1]) bd.textContent=gs.history[i+1].notation;
        tr.appendChild(bd); tbl.appendChild(tr);
    }
    var h=document.getElementById('moveHistory'); h.scrollTop=h.scrollHeight;
};

window.renderStatus = function(){
    var el=document.getElementById('statusBox');
    if(gs.gameOver){el.innerHTML='<strong>'+gs.result+'</strong>'; return;}
    if(!gs.board){el.textContent='Waiting…'; return;}
    var chk=inCheck(gs.board,gs.turn);
    var who=gs.turn==='w'?'White':'Black';
    var myTurn=gs.turn===gs.playerColor;
    el.innerHTML=chk
        ?'<strong style="color:#e86161">'+who+' is in check!</strong>'
        :'<strong>'+who+'</strong> to move'+(myTurn?' — <em>your turn</em>':'');
};

window.renderOverlay = function(){
    var ov=document.getElementById('gameOverlay');
    if(gs.gameOver){
        document.getElementById('gameOverMsg').textContent=gs.result;
        ov.style.display='flex';
    } else ov.style.display='none';
};

// ── Arrow rendering ─────────────────────────────────────────────────────────────
function ogSqCenter(row,c){
    var flip=gs.playerColor==='b';
    var ci=flip?7-c:c, ri=flip?7-row:row;
    return {x:ci*OG_CELL_SIZE+OG_CELL_SIZE/2, y:ri*OG_CELL_SIZE+OG_CELL_SIZE/2};
}
function ogRenderArrows(){
    var svg=document.getElementById('arrowSVG'); if(!svg) return;
    svg.innerHTML='';
    if(!ogArrows.length&&!ogHighlights.length) return;
    var NS='http://www.w3.org/2000/svg';
    var SHAFT_W=9, HEAD_W=24, HEAD_LEN=22;
    ogHighlights.forEach(function(sq){
        var pos=ogSqCenter(sq[0],sq[1]);
        var isLight=(sq[0]+sq[1])%2===0;
        var color=isLight?'rgba(235,97,80,0.72)':'rgba(176,41,22,0.82)';
        var rect=document.createElementNS(NS,'rect');
        rect.setAttribute('x',pos.x-OG_CELL_SIZE/2); rect.setAttribute('y',pos.y-OG_CELL_SIZE/2);
        rect.setAttribute('width',OG_CELL_SIZE); rect.setAttribute('height',OG_CELL_SIZE);
        rect.setAttribute('fill',color);
        svg.appendChild(rect);
    });
    ogArrows.forEach(function(arr){
        var a=ogSqCenter(arr.from[0],arr.from[1]), b=ogSqCenter(arr.to[0],arr.to[1]);
        var dx=b.x-a.x,dy=b.y-a.y,len=Math.sqrt(dx*dx+dy*dy); if(len<2) return;
        var ux=dx/len,uy=dy/len,nx=-uy,ny=ux;
        var sx=a.x+ux*22,sy=a.y+uy*22;
        var tx=b.x-ux*10,ty=b.y-uy*10;
        var hbx=tx-ux*HEAD_LEN,hby=ty-uy*HEAD_LEN;
        var pts=[
            [sx+nx*SHAFT_W/2, sy+ny*SHAFT_W/2],
            [hbx+nx*SHAFT_W/2, hby+ny*SHAFT_W/2],
            [hbx+nx*HEAD_W/2, hby+ny*HEAD_W/2],
            [tx,ty],
            [hbx-nx*HEAD_W/2, hby-ny*HEAD_W/2],
            [hbx-nx*SHAFT_W/2, hby-ny*SHAFT_W/2],
            [sx-nx*SHAFT_W/2, sy-ny*SHAFT_W/2],
        ].map(function(p){return p[0].toFixed(1)+','+p[1].toFixed(1);}).join(' ');
        var poly=document.createElementNS(NS,'polygon');
        poly.setAttribute('points',pts);
        poly.setAttribute('fill','rgba(255,170,0,0.85)');
        svg.appendChild(poly);
    });
}
function ogClearAnnotations(){
    ogArrows=[]; ogHighlights=[];
    var svg=document.getElementById('arrowSVG'); if(svg) svg.innerHTML='';
}

// ── Click-based cell interaction ────────────────────────────────────────────────
function onCell2(row,c){
    if(gs.gameOver||!gs.board||gs.turn!==gs.playerColor) return;
    var p=gs.board[row][c];
    if(gs.selected){
        var legal=gs.selMoves.some(function(m){return m[0]===row&&m[1]===c;});
        if(legal){
            var mp=gs.board[gs.selected[0]][gs.selected[1]];
            if(tp(mp)==='p'&&(row===0||row===7)){gs.pendingPromo={from:gs.selected.slice(),to:[row,c]};showPromo();return;}
            execMove(gs.selected,[row,c],null);
        } else if(p&&col(p)===gs.playerColor){
            gs.selected=[row,c]; gs.selMoves=legalMoves(gs.board,row,c,gs.castling,gs.ep,gs.turn); renderBoard();
        } else {gs.selected=null;gs.selMoves=[];renderBoard();}
    } else if(p&&col(p)===gs.playerColor){
        gs.selected=[row,c]; gs.selMoves=legalMoves(gs.board,row,c,gs.castling,gs.ep,gs.turn); renderBoard();
    }
}

// ── Drag drop ──────────────────────────────────────────────────────────────────
function onCellDrop(fromRow,fromCol,toRow,toCol){
    if(gs.gameOver||!gs.board||gs.turn!==gs.playerColor) return;
    var mp=gs.board[fromRow][fromCol];
    if(!mp||col(mp)!==gs.playerColor) return;
    var legal=legalMoves(gs.board,fromRow,fromCol,gs.castling,gs.ep,gs.turn);
    if(legal.some(function(m){return m[0]===toRow&&m[1]===toCol;})){
        gs.selected=null; gs.selMoves=[];
        if(tp(mp)==='p'&&(toRow===0||toRow===7)){
            gs.pendingPromo={from:[fromRow,fromCol],to:[toRow,toCol]};showPromo();
        } else {execMove([fromRow,fromCol],[toRow,toCol],null,true,true);}
    } else {gs.selected=null;gs.selMoves=[];renderBoard();}
}

function showPromo(){
    var c=gs.playerColor;
    var modal=document.getElementById('promotionModal');
    var opts=document.getElementById('promoOptions'); opts.innerHTML='';
    ['q','r','b','n'].forEach(function(t){
        var btn=document.createElement('button');
        btn.className='promo-btn'; btn.appendChild(buildPieceSVG(t, c==='w'));
        btn.onclick=function(){ modal.style.display='none'; execMove(gs.pendingPromo.from,gs.pendingPromo.to,t); gs.pendingPromo=null; };
        opts.appendChild(btn);
    });
    modal.style.display='flex';
}

// Warn before leaving during an active online game; cancel search on page leave
window.addEventListener('beforeunload', function(e) {
    if (gameId && !gs.gameOver) {
        e.preventDefault();
        e.returnValue = '';
    } else if (!gameId) {
        // Silently cancel the queue when navigating away during search
        navigator.sendBeacon(CTX + '/onlineCancel', '');
    }
});

// Inactivity resign: auto-resign after 1 minute of not viewing the board
document.addEventListener('visibilitychange', function() {
    if (!gameId || !gs || gs.gameOver) return;
    if (document.hidden) {
        inactivityTimer = setTimeout(function() {
            if (!gameId || !gs || gs.gameOver) return;
            clearInterval(gameInterval);
            var result = myColor === 'w' ? 'black' : 'white';
            gs.gameOver = true;
            gs.result = 'You were disconnected (inactive).';
            playSound('game_end');
            render();
            renderOverlay();
            var body = new URLSearchParams();
            body.append('gameId', gameId);
            body.append('result', result);
            fetch(CTX + '/onlineFinish', {method:'POST', body:body}).catch(function(){});
        }, 60000);
    } else {
        if (inactivityTimer) { clearTimeout(inactivityTimer); inactivityTimer = null; }
    }
});

document.addEventListener('DOMContentLoaded', function(){
    document.getElementById('chessBoard').addEventListener('contextmenu',function(e){e.preventDefault();});

    // Intercept sidebar/nav link clicks — confirm resign before navigating away
    document.querySelectorAll('.sidebar a, .nav-item').forEach(function(link) {
        link.addEventListener('click', function(e) {
            if (!gameId || gs.gameOver) return;
            if (!confirm('Leaving this page will resign your online game. Are you sure?')) {
                e.preventDefault();
                return;
            }
            clearInterval(gameInterval);
            var result = myColor === 'w' ? 'black' : 'white';
            gs.gameOver = true;
            var body = new URLSearchParams();
            body.append('gameId', gameId);
            body.append('result', result);
            fetch(CTX + '/onlineFinish', {method:'POST', body:body}).catch(function(){});
        });
    });

    // ── Drag & drop + arrow global handlers ──────────────────────────────────────
    document.addEventListener('mousedown',function(e){
        if(e.button===2){
            var cell=e.target.closest&&e.target.closest('#chessBoard .cell');
            if(cell) ogRightDragStart=[parseInt(cell.dataset.row),parseInt(cell.dataset.col)];
            return;
        }
        if(e.button!==0) return;
        var cell=e.target.closest&&e.target.closest('#chessBoard .cell');
        if(!cell) return;
        ogClearAnnotations();
        if(!gs.board) return;
        var row=parseInt(cell.dataset.row),c=parseInt(cell.dataset.col);
        var p=gs.board[row][c];
        if(!p||col(p)!==gs.playerColor||gs.gameOver||gs.turn!==gs.playerColor) return;
        ogPointerStart={row:row,col:c,x:e.clientX,y:e.clientY,hasDragged:false,ghost:null};
    });

    document.addEventListener('mousemove',function(e){
        if(!ogPointerStart) return;
        var dx=e.clientX-ogPointerStart.x,dy=e.clientY-ogPointerStart.y;
        if(!ogPointerStart.hasDragged&&Math.sqrt(dx*dx+dy*dy)>OG_DRAG_THRESHOLD){
            ogPointerStart.hasDragged=true; ogIsDragging=true;
            var ghost=document.createElement('div');
            ghost.className='drag-ghost';
            var _gp=gs.board[ogPointerStart.row][ogPointerStart.col];
            ghost.appendChild(buildPieceSVG(tp(_gp),isW(_gp)));
            document.body.appendChild(ghost); ogPointerStart.ghost=ghost;
            renderBoard();
        }
        if(ogPointerStart.hasDragged&&ogPointerStart.ghost){
            ogPointerStart.ghost.style.left=e.clientX+'px';
            ogPointerStart.ghost.style.top=e.clientY+'px';
        }
    });

    document.addEventListener('mouseup',function(e){
        if(e.button===2){
            if(ogRightDragStart){
                var el=document.elementFromPoint(e.clientX,e.clientY);
                var cell=el&&el.closest&&el.closest('#chessBoard .cell');
                if(cell){
                    var r=parseInt(cell.dataset.row),c2=parseInt(cell.dataset.col);
                    var sr=ogRightDragStart[0],sc=ogRightDragStart[1];
                    if(r===sr&&c2===sc){
                        var idx=ogHighlights.findIndex(function(h){return h[0]===r&&h[1]===c2;});
                        if(idx>=0) ogHighlights.splice(idx,1); else ogHighlights.push([r,c2]);
                    } else {
                        var idx=ogArrows.findIndex(function(a){return a.from[0]===sr&&a.from[1]===sc&&a.to[0]===r&&a.to[1]===c2;});
                        if(idx>=0) ogArrows.splice(idx,1); else ogArrows.push({from:[sr,sc],to:[r,c2]});
                    }
                    ogRenderArrows();
                }
            }
            ogRightDragStart=null; return;
        }
        if(e.button!==0) return;
        if(!ogPointerStart){
            var el2=document.elementFromPoint(e.clientX,e.clientY);
            var cell2=el2&&el2.closest&&el2.closest('#chessBoard .cell');
            if(cell2&&gs.selected) onCell2(parseInt(cell2.dataset.row),parseInt(cell2.dataset.col));
            return;
        }
        if(ogPointerStart.ghost){ogPointerStart.ghost.remove();ogPointerStart.ghost=null;}
        ogIsDragging=false;
        if(ogPointerStart.hasDragged){
            var el=document.elementFromPoint(e.clientX,e.clientY);
            var cell=el&&el.closest&&el.closest('#chessBoard .cell');
            if(cell){onCellDrop(ogPointerStart.row,ogPointerStart.col,parseInt(cell.dataset.row),parseInt(cell.dataset.col));}
            else{gs.selected=null;gs.selMoves=[];renderBoard();}
        } else {onCell2(ogPointerStart.row,ogPointerStart.col);}
        ogPointerStart=null;
    });

    document.getElementById('resignBtn').addEventListener('click', function(){
        if(!gs.board||gs.gameOver||!gameId) return;
        if(!confirm('Resign this game?')) return;
        clearInterval(gameInterval);
        var result=myColor==='w'?'black':'white';
        gs.gameOver=true;
        gs.result='You resigned.';
        playSound('game_end');
        var body=new URLSearchParams();
        body.append('gameId', gameId);
        body.append('result', result);
        fetch(CTX+'/onlineFinish', {method:'POST', body:body})
            .then(function(r){return r.json();})
            .then(function(msg){
                if(msg.newElo !== undefined){
                    MY_ELO=msg.newElo;
                    document.getElementById('navElo').textContent=msg.newElo;
                    document.getElementById('bottomRating').textContent=msg.newElo+' ELO';
                    var sign=msg.eloChange>=0?'+':'';
                    document.getElementById('eloChangeMsg').textContent=
                        'ELO: '+(msg.newElo-msg.eloChange)+' → '+msg.newElo+
                        ' ('+sign+msg.eloChange+')';
                }
                render();
                renderOverlay();
            })
            .catch(function(){ render(); renderOverlay(); });
    });

    // ── Move history navigation (visual-only for online games) ───────────────
    document.getElementById('btnFirst').addEventListener('click', function(){
        if(!gs.board||!gs.history.length) return;
        gs.viewIdx=0; renderBoard();
    });
    document.getElementById('btnPrev').addEventListener('click', function(){
        if(!gs.board||!gs.history.length) return;
        var cur=(gs.viewIdx<0)?gs.history.length:gs.viewIdx;
        gs.viewIdx=Math.max(0,cur-1); renderBoard();
    });
    document.getElementById('btnNext').addEventListener('click', function(){
        if(!gs.board) return;
        if(gs.viewIdx<0) return; // already at live
        gs.viewIdx=gs.viewIdx+1;
        if(gs.viewIdx>=gs.history.length){ gs.viewIdx=-1; } // snap back to live
        renderBoard();
    });
    document.getElementById('btnLast').addEventListener('click', function(){
        if(!gs.board) return;
        gs.viewIdx=-1; renderBoard(); // snap to live position
    });
});

})();
</script>
</main>
</div>
</body>
</html>
