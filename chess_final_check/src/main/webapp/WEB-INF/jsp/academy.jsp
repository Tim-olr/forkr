<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.game.pieces.PieceDefinition, timolr.chess.game.pieces.PieceRegistry, java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Academy - Forkr</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Newsreader:ital,opsz,wght@0,6..72,300..700;1,6..72,300..700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/forkr.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
    <style>body{background:var(--bg)!important;overflow:hidden}</style>
    <script src="${pageContext.request.contextPath}/js/piece-art.js"></script>
    <style>
    .academy-page { max-width: 1200px; margin: 0 auto; padding: 32px 16px; }
    .academy-header { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 28px; }
    .academy-title { font-size: 1.7rem; font-weight: 700; }
    .academy-kp-badge {
        display: flex; align-items: center; gap: 8px;
        background: var(--surface); border: 1px solid var(--border); border-radius: 10px;
        padding: 8px 18px; font-size: 15px; font-weight: 600;
    }
    .kp-icon { font-size: 20px; }
    .academy-desc { color: var(--text-muted); font-size: 14px; margin-bottom: 24px; max-width: 680px; }
    .tree-wrap {
        overflow: auto;
        scrollbar-width: none; -ms-overflow-style: none;
        background: var(--surface); border: 1px solid var(--border); border-radius: 12px;
        padding: 24px; min-height: 500px; position: relative;
        cursor: grab; user-select: none;
    }
    .tree-wrap::-webkit-scrollbar { display: none; }
    .tree-wrap.is-panning { cursor: grabbing; }
    .tree-canvas { position: relative; }
    .tree-svg { position: absolute; top: 0; left: 0; pointer-events: none; }
    .tree-node {
        position: absolute; width: 64px; height: 64px;
        border-radius: 50%; border: 3px solid var(--border);
        background: var(--bg-primary); display: flex; align-items: center;
        justify-content: center; cursor: pointer; transition: border-color .2s, transform .15s, box-shadow .2s;
        font-size: 22px; user-select: none;
    }
    .tree-node:hover { transform: scale(1.12); box-shadow: 0 0 14px rgba(83,119,162,0.6); }
    .tree-node.unlocked { border-color: #5da05d; background: #1e331e; }
    .tree-node.unlocked:hover { border-color: #7fca7f; }
    .tree-node.available { border-color: var(--accent); background: #1b2a3a; cursor: pointer; }
    .tree-node.available:hover { border-color: #89b8e8; }
    .tree-node.locked { opacity: 0.45; cursor: default; }
    .tree-node.locked:hover { transform: none; box-shadow: none; }
    .tree-node.root-node { border-color: #d4af37; background: #2a2210; font-size: 26px; }
    .node-label {
        position: absolute; bottom: -20px; left: 50%; transform: translateX(-50%);
        white-space: nowrap; font-size: 10px; color: var(--text-muted); pointer-events: none;
    }
    .node-cost {
        position: absolute; top: -16px; left: 50%; transform: translateX(-50%);
        white-space: nowrap; font-size: 10px; color: #d4af37; pointer-events: none;
        font-weight: 600;
    }
    /* Modal */
    .acad-modal-overlay {
        position: fixed; inset: 0; background: rgba(0,0,0,0.6);
        display: flex; align-items: center; justify-content: center; z-index: 900;
    }
    .acad-modal-box {
        background: var(--surface); border: 1px solid var(--border);
        border-radius: 14px; padding: 28px 32px; max-width: 480px; width: 92%;
        position: relative; max-height: 85vh; overflow-y: auto;
    }
    .acad-modal-close {
        position: absolute; top: 12px; right: 14px;
        background: none; border: none; font-size: 22px; cursor: pointer;
        color: var(--text-muted);
    }
    .acad-modal-close:hover { color: var(--text); }
    .acad-modal-title { font-size: 1.3rem; font-weight: 700; margin-bottom: 4px; }
    .acad-modal-grade { font-size: 12px; color: var(--text-muted); margin-bottom: 14px; }
    .acad-pattern-wrap { text-align: center; margin-bottom: 14px; }
    .acad-pattern-grid { display: inline-grid; border: 1px solid var(--border); border-radius: 4px; overflow: hidden; }
    .acad-pcell {
        width: 30px; height: 30px; position: relative;
        display: flex; align-items: center; justify-content: center; font-size: 16px;
    }
    .acad-pcell.light { background: var(--board-light, #c2d3e4); }
    .acad-pcell.dark  { background: var(--board-dark, #5377a2); }
    .acad-pcell.move-sq { background: rgba(70,160,70,0.55); }
    .acad-pcell.dark.move-sq { background: rgba(50,140,50,0.65); }
    .acad-pcell.cap-sq { background: rgba(200,60,60,0.25); }
    .acad-pcell.dark.cap-sq { background: rgba(200,60,60,0.35); }
    .acad-pcell.center-sq { background: #4a7040; }
    .acad-pcell.dark.center-sq { background: #3a5a30; }
    .acad-dot { width: 9px; height: 9px; border-radius: 50%; }
    .acad-dot.green { background: rgba(60,200,60,0.85); }
    .acad-dot.red   { background: rgba(220,60,60,0.9); }
    .acad-section-label { font-size: 11px; text-transform: uppercase; letter-spacing: .07em; color: var(--text-muted); margin: 12px 0 4px; }
    .acad-modal-text { font-size: 14px; line-height: 1.55; margin-bottom: 8px; }
    .acad-unlock-btn {
        margin-top: 14px; width: 100%; padding: 10px; border-radius: 8px;
        background: var(--accent); color: #fff; border: none; font-size: 15px;
        font-weight: 600; cursor: pointer; transition: background .15s;
    }
    .acad-unlock-btn:hover { background: var(--green-hover); }
    .acad-unlock-btn:disabled { background: var(--surface-alt); color: var(--text-muted); cursor: default; }
    .acad-already { margin-top: 14px; text-align: center; color: #5da05d; font-weight: 600; font-size: 14px; }
    </style>
</head>
<body>
<div class="app-shell">
<% pageContext.setAttribute("activeNav", "academy"); %>
<%@ include file="_sidebar.jsp" %>
<main class="page" style="overflow:auto;min-height:0">

<script>
var CTX = "${pageContext.request.contextPath}";
var USER_KP = ${knowledgePoints};
var UNLOCKED = ${unlockedPiecesJson};

<% List<PieceDefinition> pds = PieceRegistry.getAll(); %>
var PIECE_REGISTRY = [
<% for (PieceDefinition pd : pds) { %>
    { type:"<%= pd.getType() %>", label:"<%= pd.getLabel().replace("\"","\\\"") %>", grade:<%= pd.getGrade() %>,
      sprite:<%= pd.getSprite()!=null?"\""+pd.getSprite()+"\"":"null" %>,
      whiteUnicode:"<%= pd.getWhiteUnicode() %>", blackUnicode:"<%= pd.getBlackUnicode() %>",
      gameChar:"<%= pd.getGameChar() %>",
      fwd:<%= pd.isCanMoveForwards() %>, bwd:<%= pd.isCanMoveBackwards() %>,
      side:<%= pd.isCanMoveSideways() %>, diag:<%= pd.isCanMoveDiagonally() %>,
      jump:<%= pd.isCanJump() %>, lshape:<%= pd.isCanMoveInLShape() %>,
      range:<%= pd.getRange() %>, special:<%= pd.isSpecial() %> },
<% } %>
];
</script>

<div class="academy-page">
    <div class="academy-header">
        <div class="academy-title">&#127979; Academy</div>
        <div class="academy-kp-badge">
            <span class="kp-icon">&#128218;</span>
            <span id="kpDisplay"></span> Knowledge Points
        </div>
    </div>
    <p class="academy-desc">Spend Knowledge Points to unlock new pieces for use in the Army Builder. Hover over a node to see the piece name. Click to preview movement and unlock.</p>

    <div class="tree-wrap">
        <div class="tree-canvas" id="treeCanvas">
            <canvas class="tree-svg" id="treeCVS"></canvas>
            <!-- nodes injected by JS -->
        </div>
    </div>
</div>

<!-- Modal -->
<div class="acad-modal-overlay" id="acadModal" style="display:none" onclick="if(event.target===this)closeAcadModal()">
    <div class="acad-modal-box">
        <button class="acad-modal-close" onclick="closeAcadModal()">&times;</button>
        <div class="acad-modal-title" id="acadModalTitle"></div>
        <div class="acad-modal-grade" id="acadModalGrade"></div>
        <div class="acad-pattern-wrap" id="acadPatternWrap"></div>
        <div class="acad-section-label">Movement</div>
        <p class="acad-modal-text" id="acadModalMovement"></p>
        <div id="acadModalFooter"></div>
    </div>
</div>

<script>
// ── Skill tree definition ─────────────────────────────────────────────────────
// x,y in grid units; GRID = px per unit
const NODE_SIZE = 64;
const GRID = 150;

// Branch colors: used for connector lines and node accent borders
const BRANCH_COLOR = {
    _start:        '#d4af37',
    EVIL_PAWN:     '#888888',
    SQUIRE:        '#888888', LONGPAW:'#888888', RETREATER:'#888888', HOLLOW:'#888888', CRAWLER:'#888888',
    JESTER:        '#e07b20', DUKE:'#e07b20', BEAST_HANDLER:'#e07b20', EAGLE:'#e07b20', COIL:'#e07b20',
    LANCER:        '#27ae60', BIRD:'#27ae60', SHIELD:'#27ae60', BOOT:'#27ae60', FEATHER:'#27ae60',
    WIZARD:        '#27ae60', HUSK:'#27ae60', LANTERN:'#27ae60', HYDRA:'#27ae60', LIBRARY:'#27ae60',
    ECLIPSE:       '#8e44ad', PRINCE:'#8e44ad', CHOIR:'#8e44ad', HERBALIST:'#8e44ad',
    PRINCESS:      '#8e44ad', ORACLE:'#8e44ad', WARDEN:'#8e44ad',
    FORK:          '#c0392b',
};

const ACADEMY_TREE = [
    { type:'_start',       label:'Origins',       cost:0,  requires:[],                     x:6,   y:0 },
    { type:'EVIL_PAWN',    label:'Evil Pawn',      cost:5,  requires:['_start'],             x:0.5, y:1 },
    { type:'SQUIRE',       label:'Squire',         cost:5,  requires:['EVIL_PAWN'],           x:0,   y:2 },
    { type:'RETREATER',    label:'Retreater',      cost:5,  requires:['EVIL_PAWN'],           x:1,   y:2 },
    { type:'LONGPAW',      label:'Longpaw',        cost:8,  requires:['SQUIRE'],              x:0,   y:3 },
    { type:'HOLLOW',       label:'Hollow',         cost:10, requires:['RETREATER'],           x:1,   y:3 },
    { type:'CRAWLER',      label:'Crawler',        cost:12, requires:['LONGPAW'],             x:0,   y:4 },
    { type:'JESTER',       label:'Jester',         cost:8,  requires:['_start'],             x:3,   y:1 },
    { type:'LANCER',       label:'Lancer',         cost:8,  requires:['_start'],             x:6,   y:1 },
    { type:'ECLIPSE',      label:'Eclipse',        cost:8,  requires:['_start'],             x:10,  y:1 },
    { type:'DUKE',         label:'Duke',           cost:15, requires:['JESTER'],             x:2,   y:2 },
    { type:'BEAST_HANDLER',label:'Beast Handler',  cost:18, requires:['JESTER'],             x:4.5, y:2 },
    { type:'BIRD',         label:'Bird',           cost:15, requires:['LANCER'],             x:5.5, y:2 },
    { type:'SHIELD',       label:'Shield',         cost:12, requires:['LANCER'],             x:7,   y:2 },
    { type:'PRINCE',       label:'Prince',         cost:12, requires:['ECLIPSE'],            x:9.5, y:2 },
    { type:'CHOIR',        label:'Choir',          cost:20, requires:['ECLIPSE'],            x:11.5,y:2 },
    { type:'EAGLE',        label:'Eagle',          cost:20, requires:['DUKE'],              x:2,   y:3 },
    { type:'COIL',         label:'Coil',           cost:22, requires:['BEAST_HANDLER'],     x:4.5, y:3 },
    { type:'BOOT',         label:'Boot',           cost:25, requires:['BIRD'],              x:5,   y:3 },
    { type:'FEATHER',      label:'Feather',        cost:18, requires:['BIRD'],              x:6.5, y:3 },
    { type:'WIZARD',       label:'Wizard',         cost:25, requires:['SHIELD'],            x:7.5, y:3 },
    { type:'HERBALIST',    label:'Herbalist',      cost:18, requires:['PRINCE'],            x:9,   y:3 },
    { type:'PRINCESS',     label:'Princess',       cost:25, requires:['PRINCE'],            x:10.5,y:3 },
    { type:'HUSK',         label:'Husk',           cost:30, requires:['BOOT'],             x:5,   y:4 },
    { type:'LANTERN',      label:'Lantern',        cost:22, requires:['FEATHER'],           x:6.5, y:4 },
    { type:'ORACLE',       label:'Oracle',         cost:35, requires:['HERBALIST'],         x:9,   y:4 },
    { type:'WARDEN',       label:'Warden',         cost:20, requires:['PRINCESS'],          x:10.5,y:4 },
    { type:'HYDRA',        label:'Hydra',          cost:35, requires:['HUSK'],             x:5,   y:5 },
    { type:'LIBRARY',      label:'Library',        cost:40, requires:['HYDRA'],            x:5,   y:6 },
    { type:'FORK',         label:'Fork',           cost:50, requires:['LIBRARY','ORACLE'], x:7,   y:7 },
];

const PIECE_INFO_ACAD = {
    PAWN:         'Marches forward to empty squares. Captures diagonally forward.',
    KNIGHT:       'Leaps in an L-shape, jumping over any piece.',
    ROOK:         'Slides any number of squares in a straight line.',
    BISHOP:       'Slides any number of squares diagonally.',
    QUEEN:        'Slides any number of squares in any direction.',
    KING:         'Moves 1 square in any direction. Cannot be captured.',
    EVIL_PAWN:    'Moves diagonally forward to empty squares. Captures straight ahead.',
    SQUIRE:       'Moves and captures 1 square forward or sideways.',
    LONGPAW:      'Advances 1 or 2 squares forward. Captures 1 square diagonally forward.',
    RETREATER:    'Moves and captures 1 square forward or 1 square backward.',
    HOLLOW:       'Advances 1 or 2 squares forward, jumping over any piece in the way. Captures 1 square diagonally forward.',
    CRAWLER:      'Slides 1 square sideways to empty squares. Captures 1 square straight ahead.',
    JESTER:       'Moves up to 2 squares in any direction.',
    LANCER:       'Charges up to 3 squares forward (or 4 to capture). Can retreat 1 square.',
    ECLIPSE:      'Slides like a Rook on dark squares, like a Bishop on light squares.',
    DUKE:         'Jumps in a Z-pattern: 2 rows and 1 or 3 columns.',
    BEAST_HANDLER:'Moves 1 square any direction. Every 5 moves, summons Beasts nearby.',
    BIRD:         'Slides along straight lines and can jump to the farthest empty square in each cardinal direction.',
    SHIELD:       'Slides sideways, jumps to farthest empty square sideways, plus special rear moves.',
    PRINCE:       'Slides diagonally forward or straight backward at any distance.',
    CHOIR:        'Alternates each turn between sliding like a Rook and sliding like a Bishop.',
    EAGLE:        'Jumps exactly 3 squares in any cardinal direction.',
    COIL:         'Slides in a zigzag snake pattern in each + direction.',
    BOOT:         'Teleports to any empty square on the board. Also captures adjacent pieces.',
    FEATHER:      'Steps 1 square diagonally (empty). Captures by jumping over and landing beyond.',
    WIZARD:       'Teleports to same-color squares in 5×5. Can swap with enemy pieces.',
    HERBALIST:    'Slides diagonally. Captures in king range. Capturing it removes the capturer too.',
    PRINCESS:     'Jumps up to 2 squares in any direction. Boosts nearby allies\' range.',
    HUSK:         'Moves like a King (1 step all dirs). Each capture extends its reach by 1.',
    LANTERN:      'Jumps up to 2 squares diagonally. On capture, immobilizes nearby enemies.',
    ORACLE:       'Moves like a King. Once per game, curses a tile — any piece stepping there is removed.',
    WARDEN:       'Moves up to 2 squares any direction. Only captures pieces exactly 1 square away.',
    HYDRA:        'Slides up to 3 squares queen-style. Has 3 heads — survives being in check that many times.',
    LIBRARY:      'Copies the moveset of the last enemy piece it captured (king fallback if none).',
    FORK:         'Slides 2 squares orthogonally, then extends 3 squares sideways (T-shape). Plus king diagonals. Cannot move when directly attacked.',
};

const GRADE_NAMES = ['Grade 0 — Pawn', 'Grade 1 — Minor', 'Grade 2 — Major', 'Grade 3 — King-tier'];
const DEFAULT_UNLOCKED = ['PAWN','KNIGHT','ROOK','BISHOP','QUEEN','KING'];

// Current KP (may change after purchases)
let currentKP = USER_KP;
let unlockedSet = new Set(UNLOCKED);

// ── Helpers ───────────────────────────────────────────────────────────────────
function isUnlocked(type) {
    return type === '_start' || DEFAULT_UNLOCKED.includes(type) || unlockedSet.has(type);
}

function isAvailable(node) {
    if (isUnlocked(node.type)) return false;
    if (node.requires.length === 0) return true;
    return node.requires.every(r => isUnlocked(r));
}

function getPieceReg(type) {
    return PIECE_REGISTRY.find(p => p.type === type) || null;
}

function getPieceEmoji(type) {
    if (type === '_start') return '&#127979;';
    const pr = getPieceReg(type);
    if (!pr) return '?';
    return pr.whiteUnicode;
}
function appendPieceIcon(el, pDef, isWhite) {
    el.innerHTML = '';
    if (typeof buildPieceSVG === 'function') {
        const svg = buildPieceSVG(pDef.gameChar, isWhite !== false);
        svg.style.width = '100%'; svg.style.height = '100%';
        el.appendChild(svg);
    } else {
        el.textContent = isWhite !== false ? pDef.whiteUnicode : pDef.blackUnicode;
    }
}

// ── Render tree ───────────────────────────────────────────────────────────────
function renderTree() {
    document.getElementById('kpDisplay').textContent = currentKP;

    const canvas = document.getElementById('treeCanvas');
    const cvs    = document.getElementById('treeCVS');

    // Compute canvas size
    let maxX = 0, maxY = 0;
    ACADEMY_TREE.forEach(n => { maxX = Math.max(maxX, n.x); maxY = Math.max(maxY, n.y); });
    const W = (maxX + 1.5) * GRID + NODE_SIZE;
    const H = (maxY + 1)   * GRID + NODE_SIZE + 40;
    canvas.style.width  = W + 'px';
    canvas.style.height = H + 'px';
    cvs.width  = W;
    cvs.height = H;

    const nodeMap = {};
    ACADEMY_TREE.forEach(n => { nodeMap[n.type] = n; });

    const R = NODE_SIZE / 2;
    const ARROW_LEN = 10, ARROW_HALF_W = 5;
    const LOCKED_COL = '#aab8c8';

    // Pre-compute connector geometry once
    const connectors = [];
    ACADEMY_TREE.forEach(n => {
        n.requires.forEach(req => {
            const parent = nodeMap[req];
            if (!parent) return;
            const cx1 = parent.x * GRID + R, cy1 = parent.y * GRID + R;
            const cx2 = n.x * GRID + R,     cy2 = n.y * GRID + R;
            const dx = cx2 - cx1, dy = cy2 - cy1;
            const len = Math.sqrt(dx * dx + dy * dy) || 1;
            const ux = dx / len, uy = dy / len;
            const perpX = -uy, perpY = ux;
            const sx = cx1 + ux * (R + 3),          sy = cy1 + uy * (R + 3);
            const ex = cx2 - ux * (R + ARROW_LEN + 3), ey = cy2 - uy * (R + ARROW_LEN + 3);
            const midY = (sy + ey) / 2;
            const tipX = cx2 - ux * (R - 1),         tipY = cy2 - uy * (R - 1);
            const baseX = tipX - ux * ARROW_LEN,      baseY = tipY - uy * ARROW_LEN;
            connectors.push({
                sx, sy, ex, ey, midY, tipX, tipY,
                w1x: baseX + perpX * ARROW_HALF_W, w1y: baseY + perpY * ARROW_HALF_W,
                w2x: baseX - perpX * ARROW_HALF_W, w2y: baseY - perpY * ARROW_HALF_W,
                parentType: req, childType: n.type,
                branchColor: BRANCH_COLOR[n.type] || '#5da05d'
            });
        });
    });

    // Draw connectors on canvas (normal state)
    drawConnectors(cvs, connectors, null);

    // Remove old nodes
    canvas.querySelectorAll('.tree-node').forEach(el => el.remove());

    // Create node elements
    ACADEMY_TREE.forEach(n => {
        const el = document.createElement('div');
        el.className = 'tree-node';
        const branchCol = BRANCH_COLOR[n.type] || 'var(--border)';

        if (n.type === '_start') {
            el.classList.add('root-node');
        } else if (isUnlocked(n.type)) {
            el.classList.add('unlocked');
            el.style.borderColor = branchCol;
            el.style.boxShadow = '0 0 10px ' + branchCol + '55';
        } else if (isAvailable(n)) {
            el.classList.add('available');
            el.style.borderColor = branchCol;
            el.style.opacity = '0.85';
        } else {
            el.classList.add('locked');
        }

        el.style.left = (n.x * GRID) + 'px';
        el.style.top  = (n.y * GRID) + 'px';
        if (n.type === '_start') {
            el.innerHTML = getPieceEmoji(n.type);
        } else {
            const _pr = getPieceReg(n.type);
            if (_pr && typeof buildPieceSVG === 'function') {
                const _svg = buildPieceSVG(_pr.gameChar, true);
                _svg.style.width = '100%'; _svg.style.height = '100%';
                el.appendChild(_svg);
            } else {
                el.innerHTML = getPieceEmoji(n.type);
            }
        }
        el.title = n.label + (n.cost > 0 ? ' (' + n.cost + ' KP)' : '');

        const label = document.createElement('div');
        label.className = 'node-label';
        label.textContent = n.label;
        el.appendChild(label);

        if (n.cost > 0 && !isUnlocked(n.type)) {
            const cost = document.createElement('div');
            cost.className = 'node-cost';
            cost.textContent = n.cost + ' KP';
            el.appendChild(cost);
        }

        if (n.type !== '_start') {
            el.addEventListener('click', () => { if (!panMoved) openAcadModal(n); });
        }

        el.addEventListener('mouseenter', () => drawConnectors(cvs, connectors, n.type));
        el.addEventListener('mouseleave', () => drawConnectors(cvs, connectors, null));

        canvas.appendChild(el);
    });
}

// ── Draw connectors on a <canvas> element ─────────────────────────────────────
function drawConnectors(cvs, connectors, highlightType) {
    const ctx = cvs.getContext('2d');
    ctx.clearRect(0, 0, cvs.width, cvs.height);
    connectors.forEach(c => {
        const bu = isUnlocked(c.parentType) && isUnlocked(c.childType);
        const ba = isUnlocked(c.parentType) && !isUnlocked(c.childType);
        const highlighted = highlightType &&
            (c.parentType === highlightType || c.childType === highlightType);
        const col = (bu || ba) ? c.branchColor : '#aab8c8';
        const alpha = highlighted ? 1 : (bu ? 1 : ba ? 0.85 : 0.55);
        const lw    = highlighted ? 3.5 : (bu ? 2.5 : 2);

        ctx.globalAlpha = alpha;

        // Bezier line
        ctx.beginPath();
        ctx.moveTo(c.sx, c.sy);
        ctx.bezierCurveTo(c.sx, c.midY, c.ex, c.midY, c.ex, c.ey);
        ctx.strokeStyle = col;
        ctx.lineWidth = lw;
        ctx.stroke();

        // Arrowhead triangle
        ctx.beginPath();
        ctx.moveTo(c.tipX, c.tipY);
        ctx.lineTo(c.w1x, c.w1y);
        ctx.lineTo(c.w2x, c.w2y);
        ctx.closePath();
        ctx.fillStyle = col;
        ctx.fill();
    });
    ctx.globalAlpha = 1;
}

// ── Movement pattern board ────────────────────────────────────────────────────
function getPatternSquares(pDef) {
    const gc = pDef.gameChar;
    const CR = 4, CC = 4;
    const walk = [], capture = [];
    function inBd(r,c) { return r>=0&&r<8&&c>=0&&c<8; }

    if (pDef.special) {
        if (inBd(CR-1,CC)) walk.push([CR-1,CC]);
        if (inBd(CR-2,CC)) walk.push([CR-2,CC]);
        [-1,1].forEach(dc => { if(inBd(CR-1,CC+dc)) capture.push([CR-1,CC+dc]); });
        return {walk, capture};
    }
    if (gc==='e') {
        [-1,1].forEach(dc=>{ if(inBd(CR-1,CC+dc)) walk.push([CR-1,CC+dc]); });
        if(inBd(CR-1,CC)) capture.push([CR-1,CC]);
        return {walk, capture};
    }
    if (gc==='sq') { // Squire: 1 forward or 1 sideways
        const both=[];
        if(inBd(CR-1,CC)) both.push([CR-1,CC]);
        [-1,1].forEach(dc=>{ if(inBd(CR,CC+dc)) both.push([CR,CC+dc]); });
        return {walk:both, capture};
    }
    if (gc==='lp') { // Longpaw: 1-2 forward walk, diagonal forward capture
        if(inBd(CR-1,CC)) walk.push([CR-1,CC]);
        if(inBd(CR-2,CC)) walk.push([CR-2,CC]);
        [-1,1].forEach(dc=>{ if(inBd(CR-1,CC+dc)) capture.push([CR-1,CC+dc]); });
        return {walk, capture};
    }
    if (gc==='rt') { // Retreater: 1 forward or 1 backward
        const both=[];
        if(inBd(CR-1,CC)) both.push([CR-1,CC]);
        if(inBd(CR+1,CC)) both.push([CR+1,CC]);
        return {walk:both, capture};
    }
    if (gc==='ho') { // Hollow: 1-2 forward walk (jump), diagonal forward capture
        if(inBd(CR-1,CC)) walk.push([CR-1,CC]);
        if(inBd(CR-2,CC)) walk.push([CR-2,CC]);
        [-1,1].forEach(dc=>{ if(inBd(CR-1,CC+dc)) capture.push([CR-1,CC+dc]); });
        return {walk, capture};
    }
    if (gc==='cr') { // Crawler: 1 sideways walk, 1 forward capture
        [-1,1].forEach(dc=>{ if(inBd(CR,CC+dc)) walk.push([CR,CC+dc]); });
        if(inBd(CR-1,CC)) capture.push([CR-1,CC]);
        return {walk, capture};
    }
    if (gc==='h') {
        [[-1,-1],[-1,1],[1,-1],[1,1]].forEach(([dr,dc])=>{ for(let i=1;i<5;i++){const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; walk.push([r,c]);} });
        [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) capture.push([r,c]); });
        return {walk, capture};
    }
    if (gc==='c') {
        [[-1,-1],[-1,1],[1,-1],[1,1]].forEach(([dr,dc])=>{
            const r1=CR+dr,c1=CC+dc; if(inBd(r1,c1)) walk.push([r1,c1]);
            const r2=CR+2*dr,c2=CC+2*dc; if(inBd(r1,c1)&&inBd(r2,c2)) capture.push([r2,c2]);
        });
        return {walk, capture};
    }

    const both = [];
    if (gc==='l') {
        for(let i=1;i<=3;i++){const r=CR-i; if(inBd(r,CC)) both.push([r,CC]);}
        if(inBd(CR+1,CC)) both.push([CR+1,CC]);
        if(inBd(CR-4,CC)) capture.push([CR-4,CC]);
        return {walk:both, capture};
    }
    if (gc==='y') {
        [[-1,-1],[-1,1],[1,0]].forEach(([dr,dc])=>{ for(let i=1;i<5;i++){const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; both.push([r,c]);} });
        return {walk:both, capture};
    }
    if (gc==='d') {
        [[-2,3],[-2,1],[-2,-1],[-2,-3],[2,3],[2,1],[2,-1],[2,-3]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
        return {walk:both, capture};
    }
    if (gc==='n') { // Knight
        [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
        return {walk:both, capture};
    }
    if (gc==='j') { // Jester (range 2, all dirs)
        [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]].forEach(([dr,dc])=>{ [1,2].forEach(i=>{ const r=CR+dr*i,c=CC+dc*i; if(inBd(r,c)) both.push([r,c]); }); });
        return {walk:both, capture};
    }
    if (gc==='z') {
        for(let dr=-2;dr<=2;dr++) for(let dc=-2;dc<=2;dc++){ if(!dr&&!dc) continue; const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        return {walk:both, capture};
    }
    if (gc==='f') {
        [[-1,0],[1,0],[0,-1],[0,1]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
        [[-1,0],[1,0],[0,-1],[0,1]].forEach(([dr,dc])=>{ let er=CR+dr,ec=CC+dc,last=null; while(inBd(er,ec)){if(!(er===CR+dr&&ec===CC+dc))last=[er,ec];er+=dr;ec+=dc;} if(last) both.push(last); });
        return {walk:both, capture};
    }
    if (gc==='g') {
        [[-3,0],[3,0],[0,-3],[0,3]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
        return {walk:both, capture};
    }
    if (gc==='m') {
        [[-1,-1],[-1,1],[1,-1],[1,1]].forEach(([dr,dc])=>{ [1,2].forEach(i=>{ const r=CR+dr*i,c=CC+dc*i; if(inBd(r,c)) both.push([r,c]); }); });
        return {walk:both, capture};
    }
    if (gc==='t') {
        const mc=(CR+CC)%2;
        for(let dr=-2;dr<=2;dr++) for(let dc=-2;dc<=2;dc++){ if(!dr&&!dc) continue; const r=CR+dr,c=CC+dc; if(inBd(r,c)&&(r+c)%2===mc) both.push([r,c]); }
        return {walk:both, capture};
    }
    if (gc==='w') {
        [[-1,0],[1,0],[0,-1],[0,1],[-1,-1],[-1,1],[1,-1],[1,1]].forEach(([dr,dc])=>{ for(let i=1;i<4;i++){const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; both.push([r,c]);} });
        return {walk:both, capture};
    }
    if (gc==='o') {
        for(let c2=0;c2<8;c2++) [0,7].forEach(r=>{ if(!(r===CR&&c2===CC)) both.push([r,c2]); });
        for(let r2=1;r2<7;r2++) [0,7].forEach(c2=>{ if(!(r2===CR&&c2===CC)) both.push([r2,c2]); });
        [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) capture.push([r,c]); });
        return {walk:both, capture};
    }
    if (gc==='x') { // Coil
        [[-1,0],[1,0],[0,1],[0,-1]].forEach(([dr,dc])=>{
            let cr=CR,cc=CC,side=1;
            for(let s=0;s<7;s++){
                if(s===0){ if(!inBd(cr+dr,cc+dc)) return; both.push([cr+dr,cc+dc]); cr+=dr; cc+=dc; }
                else { const sr=dr===0?side:0,sc=dc===0?side:0; const nr=cr+dr+sr,nc=cc+dc+sc; if(!inBd(nr,nc)) return; both.push([nr,nc]); cr=nr; cc=nc; side=-side; }
            }
        });
        return {walk:both, capture};
    }
    if (gc==='ch') {
        [[-1,0],[1,0],[0,-1],[0,1],[-1,-1],[-1,1],[1,-1],[1,1]].forEach(([dr,dc])=>{ for(let i=1;i<5;i++){const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; both.push([r,c]);} });
        return {walk:both, capture};
    }
    if (gc==='hk') {
        [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
        return {walk:both, capture};
    }
    if (gc==='hy') {
        [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]].forEach(([dr,dc])=>{ for(let i=1;i<=3;i++){const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; both.push([r,c]);} });
        return {walk:both, capture};
    }
    if (gc==='lb') {
        [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
        return {walk:both, capture};
    }
    if (gc==='fk') {
        [[-1,-1],[-1,1],[1,-1],[1,1]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
        [[-1,0],[1,0],[0,-1],[0,1]].forEach(([dr,dc])=>{
            const perpDirs=dr===0?[[-1,0],[1,0]]:[[0,-1],[0,1]];
            const r1=CR+dr,c1=CC+dc; if(!inBd(r1,c1)) return; both.push([r1,c1]);
            const r2=CR+2*dr,c2=CC+2*dc; if(!inBd(r2,c2)) return; both.push([r2,c2]);
            perpDirs.forEach(([pdr,pdc])=>{ for(let i=1;i<=1;i++){const r=r2+pdr*i,c=c2+pdc*i; if(!inBd(r,c)) break; both.push([r,c]);} });
        });
        return {walk:both, capture};
    }
    if (gc==='i') { // Shield
        [-1,1].forEach(dc=>{ for(let i=1;i<5;i++){const c=CC+dc*i; if(!inBd(CR,c)) break; both.push([CR,c]);} });
        if(inBd(CR-1,CC)) both.push([CR-1,CC]);
        [[1,-1],[1,0],[1,1],[2,0]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
        return {walk:both, capture};
    }
    if (gc==='a') { // Beast Handler
        [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
        return {walk:both, capture};
    }
    if (gc==='s') { // Princess
        [[-1,-1],[-1,1],[1,-1],[1,1]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
        [[-2,0],[2,0],[0,-2],[0,2]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
        return {walk:both, capture};
    }
    if (gc==='u') { // Oracle
        [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
        return {walk:both, capture};
    }
    // Generic
    if (pDef.lshape) {
        [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]].forEach(([dr,dc])=>{ const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); });
    }
    const dirs2=[];
    if (pDef.fwd) dirs2.push([-1,0]);
    if (pDef.bwd) dirs2.push([1,0]);
    if (pDef.side){dirs2.push([0,-1]);dirs2.push([0,1]);}
    if (pDef.diag){dirs2.push([-1,-1]);dirs2.push([-1,1]);dirs2.push([1,-1]);dirs2.push([1,1]);}
    const mxR = pDef.range===0?5:pDef.range;
    dirs2.forEach(([dr,dc])=>{ for(let i=1;i<=mxR;i++){const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; both.push([r,c]);} });
    return {walk:both, capture};
}

function buildPatternBoard(pDef) {
    const {walk, capture} = getPatternSquares(pDef);
    const walkSet = new Set(walk.map(([r,c])=>r+','+c));
    const capSet  = new Set(capture.map(([r,c])=>r+','+c));
    const CR=4, CC=4, CELL=30;

    const grid = document.createElement('div');
    grid.className = 'acad-pattern-grid';
    grid.style.gridTemplateColumns = 'repeat(8,'+CELL+'px)';
    grid.style.gridTemplateRows    = 'repeat(8,'+CELL+'px)';

    for (let r=0;r<8;r++) for (let c=0;c<8;c++) {
        const cell = document.createElement('div');
        const light = (r+c)%2===0;
        const key=r+','+c;
        const isW=walkSet.has(key), isC=capSet.has(key), isCtr=r===CR&&c===CC;
        cell.className = 'acad-pcell' + (light?' light':' dark') +
            (isCtr?' center-sq':isW||isC?' move-sq':'') + (!isW&&isC?' cap-sq':'');
        cell.style.width=CELL+'px'; cell.style.height=CELL+'px';
        if (isCtr) {
            cell.style.display='flex'; cell.style.alignItems='center'; cell.style.justifyContent='center';
            if (typeof buildPieceSVG === 'function') {
                const _s = buildPieceSVG(pDef.gameChar, true);
                _s.style.width=(CELL*0.85)+'px'; _s.style.height=(CELL*0.85)+'px';
                cell.appendChild(_s);
            } else {
                cell.style.fontSize='18px';
                cell.textContent = pDef.whiteUnicode;
            }
        } else if (!isW && isC) {
            const dot=document.createElement('div'); dot.className='acad-dot red'; cell.appendChild(dot);
        } else if (isW || isC) {
            const dot=document.createElement('div'); dot.className='acad-dot green'; cell.appendChild(dot);
        }
        grid.appendChild(cell);
    }
    return grid;
}

// ── Modal ─────────────────────────────────────────────────────────────────────
let currentModalNode = null;

function openAcadModal(node) {
    currentModalNode = node;
    const pr = getPieceReg(node.type);
    document.getElementById('acadModalTitle').textContent = node.label;
    document.getElementById('acadModalGrade').textContent = pr ? (GRADE_NAMES[pr.grade] || '') : '';
    document.getElementById('acadModalMovement').textContent = PIECE_INFO_ACAD[node.type] || '';

    const wrap = document.getElementById('acadPatternWrap');
    wrap.innerHTML = '';
    if (pr) wrap.appendChild(buildPatternBoard(pr));

    const footer = document.getElementById('acadModalFooter');
    footer.innerHTML = '';
    if (isUnlocked(node.type)) {
        const already = document.createElement('div');
        already.className = 'acad-already';
        already.textContent = '✓ Unlocked';
        footer.appendChild(already);
    } else {
        const btn = document.createElement('button');
        btn.className = 'acad-unlock-btn';
        const canAfford = currentKP >= node.cost;
        const prereqsMet = node.requires.every(r => isUnlocked(r));
        if (!prereqsMet) {
            btn.textContent = 'Prerequisites not met';
            btn.disabled = true;
        } else if (!canAfford) {
            btn.textContent = 'Need ' + node.cost + ' KP (have ' + currentKP + ')';
            btn.disabled = true;
        } else {
            btn.textContent = 'Unlock for ' + node.cost + ' KP';
            btn.onclick = () => doUnlock(node, btn);
        }
        footer.appendChild(btn);
    }

    document.getElementById('acadModal').style.display = 'flex';
}

function closeAcadModal() {
    document.getElementById('acadModal').style.display = 'none';
    currentModalNode = null;
}

function doUnlock(node, btn) {
    btn.disabled = true;
    btn.textContent = 'Unlocking…';
    const fd = new FormData();
    fd.append('pieceType', node.type);
    fetch(CTX + '/unlockPiece', {method:'POST', body:fd})
        .then(r=>r.json())
        .then(data=>{
            if (data.ok) {
                currentKP = data.kp;
                unlockedSet.add(node.type);
                document.getElementById('kpDisplay').textContent = currentKP;
                closeAcadModal();
                renderTree();
            } else {
                btn.textContent = 'Error: ' + (data.error || 'unknown');
                btn.disabled = false;
            }
        })
        .catch(()=>{ btn.textContent = 'Network error'; btn.disabled = false; });
}

// ── Pan ───────────────────────────────────────────────────────────────────────
let panMoved = false;

(function initPan() {
    const wrap = document.querySelector('.tree-wrap');
    let dragging = false, startX = 0, startY = 0, scrollL = 0, scrollT = 0;

    wrap.addEventListener('mousedown', function(e) {
        if (e.button !== 0) return;
        dragging  = true;
        panMoved  = false;
        startX    = e.clientX;
        startY    = e.clientY;
        scrollL   = wrap.scrollLeft;
        scrollT   = wrap.scrollTop;
        wrap.classList.add('is-panning');
        e.preventDefault();
    });

    window.addEventListener('mousemove', function(e) {
        if (!dragging) return;
        const dx = e.clientX - startX;
        const dy = e.clientY - startY;
        if (Math.abs(dx) > 3 || Math.abs(dy) > 3) panMoved = true;
        wrap.scrollLeft = scrollL - dx;
        wrap.scrollTop  = scrollT - dy;
    });

    window.addEventListener('mouseup', function() {
        if (!dragging) return;
        dragging = false;
        wrap.classList.remove('is-panning');
    });
})();

// ── Init ──────────────────────────────────────────────────────────────────────
renderTree();
</script>
</main>
</div>
<%@ include file="_bot-picker.jsp" %>
</body>
</html>
