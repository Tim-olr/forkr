<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.game.pieces.PieceDefinition, timolr.chess.game.pieces.PieceRegistry, java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Play - Gambitonline</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Newsreader:ital,opsz,wght@0,6..72,300..700;1,6..72,300..700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/forkr.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
    <style>body{background:var(--bg)!important;overflow:hidden}</style>
    <script src="${pageContext.request.contextPath}/js/piece-art.js"></script>
    <style>
    .bot-bubble {
        background: var(--surface-alt);
        border: 1px solid var(--border);
        border-radius: 10px 10px 10px 2px;
        padding: 8px 12px;
        font-size: 13px;
        font-style: italic;
        color: var(--text);
        margin-top: 6px;
        max-width: 220px;
        line-height: 1.4;
        opacity: 0;
        transition: opacity .3s;
    }
    .bot-bubble.visible { opacity: 1; }
    .bot-avatar-img {
        width: 100%; height: 100%;
        object-fit: cover; border-radius: 50%;
    }
    .bot-card {
        display: flex; align-items: center; gap: 12px;
        padding: 10px 12px; border-radius: 6px;
        border: 1px solid var(--border); cursor: pointer;
        transition: background .15s;
    }
    .bot-card:hover { background: var(--surface-alt); }
    .bot-card-avatar {
        width: 44px; height: 44px; border-radius: 50%;
        overflow: hidden; flex-shrink: 0;
        background: var(--surface-alt);
        display: flex; align-items: center; justify-content: center;
        border: 2px solid var(--border); font-size: 20px;
    }
    .bot-collection-header {
        padding: 11px 14px; cursor: pointer;
        font-weight: 600; font-size: 14px;
        list-style: none; display: flex;
        justify-content: space-between; align-items: center;
        background: var(--surface-alt);
        user-select: none;
    }
    .bot-collection-header::-webkit-details-marker { display: none; }
    details.bot-collection {
        border: 1px solid var(--border);
        border-radius: 8px; overflow: hidden;
        margin-bottom: 10px;
    }
    details.bot-collection .bot-collection-body {
        padding: 10px; display: flex; flex-direction: column; gap: 7px;
    }
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
    #cursePanel { margin-top: 8px; }
    .curse-btn { font-size: 12px; padding: 4px 10px; }
    </style>
</head>
<body>
<div class="app-shell">
<% pageContext.setAttribute("activeNav", "bots"); %>
<%@ include file="_sidebar.jsp" %>
<main class="page" style="overflow:auto;min-height:0">
<div class="game-container">
    <div class="game-panel-left">
        <div class="player-info" id="topPlayerInfo" style="position:relative">
            <div class="player-avatar" id="topAvatar" style="overflow:hidden;border-radius:50%">&#9812;</div>
            <div>
                <div class="player-name" id="topName">Opponent</div>
                <div class="player-rating" id="topRating">—</div>
            </div>
        </div>
        <div class="bot-bubble" id="botBubble"></div>
        <div class="game-status" id="statusBox">Pick a bot to start.</div>
        <div id="cursePanel" style="display:none">
            <button id="curseBtn" class="btn btn-danger curse-btn" onclick="toggleCurseMode()">Curse a Tile</button>
        </div>
        <div class="game-actions">
            <button class="btn btn-outline" id="newGameBtn" style="flex:1">New Game</button>
            <button class="btn btn-outline" id="resignBtn" style="flex:1">Resign</button>
        </div>
    </div>

    <div class="board-container">
        <div class="board" id="chessBoard"></div>
        <svg id="arrowSVG" class="arrow-svg" viewBox="0 0 840 840" xmlns="http://www.w3.org/2000/svg"></svg>
        <div class="game-over-overlay" id="gameOverlay">
            <div class="game-over-msg" id="gameOverMsg"></div>
            <button class="btn btn-green btn-lg" id="newGameBtnOverlay">New Game</button>
        </div>
    </div>

    <div class="game-panel-right">
        <div class="player-info" id="bottomPlayerInfo">
            <div class="player-avatar" id="bottomAvatar">&#9818;</div>
            <div>
                <div class="player-name" id="bottomName"><s:property value="loggedInUsername" /></div>
                <div class="player-rating" id="bottomRating">Human</div>
            </div>
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

<!-- ── Bot Picker Modal ────────────────────────────────────────────────────── -->
<div class="modal-overlay" id="botPickerModal" style="display:none">
    <div class="modal-box" style="max-width:520px;max-height:82vh;overflow-y:auto;padding:0">
        <!-- Step 1: collection list -->
        <div id="pickerStep1">
            <div style="display:flex;justify-content:space-between;align-items:center;padding:18px 22px 12px;position:sticky;top:0;background:var(--surface);z-index:1;border-bottom:1px solid var(--border)">
                <div class="modal-title" style="margin-bottom:0">Play vs Bots</div>
                <button class="modal-close-btn" onclick="closeBotPickerModal()">&times;</button>
            </div>
            <div id="botCollectionList" style="padding:14px 20px 20px"></div>
        </div>
        <!-- Step 2: color picker for selected bot -->
        <div id="pickerStep2" style="display:none">
            <div style="display:flex;justify-content:space-between;align-items:center;padding:18px 22px 12px;position:sticky;top:0;background:var(--surface);z-index:1;border-bottom:1px solid var(--border)">
                <button class="modal-close-btn" onclick="goPickerStep1()" style="font-size:20px;width:32px;height:32px">&#8592;</button>
                <div class="modal-title" style="margin-bottom:0" id="pickerStep2Title">Pick Color</div>
                <button class="modal-close-btn" onclick="closeBotPickerModal()">&times;</button>
            </div>
            <div style="padding:20px 24px 24px">
                <div style="display:flex;align-items:center;gap:14px;margin-bottom:20px">
                    <div class="bot-card-avatar" id="step2Avatar" style="width:56px;height:56px;font-size:26px">&#9816;</div>
                    <div>
                        <div style="font-weight:700;font-size:16px" id="step2Name"></div>
                        <div style="color:var(--text-muted);font-size:13px" id="step2Elo"></div>
                    </div>
                </div>
                <div class="modal-section-label">Play as</div>
                <div class="color-picker">
                    <div class="color-option">
                        <input type="radio" name="pickerColor" id="pickerWhite" value="w" checked>
                        <label for="pickerWhite"><span class="piece-icon">&#9812;</span>White</label>
                    </div>
                    <div class="color-option">
                        <input type="radio" name="pickerColor" id="pickerRandom" value="r">
                        <label for="pickerRandom"><span class="piece-icon">&#9864;</span>Random</label>
                    </div>
                    <div class="color-option">
                        <input type="radio" name="pickerColor" id="pickerBlack" value="b">
                        <label for="pickerBlack"><span class="piece-icon">&#9818;</span>Black</label>
                    </div>
                </div>
                <button class="btn btn-green btn-full btn-lg" id="startBotGameBtn" style="margin-top:18px">Start Game</button>
            </div>
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
var CTX = "${pageContext.request.contextPath}";
var LOCAL_PLAY = ${localPlay};
var PLAYER_WHITE_ARMY = ${playerWhiteArmyJson};
var PLAYER_BLACK_ARMY = ${playerBlackArmyJson};
var PRESET_WHITE_ARMY = ${presetWhiteArmyJson};
var PRESET_BLACK_ARMY = ${presetBlackArmyJson};
var BOT_DATA = ${botDataJson};
var ALL_BOTS = ${allBotsJson};
var CURRENT_USER = '<s:property value="loggedInUsername" />';

<%-- Piece registry from PieceRegistry.java --%>
<% List<PieceDefinition> gamePieceDefs = PieceRegistry.getAll(); %>
var PIECE_REGISTRY = [
<% for (PieceDefinition pd : gamePieceDefs) { %>
    { type: "<%= pd.getType() %>", sprite: <%= pd.getSprite() != null ? "\"" + pd.getSprite() + "\"" : "null" %>, gameChar: "<%= pd.getGameChar() %>", whiteUnicode: "<%= pd.getWhiteUnicode() %>", blackUnicode: "<%= pd.getBlackUnicode() %>", special: <%= pd.isSpecial() %>, fwd: <%= pd.isCanMoveForwards() %>, bwd: <%= pd.isCanMoveBackwards() %>, side: <%= pd.isCanMoveSideways() %>, diag: <%= pd.isCanMoveDiagonally() %>, jump: <%= pd.isCanJump() %>, lshape: <%= pd.isCanMoveInLShape() %>, range: <%= pd.getRange() %> },
<% } %>
];

(function () {

const _SFX_CTX=new(window.AudioContext||window.webkitAudioContext)();
const _SFX_BUFS={};
(function(){const base='${pageContext.request.contextPath}/sounds/';['move','take','check','game_end','game_start'].forEach(n=>{fetch(base+n+'.mp3').then(r=>r.arrayBuffer()).then(b=>_SFX_CTX.decodeAudioData(b)).then(d=>{_SFX_BUFS[n]=d;}).catch(()=>{});});})();
function playSound(name){const b=_SFX_BUFS[name];if(!b)return;if(_SFX_CTX.state==='suspended')_SFX_CTX.resume();const s=_SFX_CTX.createBufferSource();s.buffer=b;s.connect(_SFX_CTX.destination);s.start(0);}

const PIECE_VALUES = { p:100, n:320, b:330, r:500, j:500, q:900, k:20000,
                       l:430, e:120, y:360, d:600, z:350,
                       h:250, s:700, f:350, a:420, o:600, i:380, g:280, v:60,
                       m:320, w:400, c:550, t:450, u:20000,
                       ch:350, hk:300, hy:800, lb:450, fk:20000,
                       sq:130, lp:125, rt:105, ho:140, cr:90 };

const PST = {
    P:[[0,0,0,0,0,0,0,0],[50,50,50,50,50,50,50,50],[10,10,20,30,30,20,10,10],[5,5,10,25,25,10,5,5],[0,0,0,20,20,0,0,0],[5,-5,-10,0,0,-10,-5,5],[5,10,10,-20,-20,10,10,5],[0,0,0,0,0,0,0,0]],
    N:[[-50,-40,-30,-30,-30,-30,-40,-50],[-40,-20,0,0,0,0,-20,-40],[-30,0,10,15,15,10,0,-30],[-30,5,15,20,20,15,5,-30],[-30,0,15,20,20,15,0,-30],[-30,5,10,15,15,10,5,-30],[-40,-20,0,5,5,0,-20,-40],[-50,-40,-30,-30,-30,-30,-40,-50]],
    B:[[-20,-10,-10,-10,-10,-10,-10,-20],[-10,0,0,0,0,0,0,-10],[-10,0,5,10,10,5,0,-10],[-10,5,5,10,10,5,5,-10],[-10,0,10,10,10,10,0,-10],[-10,10,10,10,10,10,10,-10],[-10,5,0,0,0,0,5,-10],[-20,-10,-10,-10,-10,-10,-10,-20]],
    R:[[0,0,0,0,0,0,0,0],[5,10,10,10,10,10,10,5],[-5,0,0,0,0,0,0,-5],[-5,0,0,0,0,0,0,-5],[-5,0,0,0,0,0,0,-5],[-5,0,0,0,0,0,0,-5],[-5,0,0,0,0,0,0,-5],[0,0,0,5,5,0,0,0]],
    Q:[[-20,-10,-10,-5,-5,-10,-10,-20],[-10,0,0,0,0,0,0,-10],[-10,0,5,5,5,5,0,-10],[-5,0,5,5,5,5,0,-5],[0,0,5,5,5,5,0,-5],[-10,5,5,5,5,5,0,-10],[-10,0,5,0,0,0,0,-10],[-20,-10,-10,-5,-5,-10,-10,-20]],
    K:[[-30,-40,-40,-50,-50,-40,-40,-30],[-30,-40,-40,-50,-50,-40,-40,-30],[-30,-40,-40,-50,-50,-40,-40,-30],[-30,-40,-40,-50,-50,-40,-40,-30],[-20,-30,-30,-40,-40,-30,-30,-20],[-10,-20,-20,-20,-20,-20,-20,-10],[20,20,0,0,0,0,20,20],[20,30,10,0,0,10,30,20]]
};
// Center-preferring PST for pieces that reward active central positions
const PST_CENTER=[[-10,-8,-5,-5,-5,-5,-8,-10],[-8,-5,0,0,0,0,-5,-8],[-5,0,5,8,8,5,0,-5],[-5,0,8,12,12,8,0,-5],[-5,0,8,12,12,8,0,-5],[-5,0,5,8,8,5,0,-5],[-8,-5,0,0,0,0,-5,-8],[-10,-8,-5,-5,-5,-5,-8,-10]];
PST.J  = PST.R;   PST.L  = PST.R;   PST.E  = PST.P;   PST.Y  = PST.B;
PST.D  = PST.Q;   PST.Z  = PST_CENTER; PST.H  = PST.N;   PST.S  = PST.Q;
PST.F  = PST_CENTER; PST.A  = PST.N;   PST.O  = PST_CENTER; PST.I  = PST_CENTER;
PST.G  = PST.N;   PST.V  = PST.P;   PST.M  = PST.B;   PST.W  = PST_CENTER;
PST.C  = PST.Q;   PST.T  = PST_CENTER; PST.U  = PST.K;   PST.X  = PST_CENTER;
PST.CH = PST.B;   PST.HK = PST.K;   PST.HY = PST.Q;   PST.LB = PST.B;
PST.FK = PST.K;
// Grade-0 custom pawns
PST.SQ = PST.P; PST.LP = PST.P; PST.RT = PST.P; PST.HO = PST.P; PST.CR = PST.P;

function copyBoard(b) { return b.map(r => [...r]); }
function isW(p) { return p && p === p.toUpperCase(); }
function isB(p) { return p && p === p.toLowerCase(); }
function col(p) { return p ? (isW(p) ? 'w' : 'b') : null; }
function opp(c) { return c === 'w' ? 'b' : 'w'; }
function inB(r,c) { return r>=0&&r<8&&c>=0&&c<8; }
function tp(p) { return p ? p.toLowerCase() : null; }
function mkp(t,c) { return c==='w' ? t.toUpperCase() : t.toLowerCase(); }

function allyPrincessBoost(board, row, c2, c) {
    for (let r=0;r<8;r++) for (let c3=0;c3<8;c3++) {
        const p=board[r][c3];
        if (!p||col(p)!==c||tp(p)!=='s') continue;
        const dr=Math.abs(r-row), dc=Math.abs(c3-c2);
        if ((dr===1&&dc===1)||(dr===2&&dc===0)||(dr===0&&dc===2)) return 1;
    }
    return 0;
}

function pseudoMoves(board, row, c2) {
    const p=board[row][c2]; if(!p) return [];
    const c=col(p), t=tp(p), ms=[];
    const def=PIECE_DEFS_MAP[t];
    if (!def) return ms;

    if (def.special) {
        const d=c==='w'?-1:1, sr=c==='w'?6:1;
        if (inB(row+d,c2)&&!board[row+d][c2]) {
            ms.push([row+d,c2]);
            if (row===sr&&!board[row+2*d][c2]) ms.push([row+2*d,c2]);
        }
        for (const dc of [-1,1]) {
            if (inB(row+d,c2+dc)) {
                const tgt=board[row+d][c2+dc];
                if (tgt&&col(tgt)!==c) ms.push([row+d,c2+dc]);
            }
        }
        return ms;
    }

    if (t==='l') {
        const fwd=c==='w'?-1:1;
        for (let i=1;i<=4;i++) {
            const nr=row+fwd*i,nc=c2;
            if (!inB(nr,nc)) break;
            if (board[nr][nc]) { if(col(board[nr][nc])!==c) ms.push([nr,nc]); break; }
            if (i<=3) ms.push([nr,nc]);
        }
        const br=row-fwd;
        if (inB(br,c2)&&!board[br][c2]) ms.push([br,c2]);
        return ms;
    }
    if (t==='e') {
        const fwd=c==='w'?-1:1;
        for (const dc of [-1,1]) {
            const nr=row+fwd,nc=c2+dc;
            if (inB(nr,nc)&&!board[nr][nc]) ms.push([nr,nc]);
        }
        const nr=row+fwd;
        if (inB(nr,c2)&&board[nr][c2]&&col(board[nr][c2])!==c) ms.push([nr,c2]);
        return ms;
    }
    if (t==='sq') { // Squire: 1 forward or 1 sideways, captures same
        const fwd=c==='w'?-1:1;
        for (const [dr,dc] of [[fwd,0],[0,-1],[0,1]]) {
            const nr=row+dr,nc=c2+dc;
            if (inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if (t==='lp') { // Longpaw: up to 2 forward (walk), diagonal forward (capture only)
        const fwd=c==='w'?-1:1;
        for (let i=1;i<=2;i++) {
            const nr=row+fwd*i;
            if (!inB(nr,c2)||board[nr][c2]) break;
            ms.push([nr,c2]);
        }
        for (const dc of [-1,1]) {
            const nr=row+fwd,nc=c2+dc;
            if (inB(nr,nc)&&board[nr][nc]&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if (t==='rt') { // Retreater: 1 forward or 1 backward, captures same
        const fwd=c==='w'?-1:1;
        for (const dr of [fwd,-fwd]) {
            const nr=row+dr;
            if (inB(nr,c2)&&col(board[nr][c2])!==c) ms.push([nr,c2]);
        }
        return ms;
    }
    if (t==='ho') { // Hollow: 1-2 forward jumping over any piece, diagonal forward capture
        const fwd=c==='w'?-1:1;
        for (let i=1;i<=2;i++) {
            const nr=row+fwd*i;
            if (!inB(nr,c2)) break;
            if (!board[nr][c2]) ms.push([nr,c2]);
        }
        for (const dc of [-1,1]) {
            const nr=row+fwd,nc=c2+dc;
            if (inB(nr,nc)&&board[nr][nc]&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if (t==='cr') { // Crawler: 1 sideways to empty, captures 1 straight forward
        const fwd=c==='w'?-1:1;
        for (const dc of [-1,1]) {
            const nc=c2+dc;
            if (inB(row,nc)&&!board[row][nc]) ms.push([row,nc]);
        }
        const nr=row+fwd;
        if (inB(nr,c2)&&board[nr][c2]&&col(board[nr][c2])!==c) ms.push([nr,c2]);
        return ms;
    }
    if (t==='y') {
        const fwd=c==='w'?-1:1;
        for (const [dr,dc] of [[fwd,-1],[fwd,1],[-fwd,0]]) {
            for (let i=1;i<8;i++) {
                const nr=row+dr*i,nc=c2+dc*i;
                if (!inB(nr,nc)) break;
                if (board[nr][nc]) { if(col(board[nr][nc])!==c) ms.push([nr,nc]); break; }
                ms.push([nr,nc]);
            }
        }
        return ms;
    }
    if (t==='d') {
        for (const [dr,dc] of [[-2,3],[-2,1],[-2,-1],[-2,-3],[2,3],[2,1],[2,-1],[2,-3]]) {
            const nr=row+dr,nc=c2+dc;
            if (inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if (t==='z') {
        for (let dr=-2;dr<=2;dr++) for (let dc=-2;dc<=2;dc++) {
            if (dr===0&&dc===0) continue;
            const nr=row+dr,nc=c2+dc;
            if (!inB(nr,nc)) continue;
            if (board[nr][nc]) {
                if (col(board[nr][nc])!==c&&Math.abs(dr)<=1&&Math.abs(dc)<=1) ms.push([nr,nc]);
            } else {
                ms.push([nr,nc]);
            }
        }
        return ms;
    }
    if (t==='h') {
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
            const nr=row+dr,nc=c2+dc;
            if (!inB(nr,nc)) continue;
            if (board[nr][nc]) { if (col(board[nr][nc])!==c) ms.push([nr,nc]); }
            else if (Math.abs(dr)===Math.abs(dc)) ms.push([nr,nc]); // diagonal-only to empty squares
        }
        return ms;
    }
    if (t==='s') {
        for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) {
            const nr=row+dr,nc=c2+dc;
            if (inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        for (const [dr,dc] of [[-2,0],[2,0],[0,-2],[0,2]]) {
            const nr=row+dr,nc=c2+dc;
            if (inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if (t==='f') {
        for (const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) {
            const nr=row+dr,nc=c2+dc;
            if (inB(nr,nc)&&board[nr][nc]&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        for (const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) {
            let er=row+dr,ec=c2+dc,lastEmpty=null;
            while (inB(er,ec)) { if(!board[er][ec]) lastEmpty=[er,ec]; er+=dr; ec+=dc; }
            if (lastEmpty) ms.push(lastEmpty);
        }
        return ms;
    }
    if (t==='a') {
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
            const nr=row+dr,nc=c2+dc;
            if (inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if (t==='o') {
        for (let r=0;r<8;r++) for (let c3=0;c3<8;c3++) {
            if (r===row&&c3===c2) continue;
            if (!board[r][c3]) ms.push([r,c3]);
        }
        for (const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) {
            const nr=row+dr,nc=c2+dc;
            if (inB(nr,nc)&&board[nr][nc]&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if (t==='i') {
        const fwd=c==='w'?-1:1;
        for (const dc of [-1,1]) {
            for (let i=1;i<8;i++) {
                const nc=c2+dc*i;
                if (!inB(row,nc)) break;
                if (board[row][nc]) { if(col(board[row][nc])!==c) ms.push([row,nc]); }
                else ms.push([row,nc]);
            }
        }
        if (inB(row+fwd,c2)&&!board[row+fwd][c2]) ms.push([row+fwd,c2]);
        for (const [dr,dc] of [[-fwd,-1],[-fwd,0],[-fwd*2,0],[-fwd,1]]) {
            const nr=row+dr,nc=c2+dc;
            if (inB(nr,nc)&&!board[nr][nc]) ms.push([nr,nc]);
        }
        return ms;
    }
    if (t==='g') {
        for (const [dr,dc] of [[-3,0],[3,0],[0,-3],[0,3]]) {
            const nr=row+dr,nc=c2+dc;
            if (inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if (t==='v') {
        const fwd=c==='w'?-1:1;
        const nr=row+fwd;
        if (inB(nr,c2)&&!board[nr][c2]) ms.push([nr,c2]);
        if (inB(nr,c2)&&board[nr][c2]&&col(board[nr][c2])!==c) ms.push([nr,c2]);
        return ms;
    }
    if (t==='c') { // Feather: checkers-style diagonal (move + jump-capture)
        for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) {
            const nr=row+dr, nc=c2+dc;
            if (inB(nr,nc) && !board[nr][nc]) ms.push([nr,nc]);
            const jr=row+2*dr, jc=c2+2*dc;
            if (inB(nr,nc) && inB(jr,jc) && board[nr][nc] && col(board[nr][nc])!==c && !board[jr][jc]) ms.push([jr,jc]);
        }
        return ms;
    }
    if (t==='m') { // Lantern: diagonal jumper range 2
        for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) {
            const nr1=row+dr, nc1=c2+dc;
            if (inB(nr1,nc1) && col(board[nr1][nc1])!==c) ms.push([nr1,nc1]);
            const nr2=row+2*dr, nc2=c2+2*dc;
            if (inB(nr2,nc2) && col(board[nr2][nc2])!==c) ms.push([nr2,nc2]);
        }
        return ms;
    }
    if (t==='t') { // Wizard: same-color squares in 5x5, swap with enemy
        const myColor=(row+c2)%2;
        for (let dr=-2;dr<=2;dr++) for (let dc=-2;dc<=2;dc++) {
            if (dr===0&&dc===0) continue;
            const nr=row+dr, nc=c2+dc;
            if (!inB(nr,nc)) continue;
            if ((nr+nc)%2!==myColor) continue;
            if (!board[nr][nc] || col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if (t==='u') { // Oracle: moves like king
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
            const nr=row+dr, nc=c2+dc;
            if (inB(nr,nc) && col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }
    if (t==='w') { // Eclipse: rook on dark squares, bishop on light squares
        const isDark=(row+c2)%2===1;
        if (isDark) {
            for (const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) {
                for (let i=1;i<8;i++) {
                    const nr=row+dr*i, nc=c2+dc*i;
                    if (!inB(nr,nc)) break;
                    if (board[nr][nc]) { if(col(board[nr][nc])!==c) ms.push([nr,nc]); break; }
                    ms.push([nr,nc]);
                }
            }
        } else {
            for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) {
                for (let i=1;i<8;i++) {
                    const nr=row+dr*i, nc=c2+dc*i;
                    if (!inB(nr,nc)) break;
                    if (board[nr][nc]) { if(col(board[nr][nc])!==c) ms.push([nr,nc]); break; }
                    ms.push([nr,nc]);
                }
            }
        }
        return ms;
    }

    if (t==='x') { // Coil: zigzag snake in each + direction (infinite range)
        const fwd=c==='w'?-1:1;
        // [primary_dr, primary_dc, side_dr, side_dc]
        for (const [pdr,pdc,sdr,sdc] of [[fwd,0,0,1],[-fwd,0,0,1],[0,1,fwd,0],[0,-1,fwd,0]]) {
            let cr=row,cc=c2;
            // First step: pure primary direction
            const nr1=cr+pdr,nc1=cc+pdc;
            if (!inB(nr1,nc1)) continue;
            if (board[nr1][nc1]) { if(col(board[nr1][nc1])!==c) ms.push([nr1,nc1]); continue; }
            ms.push([nr1,nc1]); cr=nr1; cc=nc1;
            // Subsequent steps: diagonal (primary + alternating side)
            let side=1;
            while (true) {
                const nr=cr+pdr+sdr*side,nc=cc+pdc+sdc*side;
                if (!inB(nr,nc)) break;
                if (board[nr][nc]) { if(col(board[nr][nc])!==c) ms.push([nr,nc]); break; }
                ms.push([nr,nc]); cr=nr; cc=nc;
                side=-side;
            }
        }
        return ms;
    }
    if (t==='ch') { // Choir: alternates + and diagonal each move
        const key=row+','+c2;
        const cnt=gs&&gs.choirCounts?(gs.choirCounts[key]||0):0;
        const dirs=(cnt%2===0)?[[-1,0],[1,0],[0,-1],[0,1]]:[[-1,-1],[-1,1],[1,-1],[1,1]];
        for (const [dr,dc] of dirs) {
            for (let i=1;i<8;i++) {
                const nr=row+dr*i,nc=c2+dc*i;
                if (!inB(nr,nc)) break;
                if (board[nr][nc]) { if(col(board[nr][nc])!==c) ms.push([nr,nc]); break; }
                ms.push([nr,nc]);
            }
        }
        return ms;
    }
    if (t==='hk') { // Husk: king pattern with range growing by 1 per capture
        const captures=gs&&gs.huskCaptures?(gs.huskCaptures[c]||0):0;
        const range=1+captures;
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
            for (let i=1;i<=range;i++) {
                const nr=row+dr*i,nc=c2+dc*i;
                if (!inB(nr,nc)) break;
                if (board[nr][nc]) { if(col(board[nr][nc])!==c) ms.push([nr,nc]); break; }
                ms.push([nr,nc]);
            }
        }
        return ms;
    }
    if (t==='hy') { // Hydra: queen pattern, range 3
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
            for (let i=1;i<=3;i++) {
                const nr=row+dr*i,nc=c2+dc*i;
                if (!inB(nr,nc)) break;
                if (board[nr][nc]) { if(col(board[nr][nc])!==c) ms.push([nr,nc]); break; }
                ms.push([nr,nc]);
            }
        }
        return ms;
    }
    if (t==='lb') { // Library: copies last captured enemy piece's moveset
        const copied=gs&&gs.libraryChar?(gs.libraryChar[c]||null):null;
        if (copied && copied!=='lb') {
            const tmp=board.map(r=>[...r]);
            tmp[row][c2]=mkp(copied,c);
            return pseudoMoves(tmp,row,c2);
        }
        // No piece copied yet: king-pattern fallback
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
            const nr=row+dr,nc=c2+dc;
            if (inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        return ms;
    }

    if (t==='fk') { // Fork: T-pattern (range-2 ortho + range-3 crossbar) + king diagonals; can't move when attacked
        for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) {
            const nr=row+dr,nc=c2+dc;
            if (inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
        for (const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) {
            const perpDirs=dr===0?[[-1,0],[1,0]]:[[0,-1],[0,1]];
            const ar1=row+dr,ac1=c2+dc;
            if (!inB(ar1,ac1)) continue;
            if (board[ar1][ac1]) { if(col(board[ar1][ac1])!==c) ms.push([ar1,ac1]); continue; }
            ms.push([ar1,ac1]);
            const ar2=row+2*dr,ac2=c2+2*dc;
            if (!inB(ar2,ac2)) continue;
            if (board[ar2][ac2]) { if(col(board[ar2][ac2])!==c) ms.push([ar2,ac2]); }
            else {
                ms.push([ar2,ac2]);
                for (const [pdr,pdc] of perpDirs) {
                    for (let i=1;i<=2;i++) {
                        const pr=ar2+pdr*i,pc=ac2+pdc*i;
                        if (!inB(pr,pc)) break;
                        if (board[pr][pc]) { if(col(board[pr][pc])!==c) ms.push([pr,pc]); break; }
                        ms.push([pr,pc]);
                    }
                }
            }
        }
        return ms;
    }

    if (def.lshape) {
        for (const [dr,dc] of [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]) {
            const nr=row+dr,nc=c2+dc;
            if (inB(nr,nc)&&col(board[nr][nc])!==c) ms.push([nr,nc]);
        }
    }

    const dirs=[];
    const fwd=c==='w'?-1:1;
    if (def.fwd)  dirs.push([fwd,0]);
    if (def.bwd)  dirs.push([-fwd,0]);
    if (def.side) { dirs.push([0,-1]); dirs.push([0,1]); }
    if (def.diag) { dirs.push([-1,-1]); dirs.push([-1,1]); dirs.push([1,-1]); dirs.push([1,1]); }
    const baseR=def.range===0?7:def.range;
    const maxR=def.range===0?7:baseR+allyPrincessBoost(board,row,c2,c);

    for (const [dr,dc] of dirs) {
        for (let i=1;i<=maxR;i++) {
            const nr=row+dr*i,nc=c2+dc*i;
            if (!inB(nr,nc)) break;
            if (board[nr][nc]) {
                if (col(board[nr][nc])!==c) ms.push([nr,nc]);
                if (!def.jump) break;
            } else {
                ms.push([nr,nc]);
            }
        }
    }
    return ms;
}

function isAttacked(board, row, c2, byColor) {
    for (let r=0;r<8;r++) for (let c=0;c<8;c++) {
        const p=board[r][c];
        if (p && col(p)===byColor) {
            if (pseudoMoves(board,r,c).some(([mr,mc])=>mr===row&&mc===c2)) return true;
        }
    }
    return false;
}

function inCheck(board, c) {
    for (let r=0;r<8;r++) for (let c2=0;c2<8;c2++) {
        const p=board[r][c2];
        if (p && col(p)===c && pieceGrade(tp(p))===3 && isAttacked(board,r,c2,opp(c))) return true;
    }
    return false;
}

function applyMove(board, from, to, ep, castling, promo) {
    const nb=copyBoard(board);
    const [fr,fc]= from, [tr,tc]=to;
    const p=nb[fr][fc], t=tp(p), c=col(p);
    const captured=nb[tr][tc];
    nb[tr][tc]=p; nb[fr][fc]=null;
    if (t==='p'&&ep&&tr===ep[0]&&tc===ep[1]) nb[fr][tc]=null;
    if (t==='k') {
        if (fc===4&&tc===6) { nb[fr][7]=null; nb[fr][5]=mkp('r',c); }
        else if (fc===4&&tc===2) { nb[fr][0]=null; nb[fr][3]=mkp('r',c); }
    }
    if (t==='p'&&(tr===0||tr===7)) nb[tr][tc]=mkp(promo||'q',c);
    if (captured&&tp(captured)==='h') nb[tr][tc]=null;
    if (t==='c'&&Math.abs(tr-fr)===2&&Math.abs(tc-fc)===2) {
        const mr=(fr+tr)/2, mc=(fc+tc)/2;
        if (nb[mr][mc]&&col(nb[mr][mc])!==c) nb[mr][mc]=null;
    }
    if (t==='t'&&captured&&col(captured)!==c) nb[fr][fc]=captured;
    return nb;
}

function newCastling(castling, from, board) {
    const c={...castling}, [r,fc]=from, p=board[r][fc];
    if (!p) return c;
    const t=tp(p), cl=col(p);
    if (t==='k') { if(cl==='w'){c.wK=false;c.wQ=false;}else{c.bK=false;c.bQ=false;} }
    else if (t==='r') {
        if(cl==='w'){if(r===7&&fc===7)c.wK=false;if(r===7&&fc===0)c.wQ=false;}
        else{if(r===0&&fc===7)c.bK=false;if(r===0&&fc===0)c.bQ=false;}
    }
    return c;
}

function newEP(board, from, to) {
    const [fr,fc]=from,[tr,tc]=to,p=board[fr][fc];
    if (!p||tp(p)!=='p') return null;
    if (Math.abs(tr-fr)===2) return [(fr+tr)/2,tc];
    return null;
}

function legalMoves(board, row, c2, castling, ep, turn) {
    const p=board[row][c2]; if(!p||col(p)!==turn) return [];
    const c=col(p), t=tp(p), ms=[];
    // Fork is paralyzed when it is directly attacked — other pieces must deal with the threat
    if (t==='fk' && isAttacked(board,row,c2,opp(c))) return [];
    for (const [tr,tc] of pseudoMoves(board,row,c2)) {
        const nb=applyMove(board,[row,c2],[tr,tc],ep,castling);
        if (!inCheck(nb,c)) ms.push([tr,tc]);
    }
    if (t==='p'&&ep) {
        const d=c==='w'?-1:1;
        if (row+d===ep[0]&&Math.abs(c2-ep[1])===1) {
            const nb=applyMove(board,[row,c2],[...ep],ep,castling);
            if (!inCheck(nb,c)) ms.push([...ep]);
        }
    }
    if (t==='k'&&!inCheck(board,c)) {
        const br=c==='w'?7:0;
        if (row===br&&c2===4) {
            const canKS=c==='w'?castling.wK:castling.bK;
            if (canKS&&!board[br][5]&&!board[br][6]&&!isAttacked(board,br,5,opp(c))&&!isAttacked(board,br,6,opp(c))) {
                const nb=applyMove(board,[row,c2],[br,6],ep,castling);
                if (!inCheck(nb,c)) ms.push([br,6]);
            }
            const canQS=c==='w'?castling.wQ:castling.bQ;
            if (canQS&&!board[br][3]&&!board[br][2]&&!board[br][1]&&!isAttacked(board,br,3,opp(c))&&!isAttacked(board,br,2,opp(c))) {
                const nb=applyMove(board,[row,c2],[br,2],ep,castling);
                if (!inCheck(nb,c)) ms.push([br,2]);
            }
        }
    }
    return ms;
}

function allLegal(board, castling, ep, turn) {
    const ms=[];
    for (let r=0;r<8;r++) for (let c=0;c<8;c++) {
        const p=board[r][c];
        if (p&&col(p)===turn) {
            if (gs&&gs.lanternImmobileFor===turn&&gs.lanternImmobile&&gs.lanternImmobile.some(([ir,ic])=>ir===r&&ic===c)) continue;
            for (const [tr,tc] of legalMoves(board,r,c,castling,ep,turn))
                ms.push({from:[r,c],to:[tr,tc]});
        }
    }
    return ms;
}

function evaluate(board) {
    let s=0;
    for (let r=0;r<8;r++) for (let c=0;c<8;c++) {
        const p=board[r][c]; if(!p) continue;
        const t=tp(p), w=isW(p);
        const pv=PIECE_VALUES[t]||100;
        const pstRow=w?r:7-r;
        const pst=PST[t.toUpperCase()];
        let pos=pst?pst[pstRow][c]:0;
        // Extra center bonus for custom pieces that lack good PST guidance
        if(!pst&&r>=2&&r<=5&&c>=2&&c<=5) pos+=8;
        s+=(w?1:-1)*(pv+pos);
    }
    return s;
}

function orderMoves(board, ms) {
    return ms.sort((a,b)=>{
        // MVV-LVA: prefer capturing high-value pieces with low-value pieces
        const va=board[a.to[0]][a.to[1]]?PIECE_VALUES[tp(board[a.to[0]][a.to[1]])]:0;
        const vb=board[b.to[0]][b.to[1]]?PIECE_VALUES[tp(board[b.to[0]][b.to[1]])]:0;
        const ava=board[a.from[0]][a.from[1]]?PIECE_VALUES[tp(board[a.from[0]][a.from[1]])]:0;
        const avb=board[b.from[0]][b.from[1]]?PIECE_VALUES[tp(board[b.from[0]][b.from[1]])]:0;
        const scoreA=(va>0?(va*10-ava/10):0);
        const scoreB=(vb>0?(vb*10-avb/10):0);
        return scoreB-scoreA;
    });
}

function minimax(board, depth, alpha, beta, maxing, castling, ep) {
    if (depth===0) return {score:evaluate(board),move:null};
    const turn=maxing?'w':'b';
    const ms=allLegal(board,castling,ep,turn);
    if (ms.length===0) return {score:inCheck(board,turn)?(maxing?-99999:99999):0,move:null};
    const ordered=orderMoves(board,ms);
    let best={score:maxing?-Infinity:Infinity,move:null};
    for (const m of ordered) {
        const nb=applyMove(board,m.from,m.to,ep,castling);
        const nc=newCastling(castling,m.from,board);
        const ne=newEP(board,m.from,m.to);
        const r=minimax(nb,depth-1,alpha,beta,!maxing,nc,ne);
        if (maxing){if(r.score>best.score){best={score:r.score,move:m};} alpha=Math.max(alpha,r.score);}
        else{if(r.score<best.score){best={score:r.score,move:m};} beta=Math.min(beta,r.score);}
        if (beta<=alpha) break;
    }
    return best;
}

function pickPersonality(elo) {
    const r=Math.random();
    if (elo<=200)      return r<0.55?'chaotic':(r<0.80?'aggressive':'balanced');
    if (elo<=400)      return r<0.25?'chaotic':(r<0.50?'aggressive':(r<0.75?'defensive':'balanced'));
    if (elo<=600)      return r<0.22?'aggressive':(r<0.44?'defensive':(r<0.70?'positional':'balanced'));
    if (elo<=800)      return r<0.30?'aggressive':(r<0.60?'positional':(r<0.80?'defensive':'balanced'));
    /* 1000 */         return r<0.45?'positional':(r<0.75?'aggressive':'balanced');
}

function scoreMovePsych(board, m, personality, aiColor, moveNum) {
    let bonus=0;
    const [fr,fc]=m.from,[tr,tc]=m.to;
    const piece=board[fr][fc];
    const captured=board[tr][tc];
    const isCapture=!!captured;
    const forward=aiColor==='w'?(fr-tr):(tr-fr);
    const pieceType=tp(piece);
    const inCenter=(tr>=2&&tr<=5&&tc>=2&&tc<=5);

    // Universal human-like heuristics
    // 1. Prioritise safe captures by material gain (even without psych)
    if(isCapture&&captured) {
        const gain=PIECE_VALUES[tp(captured)]-(PIECE_VALUES[pieceType]||100);
        if(gain>0) bonus+=gain*0.12; // winning trade is always good
    }
    // 2. Prefer developing new pieces in the opening (moves 1-12)
    if(moveNum!==undefined&&moveNum<12) {
        // Penalise moving the same piece twice before all pieces developed
        if(pieceType==='k'&&!isCapture) bonus-=25; // avoid king moves early
        if(inCenter&&(pieceType==='n'||pieceType==='b')) bonus+=20; // develop to center
    }
    // 3. Penalise retreating into corners
    const inCorner=(tr<=1||tr>=6)&&(tc<=1||tc>=6);
    if(inCorner&&!isCapture) bonus-=15;

    switch(personality) {
        case 'aggressive':
            if(isCapture) bonus+=45+(captured?PIECE_VALUES[tp(captured)]*0.03:0);
            bonus+=forward*8;
            if(inCenter) bonus+=10;
            break;
        case 'defensive':
            if(isCapture) bonus+=20;
            bonus-=forward*4;
            // prefer centre-adjacent squares rather than far corners
            bonus-=Math.max(0,(Math.abs(tc-3.5)+Math.abs(tr-3.5)-3))*4;
            break;
        case 'positional':
            if(inCenter) bonus+=22;
            if(isCapture) bonus+=15;
            bonus+=forward*3;
            break;
        case 'chaotic':
            bonus+=Math.random()*90-45; // reduced chaos band
            break;
        default: // balanced
            if(isCapture) bonus+=12;
            if(inCenter) bonus+=8;
            bonus+=forward*2;
    }
    return bonus;
}

function getAIMove(board, castling, ep, aiColor, elo, personality) {
    const ms=allLegal(board,castling,ep,aiColor);
    if (!ms.length) return null;
    // depth / noise / pool size by ELO
    let depth, noiseRange, topN;
    if      (elo<=200) {depth=1; noiseRange=120; topN=Math.max(1,Math.floor(ms.length*0.65));}
    else if (elo<=400) {depth=1; noiseRange=60;  topN=Math.max(1,Math.floor(ms.length*0.40));}
    else if (elo<=600) {depth=2; noiseRange=28;  topN=Math.max(1,Math.floor(ms.length*0.22));}
    else if (elo<=800) {depth=2; noiseRange=10;  topN=Math.max(1,Math.ceil (ms.length*0.08));}
    else               {depth=3; noiseRange=0;   topN=1;}
    const pers=personality||'balanced';
    const moveNum=gs&&gs.history?gs.history.length:0;
    const scored=ms.map(m=>{
        const nb=applyMove(board,m.from,m.to,ep,castling);
        const nc=newCastling(castling,m.from,board);
        const ne=newEP(board,m.from,m.to);
        const res=minimax(nb,depth-1,-Infinity,Infinity,aiColor!=='w',nc,ne);
        const psychBonus=scoreMovePsych(board,m,pers,aiColor,moveNum);
        const noise=noiseRange>0?(Math.random()*noiseRange-noiseRange/2):0;
        return {m, score:(aiColor==='w'?res.score:-res.score)+psychBonus+noise};
    });
    scored.sort((a,b)=>b.score-a.score);
    // Weighted random selection from pool: rank 1 = topN weight, last = 1 weight
    const pool=scored.slice(0,topN);
    const totalW=pool.reduce((s,_,i)=>s+(topN-i),0);
    let rand=Math.random()*totalW;
    for (let i=0;i<pool.length;i++){rand-=(topN-i);if(rand<=0)return pool[i].m;}
    return pool[0].m;
}

const FILES='abcdefgh', RANKS='87654321';
const UNI=(()=>{const m={};PIECE_REGISTRY.forEach(pd=>{const lo=pd.gameChar,hi=lo.toUpperCase();if(!m[lo])m[lo]=pd.blackUnicode;if(!m[hi])m[hi]=pd.whiteUnicode;});m['v']='♟';m['V']='♙';return m;})();

function toNotation(board, from, to, ep, promo) {
    const [fr,fc]= from,[tr,tc]=to, p=board[fr][fc];
    if (!p) return '';
    const t=tp(p);
    if (t==='k'&&Math.abs(fc-tc)===2) return tc>fc?'O-O':'O-O-O';
    const capture=board[tr][tc]||(t==='p'&&ep&&tr===ep[0]&&tc===ep[1]);
    let n=t==='p'?'':(t.toUpperCase());
    if (t==='p'&&capture) n=FILES[fc];
    if (capture) n+='x';
    n+=FILES[tc]+RANKS[tr];
    if (promo) n+='='+promo.toUpperCase();
    return n;
}

const INIT_BOARD=[
    ['r','n','b','q','k','b','n','r'],
    ['p','p','p','p','p','p','p','p'],
    [null,null,null,null,null,null,null,null],
    [null,null,null,null,null,null,null,null],
    [null,null,null,null,null,null,null,null],
    [null,null,null,null,null,null,null,null],
    ['P','P','P','P','P','P','P','P'],
    ['R','N','B','Q','K','B','N','R']
];

let gs={
    board:null, turn:'w',
    castling:{wK:true,wQ:true,bK:true,bQ:true},
    ep:null, selected:null, selMoves:[],
    history:[], redoStack:[], gameOver:false, result:'',
    playerColor:'w', aiColor:'b', aiElo:600,
    pendingPromo:null, lastFrom:null, lastTo:null, aiThinking:false,
    aiPersonality:'balanced'
};

let pointerStart=null;
let isDragging=false;
const DRAG_THRESHOLD=6;

function getCellSize() {
    var b=document.getElementById('chessBoard');
    if (b) { var s=b.getBoundingClientRect().width/8; if(s>8) return s; }
    return 105;
}
const SVG_CELL=105; /* fixed — matches viewBox="0 0 840 840" */

let arrows=[];
let highlights=[];
let rightDragStart=null;

// ── Bot state ──────────────────────────────────────────────────────────────
var currentBot = null;
var voicelineTimer = null;
var periodicTimer = null;
var selectedPickerBot = null;

const ARMY_PIECE_MAP = (() => {
    const m = {};
    PIECE_REGISTRY.forEach(pd => { m[pd.type] = pd.gameChar; });
    return m;
})();

const SPRITE_MAP = (() => {
    const m = {};
    PIECE_REGISTRY.forEach(pd => {
        if (pd.sprite && !m[pd.gameChar]) m[pd.gameChar] = pd.sprite;
    });
    return m;
})();

const PIECE_DEFS_MAP = (() => {
    const m = {};
    PIECE_REGISTRY.forEach(pd => { if (!m[pd.gameChar]) m[pd.gameChar] = pd; });
    // Beast: spawned dynamically by Beast Handler, not in the army builder registry
    m['v'] = {grade:0,special:false,fwd:false,bwd:false,side:false,diag:false,jump:false,lshape:false,range:1};
    return m;
})();

const STD_WHITE_ROWS = {7:['R','N','B','Q','K','B','N','R'], 6:['P','P','P','P','P','P','P','P']};
const STD_BLACK_ROWS = {0:['r','n','b','q','k','b','n','r'], 1:['p','p','p','p','p','p','p','p']};

// ── Piece grade (0=pawn, 1=minor/major, 2=queen, 3=king) ──────────────────
function pieceGrade(gameChar) {
    const t = gameChar.toLowerCase();
    if (t === 'p' || t === 'e' || t === 'v' || t === 'sq' || t === 'lp' || t === 'rt' || t === 'ho' || t === 'cr') return 0;
    if (t === 'q' || t === 'z' || t === 's' || t === 'o' || t === 'c' || t === 't') return 2;
    if (t === 'k' || t === 'u' || t === 'hk' || t === 'hy' || t === 'lb' || t === 'fk') return 3;
    return 1;
}

// ── Voiceline display ──────────────────────────────────────────────────────
function showBotVoiceline(text) {
    if (!text) return;
    const el = document.getElementById('botBubble');
    if (!el) return;
    clearTimeout(voicelineTimer);
    el.textContent = '"' + text + '"';
    el.classList.add('visible');
    voicelineTimer = setTimeout(function() { el.classList.remove('visible'); }, 4500);
}

function randomFrom(arr) {
    if (!arr || !arr.length) return null;
    return arr[Math.floor(Math.random() * arr.length)];
}

function schedulePeriodicVoiceline() {
    clearTimeout(periodicTimer);
    if (!currentBot || !currentBot.voicelines || !currentBot.voicelines.length) return;
    var delay = 28000 + Math.random() * 22000;
    periodicTimer = setTimeout(function() {
        if (!gs.gameOver && currentBot) showBotVoiceline(randomFrom(currentBot.voicelines));
        schedulePeriodicVoiceline();
    }, delay);
}

// ── Player panel update ────────────────────────────────────────────────────
function updatePlayerPanels() {
    if (gs.localPlay) {
        document.getElementById('topAvatar').textContent = '♚';
        document.getElementById('topName').textContent = 'Black';
        document.getElementById('topRating').textContent = 'Local';
        document.getElementById('bottomAvatar').textContent = '♔';
        document.getElementById('bottomName').textContent = 'White';
        document.getElementById('bottomRating').textContent = 'Local';
        return;
    }
    const flip = gs.playerColor === 'b';
    const topColor = flip ? 'w' : 'b';
    const botColor = flip ? 'b' : 'w';

    const topAvatar = document.getElementById('topAvatar');
    const topName   = document.getElementById('topName');
    const topRating = document.getElementById('topRating');
    const botAvatar = document.getElementById('bottomAvatar');

    botAvatar.textContent = botColor === 'w' ? '♔' : '♚';

    if (topColor === gs.aiColor && currentBot) {
        if (currentBot.imagePath) {
            topAvatar.innerHTML = '<img class="bot-avatar-img" src="' + CTX + '/' + currentBot.imagePath + '" alt="">';
        } else {
            topAvatar.textContent = topColor === 'w' ? '♔' : '♚';
        }
        topName.textContent = currentBot.name;
        topRating.textContent = currentBot.elo + ' ELO';
    } else {
        topAvatar.textContent = topColor === 'w' ? '♔' : '♚';
        topName.textContent = topColor === gs.aiColor ? ('AI (' + gs.aiElo + ' ELO)') : 'You';
        topRating.textContent = topColor === gs.aiColor ? (gs.aiElo + ' ELO') : 'Human';
    }
    document.getElementById('bottomName').textContent = botColor === gs.aiColor ? ('AI (' + gs.aiElo + ' ELO)') : 'You';
    document.getElementById('bottomRating').textContent = botColor === gs.aiColor ? (gs.aiElo + ' ELO') : 'Human';
}

function createGamePieceEl(p) {
    return buildPieceSVG(tp(p), isW(p));
}

function buildSide(army, isWhite) {
    if (!army || !army.length) return null;
    const rows = {};
    let hasKing = false;
    for (const p of army) {
        const ci = p.col.charCodeAt(0)-65, ri = 8-p.rank;
        if (ri<0||ri>7||ci<0||ci>7) continue;
        const t = ARMY_PIECE_MAP[p.pieceType]||'p';
        if (t==='k'||t==='u'||t==='hk'||t==='hy'||t==='lb'||t==='fk') hasKing = true;
        if (!rows[ri]) rows[ri] = [null,null,null,null,null,null,null,null];
        rows[ri][ci] = isWhite ? t.toUpperCase() : t;
    }
    return hasKing ? rows : null;
}

function buildBoard(playerColor) {
    const whiteArmy = (playerColor==='w'||playerColor==='both') ? PLAYER_WHITE_ARMY : PRESET_WHITE_ARMY;
    const blackArmy = (playerColor==='b'||playerColor==='both') ? PLAYER_BLACK_ARMY : PRESET_BLACK_ARMY;
    const board = [];
    for (let i=0;i<8;i++) board.push([null,null,null,null,null,null,null,null]);
    const wRows = buildSide(whiteArmy, true) || STD_WHITE_ROWS;
    const bRows = buildSide(blackArmy, false) || STD_BLACK_ROWS;
    for (const [ri, cells] of Object.entries(wRows)) board[parseInt(ri)] = [...cells];
    for (const [ri, cells] of Object.entries(bRows)) board[parseInt(ri)] = [...cells];
    const castling = {
        wK: board[7][4]==='K' && board[7][7]==='R',
        wQ: board[7][4]==='K' && board[7][0]==='R',
        bK: board[0][4]==='k' && board[0][7]==='r',
        bQ: board[0][4]==='k' && board[0][0]==='r'
    };
    return {board, castling};
}

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

function startGame(playerColor, elo, bot) {
    currentBot = LOCAL_PLAY ? null : (bot || null);
    clearTimeout(periodicTimer);

    const buildColor = LOCAL_PLAY ? 'both' : playerColor;
    const {board, castling} = buildBoard(buildColor);
    clearAnnotations();
    const effectiveColor = LOCAL_PLAY ? 'w' : playerColor;
    gs={
        board: board.map(r=>[...r]), turn:'w',
        castling,
        ep:null, selected:null, selMoves:[],
        history:[], redoStack:[], gameOver:false, result:'',
        playerColor: effectiveColor,
        aiColor: LOCAL_PLAY ? null : opp(playerColor),
        aiElo: LOCAL_PLAY ? 0 : elo,
        pendingPromo:null, lastFrom:null, lastTo:null, aiThinking:false,
        aiPersonality: LOCAL_PLAY ? null : pickPersonality(elo),
        bhCounts:{}, beasts:[], beastExpiry:-1,
        choirCounts:{}, huskCaptures:{w:0,b:0}, hydraHeads:{w:3,b:3}, libraryChar:{w:null,b:null},
        lanternImmobile:[], lanternImmobileFor:null,
        oracleCursedTile:null, oracleHasCursed:{w:false,b:false}, curseMode:false,
        localPlay: LOCAL_PLAY
    };
    applyOracleAutoStart();
    updatePlayerPanels();
    render();
    playSound('game_start');
    if (!LOCAL_PLAY) schedulePeriodicVoiceline();
    if (!LOCAL_PLAY && gs.playerColor==='b') setTimeout(doAI,1000);
}

function doAI() {
    if (gs.gameOver||gs.turn!==gs.aiColor||gs.aiThinking) return;
    gs.aiThinking=true; renderStatus();
    var thinkMs = 700 + Math.random() * 800; // 700–1500 ms
    setTimeout(()=>{
        const m=getAIMove(gs.board,gs.castling,gs.ep,gs.aiColor,gs.aiElo,gs.aiPersonality);
        if (m) {
            const p=gs.board[m.from[0]][m.from[1]];
            execMove(m.from,m.to,tp(p)==='p'&&(m.to[0]===0||m.to[0]===7)?'q':null);
        }
        gs.aiThinking=false;
    }, thinkMs);
}

function doAnimateMove(from, to, piece, onDone) {
    if (!piece) { if (onDone) onDone(); return; }
    const container=document.querySelector('.board-container');
    if (!container) { if (onDone) onDone(); return; }
    const cs=getCellSize();
    const flip=!gs.localPlay&&gs.playerColor==='b';
    const fci=flip?7-from[1]:from[1], fri=flip?7-from[0]:from[0];
    const tci=flip?7-to[1]:to[1],   tri=flip?7-to[0]:to[0];
    const fx=2+fci*cs, fy=2+fri*cs;
    const dx=(tci-fci)*cs, dy=(tri-fri)*cs;
    const boardEl=document.getElementById('chessBoard');
    const destCell=boardEl&&boardEl.querySelector('[data-row="'+to[0]+'"][data-col="'+to[1]+'"]');
    if (destCell) destCell.classList.add('anim-dest-hiding');
    const el=document.createElement('div');
    el.className='anim-piece-overlay';
    el.style.cssText='position:absolute;left:'+fx+'px;top:'+fy+'px;width:'+cs+'px;height:'+cs+'px;display:flex;align-items:center;justify-content:center;pointer-events:none;z-index:30;';
    el.appendChild(createGamePieceEl(piece));
    container.appendChild(el);
    let done=false;
    function finish(){
        if(done) return; done=true;
        el.remove();
        if(destCell) destCell.classList.remove('anim-dest-hiding');
        if(onDone) onDone();
    }
    el.addEventListener('transitionend',finish,{once:true});
    setTimeout(finish,250);
    requestAnimationFrame(()=>requestAnimationFrame(()=>{
        el.style.transition='transform 0.13s ease';
        el.style.transform='translate('+dx+'px,'+dy+'px)';
    }));
}

function execMove(from, to, promo, skipAnimation) {
    const piece=gs.board[from[0]][from[1]];
    const capturedPiece = gs.board[to[0]][to[1]];
    clearAnnotations();
    const notation=toNotation(gs.board,from,to,gs.ep,promo);
    const nb=applyMove(gs.board,from,to,gs.ep,gs.castling,promo);
    const nc=newCastling(gs.castling,from,gs.board);
    const ne=newEP(gs.board,from,to);
    gs.history.push({board:gs.board,castling:gs.castling,ep:gs.ep,notation,from:[...from],to:[...to]});
    gs.redoStack=[];
    gs.board=nb; gs.castling=nc; gs.ep=ne;
    gs.lastFrom=[...from]; gs.lastTo=[...to];
    gs.curseMode=false;
    gs.turn=opp(gs.turn); gs.selected=null; gs.selMoves=[];
    // Clear Lantern immobility once the immobilized team moves
    if (gs.lanternImmobileFor===opp(gs.turn)) { gs.lanternImmobile=[]; gs.lanternImmobileFor=null; }

    // Trigger voiceline on capture
    if (capturedPiece && currentBot) {
        const grade = pieceGrade(tp(capturedPiece));
        if (grade < 3) {
            const botJustCaptured = (opp(gs.turn) === gs.aiColor);
            var lines;
            if (botJustCaptured) {
                lines = grade===0 ? currentBot.g0TakeLines : grade===1 ? currentBot.g1TakeLines : currentBot.g2TakeLines;
            } else {
                lines = grade===0 ? currentBot.g0CaptureLines : grade===1 ? currentBot.g1CaptureLines : currentBot.g2CaptureLines;
            }
            setTimeout(function() { showBotVoiceline(randomFrom(lines)); }, 300);
        }
    }

    // Beast Handler ability: track moves per handler, spawn beasts every 5 moves
    if (gs.bhCounts && tp(piece)==='a') {
        const fromKey=from[0]+','+from[1], toKey=to[0]+','+to[1];
        const cnt=(gs.bhCounts[fromKey]||0)+1;
        delete gs.bhCounts[fromKey]; gs.bhCounts[toKey]=cnt;
        if (cnt%5===0) {
            const beastChar=isW(piece)?'V':'v';
            for (const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) {
                const br=to[0]+dr, bc=to[1]+dc;
                if (inB(br,bc)&&!gs.board[br][bc]) { gs.board[br][bc]=beastChar; gs.beasts.push([br,bc]); }
            }
            gs.beastExpiry=gs.history.length+4;
        }
    }
    // Beast position tracking: keep gs.beasts in sync when a beast moves
    if (tp(piece)==='v' && gs.beasts) {
        const bIdx=gs.beasts.findIndex(([br,bc])=>br===from[0]&&bc===from[1]);
        if (bIdx>=0) gs.beasts[bIdx]=[to[0],to[1]];
    }
    // Remove expired beasts after opponent's move
    if (gs.beasts&&gs.beasts.length>0&&gs.beastExpiry>=0&&gs.history.length>=gs.beastExpiry) {
        gs.beasts.forEach(([br,bc])=>{ if(gs.board[br][bc]&&tp(gs.board[br][bc])==='v') gs.board[br][bc]=null; });
        gs.beasts=[]; gs.beastExpiry=-1;
    }
    // Choir: increment move counter so it switches between + and diagonal
    if (tp(piece)==='ch') {
        const fromKey=from[0]+','+from[1], toKey=to[0]+','+to[1];
        const cnt=(gs.choirCounts[fromKey]||0)+1;
        delete gs.choirCounts[fromKey]; gs.choirCounts[toKey]=cnt;
    }
    // Husk: gain +1 range for each capture
    if (tp(piece)==='hk' && capturedPiece) {
        if (!gs.huskCaptures) gs.huskCaptures={w:0,b:0};
        gs.huskCaptures[col(piece)]=(gs.huskCaptures[col(piece)]||0)+1;
    }
    // Hydra: capture reversal — losing a head sends both pieces back, turn is still consumed
    let hydraCaptureLoss=false;
    if (capturedPiece && tp(capturedPiece)==='hy') {
        if (!gs.hydraHeads) gs.hydraHeads={w:3,b:3};
        const hc=col(capturedPiece), heads=gs.hydraHeads[hc]||3;
        if (heads>0) {
            gs.hydraHeads[hc]=heads-1;
            gs.board[from[0]][from[1]]=piece;
            gs.board[to[0]][to[1]]=capturedPiece;
            hydraCaptureLoss=true;
        }
    }
    // Hydra: in-check head loss (one head per move that puts Hydra in check, skip if capture already cost one)
    if (!hydraCaptureLoss) {
        for (let ri=0;ri<8;ri++) for (let ci2=0;ci2<8;ci2++) {
            const hp=gs.board[ri][ci2];
            if (hp&&col(hp)===gs.turn&&tp(hp)==='hy'&&isAttacked(gs.board,ri,ci2,opp(gs.turn))) {
                if (!gs.hydraHeads) gs.hydraHeads={w:3,b:3};
                gs.hydraHeads[gs.turn]=Math.max(0,(gs.hydraHeads[gs.turn]||3)-1);
            }
        }
    }
    // Library: record last captured enemy piece for each team (skip Hydra-reversed captures)
    if (capturedPiece && !hydraCaptureLoss) {
        if (!gs.libraryChar) gs.libraryChar={w:null,b:null};
        gs.libraryChar[col(piece)]=tp(capturedPiece);
    }
    // Lantern immobility: if Lantern captured something, immobilize adjacent squares for opponent's next turn
    if (tp(piece)==='m'&&capturedPiece&&col(capturedPiece)!==col(piece)) {
        gs.lanternImmobile=[];
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
            const ir=to[0]+dr, ic=to[1]+dc;
            if (inB(ir,ic)) gs.lanternImmobile.push([ir,ic]);
        }
        gs.lanternImmobileFor=gs.turn;
        showLanternEffect(to[0],to[1]);
    }
    // Oracle cursed tile: if any piece steps on the cursed tile, it is captured
    if (gs.oracleCursedTile) {
        const [cr,cc]=gs.oracleCursedTile;
        if (to[0]===cr&&to[1]===cc&&gs.board[cr][cc]) {
            gs.board[cr][cc]=null;
            gs.oracleCursedTile=null;
            showOracleCurseEffect(cr,cc);
        }
    }

    const nextMs=allLegal(gs.board,gs.castling,gs.ep,gs.turn);
    if (!nextMs.length) {
        const isInChk=inCheck(gs.board,gs.turn);
        // Hydra: checkmate does not mean end game while heads remain — skip turn instead
        let hydraSkip=false;
        if (isInChk) {
            for (let ri=0;ri<8;ri++) for (let ci2=0;ci2<8;ci2++) {
                const hp=gs.board[ri][ci2];
                if (hp&&col(hp)===gs.turn&&tp(hp)==='hy') {
                    const hh=(gs.hydraHeads&&gs.hydraHeads[gs.turn])||0;
                    if (hh>0) { gs.hydraHeads[gs.turn]=hh-1; hydraSkip=true; }
                }
            }
        }
        if (!hydraSkip) {
            gs.gameOver=true;
            gs.result=isInChk
                ?(opp(gs.turn)==='w'?'White wins by checkmate!':'Black wins by checkmate!')
                :'Draw by stalemate!';
            if (isInChk) triggerCheckmateEffect();
            if (currentBot&&isInChk) {
                const botWon=opp(gs.turn)===gs.aiColor;
                if (!botWon && !gs.localPlay) awardKP('bot_win');
                setTimeout(function(){ showBotVoiceline(randomFrom(botWon?currentBot.winLines:currentBot.loseLines)); }, 800);
            }
        } else {
            // Hydra survived checkmate — pass the turn back to the opponent
            gs.turn=opp(gs.turn);
        }
    }
    if (gs.gameOver) playSound('game_end');
    else if (inCheck(gs.board,gs.turn)) playSound('check');
    else if (notation.includes('x')&&!hydraCaptureLoss) playSound('take');
    else playSound('move');
    const aiTurn=!gs.gameOver&&gs.turn===gs.aiColor;
    render();
    if (gs.gameOver) clearGameState(); else if (!gs.localPlay) saveGameState();
    if (!skipAnimation) doAnimateMove(from,to,piece,aiTurn?()=>setTimeout(doAI,300):()=>renderStatus());
    else if (aiTurn) setTimeout(doAI,300); else renderStatus();
}

function showLanternEffect(row, c) {
    const boardEl=document.getElementById('chessBoard'); if(!boardEl) return;
    const cell=boardEl.querySelector('[data-row="'+row+'"][data-col="'+c+'"]'); if(!cell) return;
    const flash=document.createElement('div'); flash.className='lantern-flash-effect';
    cell.style.position='relative'; cell.appendChild(flash);
    flash.addEventListener('animationend',()=>flash.remove(),{once:true});
}
function showOracleCurseEffect(row, c) {
    const boardEl=document.getElementById('chessBoard'); if(!boardEl) return;
    const cell=boardEl.querySelector('[data-row="'+row+'"][data-col="'+c+'"]'); if(!cell) return;
    const flash=document.createElement('div'); flash.className='oracle-curse-trigger-effect';
    cell.style.position='relative'; cell.appendChild(flash);
    flash.addEventListener('animationend',()=>flash.remove(),{once:true});
}
function awardKP(reason) {
    var fd = new FormData();
    fd.append('reason', reason);
    fetch(CTX + '/awardKP', {method:'POST', body:fd}).catch(function(){});
}

function triggerCheckmateEffect() {
    const boardEl=document.getElementById('chessBoard'); if(!boardEl) return;
    boardEl.classList.add('board-shake');
    boardEl.addEventListener('animationend',()=>boardEl.classList.remove('board-shake'),{once:true});
    setTimeout(()=>{
        const king=boardEl.querySelector('.in-check'); if(!king) return;
        king.classList.add('king-defeated');
    },40);
}
function renderCursePanel() {
    const panel=document.getElementById('cursePanel'); if(!panel) return;
    if (!gs||!gs.board||gs.gameOver||!gs.selected) { panel.style.display='none'; return; }
    const sp=gs.board[gs.selected[0]][gs.selected[1]];
    if (!sp||tp(sp)!=='u') { panel.style.display='none'; return; }
    const oc=col(sp);
    if (gs.oracleHasCursed&&gs.oracleHasCursed[oc]) { panel.style.display='none'; return; }
    panel.style.display='block';
    const btn=document.getElementById('curseBtn'); if(!btn) return;
    btn.textContent=gs.curseMode?'Cancel Curse':'Curse a Tile';
    btn.className='btn '+(gs.curseMode?'btn-outline':'btn-danger')+' curse-btn';
}
function toggleCurseMode() {
    if (!gs||!gs.selected) return;
    gs.curseMode=!gs.curseMode;
    renderBoard(); renderCursePanel();
}
function execCurse(targetRow, targetCol) {
    if (!gs||!gs.board||gs.gameOver||!gs.selected) return;
    const oracle=gs.board[gs.selected[0]][gs.selected[1]];
    if (!oracle||tp(oracle)!=='u') return;
    const oracleColor=col(oracle);
    if (gs.oracleHasCursed[oracleColor]) return;
    if (gs.board[targetRow][targetCol]) return;
    gs.oracleCursedTile=[targetRow,targetCol];
    gs.oracleHasCursed[oracleColor]=true;
    gs.selected=null; gs.selMoves=[]; gs.curseMode=false;
    gs.turn=opp(gs.turn);
    const nextMs=allLegal(gs.board,gs.castling,gs.ep,gs.turn);
    if (!nextMs.length) {
        gs.gameOver=true;
        gs.result=inCheck(gs.board,gs.turn)?(opp(gs.turn)==='w'?'White wins by checkmate!':'Black wins by checkmate!'):'Draw by stalemate!';
        playSound('game_end');
    }
    if (!gs.localPlay) saveGameState();
    render();
    if (!gs.gameOver&&gs.turn===gs.aiColor) setTimeout(doAI,300);
}

function render() { renderBoard(); renderMoveList(); renderStatus(); renderOverlay(); renderCursePanel(); }

function renderBoard() {
    if (!gs.board) return;
    const el=document.getElementById('chessBoard');
    el.innerHTML='';
    const flip=!gs.localPlay&&gs.playerColor==='b';
    const activeColor=gs.localPlay?gs.turn:gs.playerColor;
    const dragMoves=(isDragging&&pointerStart&&gs.board&&gs.turn===activeColor)
        ?legalMoves(gs.board,pointerStart.row,pointerStart.col,gs.castling,gs.ep,gs.turn):[];
    for (let ri=0;ri<8;ri++) for (let ci=0;ci<8;ci++) {
        const row=flip?7-ri:ri, c=flip?7-ci:ci;
        const cell=document.createElement('div');
        const light=(row+c)%2===0;
        cell.className='cell '+(light?'light':'dark');
        cell.dataset.row=row; cell.dataset.col=c;
        if (gs.lastFrom&&gs.lastTo&&((row===gs.lastFrom[0]&&c===gs.lastFrom[1])||(row===gs.lastTo[0]&&c===gs.lastTo[1])))
            cell.classList.add('last-move');
        if (gs.selected&&gs.selected[0]===row&&gs.selected[1]===c) cell.classList.add('selected');
        if (isDragging&&pointerStart&&row===pointerStart.row&&c===pointerStart.col) cell.classList.add('dragging-from');
        const isDragLegal=isDragging&&pointerStart&&dragMoves.some(([lr,lc])=>lr===row&&lc===c);
        const isLegal=gs.selMoves.some(([lr,lc])=>lr===row&&lc===c)||isDragLegal;
        if (gs.curseMode&&!gs.board[row][c]) cell.classList.add('curse-valid');
        if (isLegal) cell.classList.add(gs.board[row][c]?'legal-capture':'legal-move');
        if (gs.lanternImmobileFor===gs.turn&&gs.lanternImmobile&&gs.lanternImmobile.some(([ir,ic])=>ir===row&&ic===c)&&gs.board[row][c]) cell.classList.add('lantern-immobilized');
        const p=gs.board[row][c];
        if (p&&pieceGrade(tp(p))===3&&inCheck(gs.board,col(p))) cell.classList.add('in-check');
        if (p) cell.appendChild(createGamePieceEl(p));
        if (gs.oracleCursedTile&&gs.oracleCursedTile[0]===row&&gs.oracleCursedTile[1]===c) {
            cell.classList.add('oracle-cursed');
            const skull=document.createElement('span'); skull.className='curse-marker'; skull.textContent='☠'; cell.appendChild(skull);
        }
        if ((!flip&&ci===0)||(flip&&ci===7)) {
            const lbl=document.createElement('span');
            lbl.className='coord-rank'; lbl.textContent=8-row; cell.appendChild(lbl);
        }
        if ((!flip&&ri===7)||(flip&&ri===0)) {
            const lbl=document.createElement('span');
            lbl.className='coord-file'; lbl.textContent=FILES[c]; cell.appendChild(lbl);
        }
        el.appendChild(cell);
    }
}

function renderMoveList() {
    const tbl=document.getElementById('moveList');
    tbl.innerHTML='';
    for (let i=0;i<gs.history.length;i+=2) {
        const tr=document.createElement('tr');
        const nd=document.createElement('td'); nd.className='move-num'; nd.textContent=(i/2+1)+'.'; tr.appendChild(nd);
        const wd=document.createElement('td'); wd.className='move-item'; wd.textContent=gs.history[i].notation; tr.appendChild(wd);
        const bd=document.createElement('td'); bd.className='move-item';
        if (gs.history[i+1]) bd.textContent=gs.history[i+1].notation;
        tr.appendChild(bd); tbl.appendChild(tr);
    }
    const h=document.getElementById('moveHistory'); h.scrollTop=h.scrollHeight;
}

function renderStatus() {
    const el=document.getElementById('statusBox');
    if (!gs.board) { el.textContent=LOCAL_PLAY?'Local play — White to move.':'Pick a bot to start.'; return; }
    if (gs.gameOver) { el.innerHTML='<strong>'+gs.result+'</strong>'; return; }
    if (gs.aiThinking) { el.innerHTML=(currentBot?currentBot.name+' is thinking...':'AI is thinking...'); return; }
    const chk=inCheck(gs.board,gs.turn);
    const who=gs.turn==='w'?'White':'Black';
    el.innerHTML=chk
        ?'<strong style="color:#e86161">'+who+' is in check!</strong>'
        :'<strong>'+who+'</strong> to move';
}

function renderOverlay() {
    const ov=document.getElementById('gameOverlay');
    if (gs.gameOver) {
        document.getElementById('gameOverMsg').textContent=gs.result;
        ov.style.display='flex';
    } else { ov.style.display='none'; }
}

function sqCenter(row, c) {
    const flip=gs.playerColor==='b';
    const ci=flip?7-c:c, ri=flip?7-row:row;
    return {x:ci*SVG_CELL+SVG_CELL/2, y:ri*SVG_CELL+SVG_CELL/2};
}

function renderArrows() {
    const svg=document.getElementById('arrowSVG');
    if (!svg) return;
    svg.innerHTML='';
    if (!arrows.length&&!highlights.length) return;
    const NS='http://www.w3.org/2000/svg';
    const SHAFT_W=20, HEAD_W=46, HEAD_LEN=30;
    highlights.forEach(([row,c])=>{
        const {x,y}=sqCenter(row,c);
        const isLight=(row+c)%2===0;
        const color=isLight?'rgba(235,97,80,0.72)':'rgba(176,41,22,0.82)';
        const rect=document.createElementNS(NS,'rect');
        rect.setAttribute('x',x-SVG_CELL/2); rect.setAttribute('y',y-SVG_CELL/2);
        rect.setAttribute('width',SVG_CELL); rect.setAttribute('height',SVG_CELL);
        rect.setAttribute('fill',color);
        svg.appendChild(rect);
    });
    arrows.forEach(({from,to})=>{
        const dr=Math.abs(to[0]-from[0]), dc=Math.abs(to[1]-from[1]);
        const a=sqCenter(from[0],from[1]), b=sqCenter(to[0],to[1]);
        if ((dr===2&&dc===1)||(dr===1&&dc===2)) {
            const corner=dr===2?{x:a.x,y:b.y}:{x:b.x,y:a.y};
            const dx1=corner.x-a.x,dy1=corner.y-a.y,len1=Math.sqrt(dx1*dx1+dy1*dy1);
            const u1x=dx1/len1,u1y=dy1/len1;
            const n1x=-u1y,n1y=u1x;
            const dx2=b.x-corner.x,dy2=b.y-corner.y,len2=Math.sqrt(dx2*dx2+dy2*dy2);
            const u2x=dx2/len2,u2y=dy2/len2;
            const n2x=-u2y,n2y=u2x;
            const w=SHAFT_W/2;
            const sx=a.x+u1x*22,sy=a.y+u1y*22;
            const tx=b.x-u2x*10,ty=b.y-u2y*10;
            const hbx=tx-u2x*HEAD_LEN,hby=ty-u2y*HEAD_LEN;
            const ex=corner.x+u1x*w,ey=corner.y+u1y*w;
            const pts1=[
                [sx+n1x*w,sy+n1y*w],
                [ex+n1x*w,ey+n1y*w],
                [ex-n1x*w,ey-n1y*w],
                [sx-n1x*w,sy-n1y*w],
            ].map(p=>p[0].toFixed(1)+','+p[1].toFixed(1)).join(' ');
            const leg1=document.createElementNS(NS,'polygon');
            leg1.setAttribute('points',pts1);
            leg1.setAttribute('fill','rgba(255,170,0,0.85)');
            svg.appendChild(leg1);
            const sx2=corner.x+u2x*w,sy2=corner.y+u2y*w;
            const pts2=[
                [sx2+n2x*w,sy2+n2y*w],
                [hbx+n2x*w,hby+n2y*w],
                [hbx+n2x*HEAD_W/2,hby+n2y*HEAD_W/2],
                [tx,ty],
                [hbx-n2x*HEAD_W/2,hby-n2y*HEAD_W/2],
                [hbx-n2x*w,hby-n2y*w],
                [sx2-n2x*w,sy2-n2y*w],
            ].map(p=>p[0].toFixed(1)+','+p[1].toFixed(1)).join(' ');
            const leg2=document.createElementNS(NS,'polygon');
            leg2.setAttribute('points',pts2);
            leg2.setAttribute('fill','rgba(255,170,0,0.85)');
            svg.appendChild(leg2);
        } else {
            const dx=b.x-a.x, dy=b.y-a.y, len=Math.sqrt(dx*dx+dy*dy);
            if (len<2) return;
            const ux=dx/len, uy=dy/len, nx=-uy, ny=ux;
            const sx=a.x+ux*22, sy=a.y+uy*22;
            const tx=b.x-ux*10, ty=b.y-uy*10;
            const hbx=tx-ux*HEAD_LEN, hby=ty-uy*HEAD_LEN;
            const pts=[
                [sx+nx*SHAFT_W/2, sy+ny*SHAFT_W/2],
                [hbx+nx*SHAFT_W/2, hby+ny*SHAFT_W/2],
                [hbx+nx*HEAD_W/2, hby+ny*HEAD_W/2],
                [tx, ty],
                [hbx-nx*HEAD_W/2, hby-ny*HEAD_W/2],
                [hbx-nx*SHAFT_W/2, hby-ny*SHAFT_W/2],
                [sx-nx*SHAFT_W/2, sy-ny*SHAFT_W/2],
            ].map(p=>p[0].toFixed(1)+','+p[1].toFixed(1)).join(' ');
            const poly=document.createElementNS(NS,'polygon');
            poly.setAttribute('points',pts);
            poly.setAttribute('fill','rgba(255,170,0,0.85)');
            svg.appendChild(poly);
        }
    });
}

function clearAnnotations() {
    arrows=[]; highlights=[];
    const svg=document.getElementById('arrowSVG');
    if (svg) svg.innerHTML='';
}

function onCell2(row, c) {
    if (gs.gameOver||gs.aiThinking||!gs.board) return;
    if (!gs.localPlay&&gs.turn!==gs.playerColor) return;
    if (gs.curseMode) {
        if (!gs.board[row][c]) { execCurse(row,c); } else { gs.curseMode=false; renderBoard(); renderCursePanel(); }
        return;
    }
    const activeColor=gs.localPlay?gs.turn:gs.playerColor;
    const p=gs.board[row][c];
    if (gs.selected) {
        const legal=gs.selMoves.some(([lr,lc])=>lr===row&&lc===c);
        if (legal) {
            const mp=gs.board[gs.selected[0]][gs.selected[1]];
            if (tp(mp)==='p'&&(row===0||row===7)){gs.pendingPromo={from:[...gs.selected],to:[row,c]};showPromo();return;}
            execMove(gs.selected,[row,c],null);
        } else if (p&&col(p)===activeColor) {
            gs.selected=[row,c]; gs.selMoves=legalMoves(gs.board,row,c,gs.castling,gs.ep,gs.turn); renderBoard();
        } else { gs.selected=null; gs.selMoves=[]; renderBoard(); }
    } else if (p&&col(p)===activeColor) {
        gs.selected=[row,c]; gs.selMoves=legalMoves(gs.board,row,c,gs.castling,gs.ep,gs.turn); renderBoard();
    }
}

function onCellDrop(fromRow, fromCol, toRow, toCol) {
    if (gs.gameOver||gs.aiThinking||!gs.board) return;
    if (!gs.localPlay&&gs.turn!==gs.playerColor) return;
    const mp=gs.board[fromRow][fromCol];
    const activeColor=gs.localPlay?gs.turn:gs.playerColor;
    if (!mp||col(mp)!==activeColor) return;
    const legal=legalMoves(gs.board,fromRow,fromCol,gs.castling,gs.ep,gs.turn);
    if (legal.some(([lr,lc])=>lr===toRow&&lc===toCol)) {
        gs.selected=null; gs.selMoves=[];
        if (tp(mp)==='p'&&(toRow===0||toRow===7)){
            gs.pendingPromo={from:[fromRow,fromCol],to:[toRow,toCol]};
            showPromo();
        } else { execMove([fromRow,fromCol],[toRow,toCol],null,true); }
    } else { gs.selected=null; gs.selMoves=[]; renderBoard(); }
}

function showPromo() {
    const c=gs.playerColor;
    const modal=document.getElementById('promotionModal');
    const opts=document.getElementById('promoOptions');
    opts.innerHTML='';
    for (const t of ['q','r','b','n']) {
        const btn=document.createElement('button');
        btn.className='promo-btn'; btn.appendChild(buildPieceSVG(t, c==='w'));
        btn.onclick=()=>{ modal.style.display='none'; execMove(gs.pendingPromo.from,gs.pendingPromo.to,t); gs.pendingPromo=null; };
        opts.appendChild(btn);
    }
    modal.style.display='flex';
}

// ── Bot picker modal ───────────────────────────────────────────────────────
function escHtml(s) {
    if (!s) return '';
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

function openBotPickerModal() {
    renderBotCollectionList();
    goPickerStep1();
    document.getElementById('botPickerModal').style.display = 'flex';
}
function closeBotPickerModal() {
    document.getElementById('botPickerModal').style.display = 'none';
}

function goPickerStep1() {
    document.getElementById('pickerStep1').style.display = '';
    document.getElementById('pickerStep2').style.display = 'none';
    selectedPickerBot = null;
}

function selectBotForGame(bot) {
    selectedPickerBot = bot;
    document.getElementById('pickerStep1').style.display = 'none';
    document.getElementById('pickerStep2').style.display = '';
    document.getElementById('pickerStep2Title').textContent = 'Play vs ' + bot.name;
    document.getElementById('step2Name').textContent = bot.name;
    document.getElementById('step2Elo').textContent = bot.elo + ' ELO';
    var av = document.getElementById('step2Avatar');
    if (bot.imagePath) {
        av.innerHTML = '<img src="' + CTX + '/' + bot.imagePath + '" style="width:100%;height:100%;object-fit:cover;border-radius:50%" alt="">';
    } else {
        av.innerHTML = '&#9816;';
    }
    document.getElementById('pickerWhite').checked = true;
}

function renderBotCollectionList() {
    var container = document.getElementById('botCollectionList');
    container.innerHTML = '';

    if (!ALL_BOTS || ALL_BOTS.length === 0) {
        container.innerHTML = '<div style="color:var(--text-muted);text-align:center;padding:28px 0">No bots available yet.</div>';
        return;
    }

    var grouped = {}, order = [];
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

        var summary = document.createElement('summary');
        summary.className = 'bot-collection-header';
        summary.innerHTML = '<span>' + escHtml(colName) + '</span><span style="color:var(--text-muted);font-size:13px;font-weight:400">' + bots.length + ' bot' + (bots.length !== 1 ? 's' : '') + '</span>';
        details.appendChild(summary);

        var body = document.createElement('div');
        body.className = 'bot-collection-body';

        bots.forEach(function(bot) {
            var card = document.createElement('div');
            card.className = 'bot-card';
            card.onclick = function() { selectBotForGame(bot); };

            var av = document.createElement('div');
            av.className = 'bot-card-avatar';
            if (bot.imagePath) {
                av.innerHTML = '<img src="' + CTX + '/' + bot.imagePath + '" style="width:100%;height:100%;object-fit:cover;border-radius:50%" alt="">';
            } else {
                av.innerHTML = '&#9816;';
            }

            var info = document.createElement('div');
            info.style.flex = '1';
            info.innerHTML = '<div style="font-weight:600">' + escHtml(bot.name) + '</div>' +
                             '<div style="color:var(--text-muted);font-size:13px">' + bot.elo + ' ELO</div>';

            var btn = document.createElement('button');
            btn.className = 'btn btn-green';
            btn.style.cssText = 'font-size:13px;padding:5px 14px';
            btn.textContent = 'Select';
            btn.onclick = function(e) { e.stopPropagation(); selectBotForGame(bot); };

            card.appendChild(av); card.appendChild(info); card.appendChild(btn);
            body.appendChild(card);
        });

        details.appendChild(body);
        container.appendChild(details);
    });
}

// ── Bot game persistence (localStorage) ─────────────────────────────────────
function _saveKey() {
    var u = CURRENT_USER || '_guest';
    return BOT_DATA ? 'gambitonline_botgame_' + u + '_' + BOT_DATA.id : null;
}

function saveGameState() {
    const key = _saveKey();
    if (!key || !gs.board || gs.localPlay || gs.gameOver) { clearGameState(); return; }
    try {
        const state = {
            board: gs.board, turn: gs.turn, castling: gs.castling, ep: gs.ep,
            history: gs.history, playerColor: gs.playerColor, aiColor: gs.aiColor,
            aiElo: gs.aiElo, aiPersonality: gs.aiPersonality,
            bhCounts: gs.bhCounts, beasts: gs.beasts, beastExpiry: gs.beastExpiry,
            choirCounts: gs.choirCounts, huskCaptures: gs.huskCaptures,
            hydraHeads: gs.hydraHeads, libraryChar: gs.libraryChar,
            lanternImmobile: gs.lanternImmobile, lanternImmobileFor: gs.lanternImmobileFor,
            oracleCursedTile: gs.oracleCursedTile, oracleHasCursed: gs.oracleHasCursed,
            lastFrom: gs.lastFrom, lastTo: gs.lastTo
        };
        localStorage.setItem(key, JSON.stringify(state));
    } catch(e) {}
}

function loadGameState() {
    const key = _saveKey();
    if (!key) return null;
    try {
        const raw = localStorage.getItem(key);
        return raw ? JSON.parse(raw) : null;
    } catch(e) { return null; }
}

function clearGameState() {
    const key = _saveKey();
    if (key) { try { localStorage.removeItem(key); } catch(e) {} }
}

function restoreGameState(saved) {
    gs = {
        board: saved.board, turn: saved.turn, castling: saved.castling, ep: saved.ep,
        history: saved.history || [], gameOver: false, result: '',
        playerColor: saved.playerColor, aiColor: saved.aiColor, aiElo: saved.aiElo,
        pendingPromo: null, lastFrom: saved.lastFrom, lastTo: saved.lastTo,
        aiThinking: false, aiPersonality: saved.aiPersonality,
        bhCounts: saved.bhCounts || {}, beasts: saved.beasts || [],
        beastExpiry: saved.beastExpiry !== undefined ? saved.beastExpiry : -1,
        choirCounts: saved.choirCounts || {},
        huskCaptures: saved.huskCaptures || {w:0,b:0},
        hydraHeads: saved.hydraHeads || {w:3,b:3},
        libraryChar: saved.libraryChar || {w:null,b:null},
        lanternImmobile: saved.lanternImmobile || [], lanternImmobileFor: saved.lanternImmobileFor || null,
        oracleCursedTile: saved.oracleCursedTile || null, oracleHasCursed: saved.oracleHasCursed || {w:false,b:false},
        curseMode: false, selMoves: [], selected: null, localPlay: false
    };
    currentBot = BOT_DATA;
    updatePlayerPanels();
    render();
    schedulePeriodicVoiceline();
    if (gs.turn === gs.aiColor) setTimeout(doAI, 1000);
}

document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('chessBoard').addEventListener('contextmenu', e => e.preventDefault());

    // ── Bot picker modal wiring ──────────────────────────────────────────────
    document.getElementById('botPickerModal').addEventListener('click', function(e) {
        if (e.target === this) closeBotPickerModal();
    });

    document.getElementById('startBotGameBtn').addEventListener('click', function() {
        if (!selectedPickerBot) return;
        var colorVal = document.querySelector('input[name="pickerColor"]:checked').value;
        if (colorVal === 'r') colorVal = Math.random() < 0.5 ? 'w' : 'b';
        var bot = selectedPickerBot;
        closeBotPickerModal();
        // Navigate to game with that bot's full data loaded, or start in-page
        // If BOT_DATA was already server-loaded for this bot, start directly
        // otherwise use the minimal picker data (no voicelines — redirect)
        if (bot.id && (!BOT_DATA || BOT_DATA.id !== bot.id)) {
            window.location.href = CTX + '/game?botId=' + bot.id + '#autostart=' + colorVal;
        } else {
            startGame(colorVal, bot.elo || 800, BOT_DATA || bot);
        }
    });

    document.getElementById('newGameBtn').addEventListener('click', function() {
        if (LOCAL_PLAY) { startGame('w', 0, null); } else { openBotPickerModal(); }
    });
    document.getElementById('newGameBtnOverlay').addEventListener('click', function() {
        document.getElementById('gameOverlay').style.display = 'none';
        if (LOCAL_PLAY) { startGame('w', 0, null); } else { openBotPickerModal(); }
    });
    document.getElementById('resignBtn').addEventListener('click', function() {
        if (!gs.board || gs.gameOver) return;
        gs.gameOver = true;
        gs.result = (gs.playerColor === 'w' ? 'Black' : 'White') + ' wins! (Resigned)';
        playSound('game_end');
        clearGameState();
        render();
    });

    // ── Move navigation (undo / redo) ─────────────────────────────────────────
    function undoMoves(count) {
        if (!gs.board || gs.history.length === 0) return;
        gs.aiThinking = false; // cancel any pending AI move
        for (var _i = 0; _i < count && gs.history.length > 0; _i++) {
            var entry = gs.history.pop();
            // Store current board in redo stack so it can be re-applied
            gs.redoStack.push({
                board: gs.board, castling: gs.castling, ep: gs.ep,
                notation: entry.notation, from: entry.from, to: entry.to
            });
            gs.board     = entry.board;
            gs.castling  = entry.castling;
            gs.ep        = entry.ep;
            gs.turn      = opp(gs.turn);
        }
        gs.gameOver = false; gs.result = '';
        gs.pendingPromo = null; gs.selected = null; gs.selMoves = [];
        if (gs.history.length > 0) {
            var lh = gs.history[gs.history.length - 1];
            gs.lastFrom = lh.from; gs.lastTo = lh.to;
        } else { gs.lastFrom = null; gs.lastTo = null; }
        render(); renderStatus();
    }

    function redoMoves(count) {
        if (!gs.redoStack || gs.redoStack.length === 0) return;
        for (var _j = 0; _j < count && gs.redoStack.length > 0; _j++) {
            var fwd = gs.redoStack.pop();
            gs.history.push({
                board: gs.board, castling: gs.castling, ep: gs.ep,
                notation: fwd.notation, from: fwd.from, to: fwd.to
            });
            gs.board    = fwd.board;
            gs.castling = fwd.castling;
            gs.ep       = fwd.ep;
            gs.turn     = opp(gs.turn);
            gs.lastFrom = fwd.from; gs.lastTo = fwd.to;
        }
        gs.gameOver = false; gs.result = '';
        gs.pendingPromo = null; gs.selected = null; gs.selMoves = [];
        render(); renderStatus();
    }

    document.getElementById('btnFirst').addEventListener('click', function() {
        undoMoves(gs.history.length);
    });
    document.getElementById('btnPrev').addEventListener('click', function() {
        if (!gs.board || gs.history.length === 0) return;
        // In bot games, undo 2 (bot's reply + player's move) when it's the player's turn
        var count = 1;
        if (!gs.localPlay && gs.aiColor && gs.turn === gs.playerColor && gs.history.length >= 2) {
            count = 2;
        }
        undoMoves(count);
    });
    document.getElementById('btnNext').addEventListener('click', function() {
        if (!gs.redoStack || gs.redoStack.length === 0) return;
        var count = 1;
        if (!gs.localPlay && gs.aiColor && gs.redoStack.length >= 2) {
            count = 2; // redo both player and bot move together
        }
        redoMoves(count);
    });
    document.getElementById('btnLast').addEventListener('click', function() {
        redoMoves(gs.redoStack ? gs.redoStack.length : 0);
    });

    // ── Drag & drop ──────────────────────────────────────────────────────────
    document.addEventListener('mousedown', function(e) {
        if (e.button===2) {
            const cell=e.target.closest('#chessBoard .cell');
            if (cell) rightDragStart=[parseInt(cell.dataset.row),parseInt(cell.dataset.col)];
            return;
        }
        if (e.button!==0) return;
        const cell=e.target.closest('#chessBoard .cell');
        if (!cell) return;
        clearAnnotations();
        const row=parseInt(cell.dataset.row), c=parseInt(cell.dataset.col);
        if (!gs.board) return;
        const p=gs.board[row][c];
        const dragColor=gs.localPlay?gs.turn:gs.playerColor;
        if (!p||col(p)!==dragColor||gs.gameOver||gs.aiThinking||gs.turn!==dragColor) return;
        pointerStart={row,col:c,x:e.clientX,y:e.clientY,hasDragged:false,ghost:null};
    });

    document.addEventListener('mousemove', function(e) {
        if (!pointerStart) return;
        const dx=e.clientX-pointerStart.x, dy=e.clientY-pointerStart.y;
        if (!pointerStart.hasDragged&&Math.sqrt(dx*dx+dy*dy)>DRAG_THRESHOLD) {
            pointerStart.hasDragged=true; isDragging=true;
            const ghost=document.createElement('div');
            ghost.className='drag-ghost';
            ghost.appendChild(createGamePieceEl(gs.board[pointerStart.row][pointerStart.col]));
            ghost.style.left=e.clientX+'px';
            ghost.style.top=e.clientY+'px';
            document.body.appendChild(ghost); pointerStart.ghost=ghost;
            renderBoard();
        }
        if (pointerStart.hasDragged&&pointerStart.ghost) {
            pointerStart.ghost.style.left=e.clientX+'px';
            pointerStart.ghost.style.top=e.clientY+'px';
        }
    });

    document.addEventListener('mouseup', function(e) {
        if (e.button===2) {
            if (rightDragStart) {
                const el=document.elementFromPoint(e.clientX,e.clientY);
                const cell=el&&el.closest('#chessBoard .cell');
                if (cell) {
                    const r=parseInt(cell.dataset.row), c2=parseInt(cell.dataset.col);
                    const [sr,sc]=rightDragStart;
                    if (r===sr&&c2===sc) {
                        const idx=highlights.findIndex(([hr,hc])=>hr===r&&hc===c2);
                        if (idx>=0) highlights.splice(idx,1); else highlights.push([r,c2]);
                    } else {
                        const idx=arrows.findIndex(a=>a.from[0]===sr&&a.from[1]===sc&&a.to[0]===r&&a.to[1]===c2);
                        if (idx>=0) arrows.splice(idx,1); else arrows.push({from:[sr,sc],to:[r,c2]});
                    }
                    renderArrows();
                }
            }
            rightDragStart=null; return;
        }
        if (e.button!==0) return;
        if (!pointerStart) {
            const el2=document.elementFromPoint(e.clientX,e.clientY);
            const cell2=el2&&el2.closest('#chessBoard .cell');
            if (cell2&&gs.selected) onCell2(parseInt(cell2.dataset.row),parseInt(cell2.dataset.col));
            return;
        }
        if (pointerStart.ghost){pointerStart.ghost.remove();pointerStart.ghost=null;}
        isDragging=false;
        if (pointerStart.hasDragged) {
            const el=document.elementFromPoint(e.clientX,e.clientY);
            const cell=el&&el.closest('#chessBoard .cell');
            if (cell) {
                onCellDrop(pointerStart.row,pointerStart.col,parseInt(cell.dataset.row),parseInt(cell.dataset.col));
            } else { gs.selected=null; gs.selMoves=[]; renderBoard(); }
        } else { onCell2(pointerStart.row,pointerStart.col); }
        pointerStart=null;
    });

    // ── Touch support: tap-to-select + long-press-drag ──────────────────────
    // touchInfo tracks the ongoing touch gesture
    var touchInfo = null; // { row, col, x, y, piece, timer, dragging, ghost }
    var LONG_PRESS_MS = 280;

    var boardEl2 = document.getElementById('chessBoard');

    boardEl2.addEventListener('touchstart', function(e) {
        if (!gs.board || gs.gameOver || gs.aiThinking) return;
        if (!gs.localPlay && gs.turn !== gs.playerColor) return;
        if (e.touches.length !== 1) return;

        // Cancel any in-progress gesture
        if (touchInfo) {
            if (touchInfo.timer) clearTimeout(touchInfo.timer);
            if (touchInfo.ghost) { touchInfo.ghost.remove(); }
            isDragging = false; pointerStart = null;
            touchInfo = null;
        }

        const t = e.touches[0];
        const el = document.elementFromPoint(t.clientX, t.clientY);
        const cell = el && el.closest('#chessBoard .cell');
        if (!cell) return;

        const row = parseInt(cell.dataset.row);
        const c2  = parseInt(cell.dataset.col);
        const activeColor = gs.localPlay ? gs.turn : gs.playerColor;
        const p = gs.board[row][c2];
        const isOwnPiece = p && col(p) === activeColor;

        var timer = null;
        if (isOwnPiece) {
            timer = setTimeout(function() {
                if (!touchInfo) return;
                touchInfo.dragging = true;
                touchInfo.timer = null;

                if (navigator.vibrate) navigator.vibrate(25);

                const ghost = document.createElement('div');
                ghost.className = 'drag-ghost';
                ghost.appendChild(createGamePieceEl(p));
                ghost.style.left = touchInfo.x + 'px';
                ghost.style.top  = touchInfo.y + 'px';
                document.body.appendChild(ghost);
                touchInfo.ghost = ghost;

                // Wire into the mouse-drag render infrastructure
                isDragging = true;
                pointerStart = { row: touchInfo.row, col: touchInfo.col,
                                 x: touchInfo.x, y: touchInfo.y,
                                 hasDragged: true, ghost: ghost };
                gs.selected = [touchInfo.row, touchInfo.col];
                gs.selMoves = legalMoves(gs.board, touchInfo.row, touchInfo.col,
                                         gs.castling, gs.ep, gs.turn);
                renderBoard();
            }, LONG_PRESS_MS);
        }

        touchInfo = { row, col: c2, x: t.clientX, y: t.clientY,
                      piece: p, timer, dragging: false, ghost: null };
    }, { passive: true });

    boardEl2.addEventListener('touchmove', function(e) {
        if (!touchInfo) return;
        const t = e.touches[0];
        const dx = t.clientX - touchInfo.x;
        const dy = t.clientY - touchInfo.y;

        if (touchInfo.dragging) {
            e.preventDefault(); // prevent scroll while dragging
            if (touchInfo.ghost) {
                touchInfo.ghost.style.left = t.clientX + 'px';
                touchInfo.ghost.style.top  = t.clientY + 'px';
            }
            if (pointerStart) { pointerStart.x = t.clientX; pointerStart.y = t.clientY; }
        } else if (touchInfo.timer && Math.sqrt(dx*dx + dy*dy) > 10) {
            // Scrolling — cancel long-press
            clearTimeout(touchInfo.timer);
            touchInfo.timer = null;
        }
    }, { passive: false });

    function endTouch(e) {
        if (!touchInfo) return;
        if (touchInfo.timer) { clearTimeout(touchInfo.timer); touchInfo.timer = null; }

        if (touchInfo.dragging) {
            // Drag ended — find target cell (ghost has pointer-events:none so elementFromPoint sees through it)
            const t = e.changedTouches && e.changedTouches[0];
            const targetEl = t ? document.elementFromPoint(t.clientX, t.clientY) : null;
            const targetCell = targetEl && targetEl.closest('#chessBoard .cell');

            if (touchInfo.ghost) { touchInfo.ghost.remove(); touchInfo.ghost = null; }
            isDragging = false;
            pointerStart = null;

            if (targetCell) {
                onCellDrop(touchInfo.row, touchInfo.col,
                           parseInt(targetCell.dataset.row), parseInt(targetCell.dataset.col));
            } else {
                gs.selected = null; gs.selMoves = [];
                renderBoard();
            }
        } else {
            // Tap — existing select/move logic
            const t = e.changedTouches && e.changedTouches[0];
            if (t) {
                const dx = t.clientX - touchInfo.x, dy = t.clientY - touchInfo.y;
                if (Math.sqrt(dx*dx + dy*dy) < 14) {
                    const el = document.elementFromPoint(t.clientX, t.clientY);
                    const cell = el && el.closest('#chessBoard .cell');
                    if (cell) onCell2(parseInt(cell.dataset.row), parseInt(cell.dataset.col));
                }
            }
        }
        touchInfo = null;
    }

    boardEl2.addEventListener('touchend',    endTouch, { passive: false });
    boardEl2.addEventListener('touchcancel', endTouch, { passive: false });

    // ── Auto-start ────────────────────────────────────────────────────────────
    if (LOCAL_PLAY) {
        startGame('w', 0, null);
    } else {
        var hash = window.location.hash;
        var autoColor = 'w';
        if (hash && hash.indexOf('autostart=') !== -1) {
            autoColor = hash.split('autostart=')[1].charAt(0);
            if (autoColor !== 'w' && autoColor !== 'b') autoColor = 'w';
        }
        if (BOT_DATA && BOT_DATA !== null) {
            var saved = loadGameState();
            if (saved) {
                if (confirm('You have a saved game in progress with ' + BOT_DATA.name + '. Continue?')) {
                    restoreGameState(saved);
                } else {
                    clearGameState();
                    startGame(autoColor, BOT_DATA.elo || 800, BOT_DATA);
                }
            } else {
                // Start directly — no need to show the modal again
                startGame(autoColor, BOT_DATA.elo || 800, BOT_DATA);
            }
        } else {
            openBotPickerModal();
        }
    }

    // Render empty board on start
    renderStatus();
});

})();
</script>
</main>
</div>
<%@ include file="_bot-picker.jsp" %>
</body>
</html>
