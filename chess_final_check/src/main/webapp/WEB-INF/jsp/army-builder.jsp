<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.army.Army, timolr.chess.army.ArmyPiece, java.util.List, timolr.chess.game.pieces.PieceDefinition, timolr.chess.game.pieces.PieceRegistry" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Army Builder - Forkr</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Newsreader:ital,opsz,wght@0,6..72,300..700;1,6..72,300..700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/forkr.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
    <style>body{background:var(--bg)!important;overflow:hidden}</style>
    <script src="${pageContext.request.contextPath}/js/piece-art.js"></script>
    <style>
    .ab-piece-btn { position: relative; }
    .ab-info-btn {
        position: absolute; top: 3px; right: 3px;
        width: 16px; height: 16px; border-radius: 50%;
        background: var(--surface-alt); border: 1px solid var(--border);
        color: #fff; font-size: 10px; font-weight: 700;
        cursor: pointer; line-height: 14px; text-align: center; padding: 0;
        transition: background .15s, color .15s;
        z-index: 5;
    }
    .ab-info-btn:hover { background: var(--accent); border-color: var(--accent); }
    .piece-info-overlay {
        position: fixed; inset: 0; background: rgba(0,0,0,0.55);
        display: flex; align-items: center; justify-content: center; z-index: 900;
    }
    .piece-info-box {
        background: var(--surface); border: 1px solid var(--border);
        border-radius: 12px; padding: 28px 32px; max-width: 440px; width: 90%;
        position: relative; max-height: 80vh; overflow-y: auto;
    }
    .piece-info-box h2 { margin: 0 0 4px; font-size: 1.3rem; }
    .piece-info-grade { font-size: 12px; color: var(--text-muted); margin-bottom: 16px; }
    .piece-info-box h3 { font-size: 0.88rem; text-transform: uppercase; letter-spacing: .05em; color: var(--text-muted); margin: 14px 0 4px; }
    .piece-info-box p { margin: 0 0 8px; line-height: 1.55; font-size: 14px; }
    .piece-info-close {
        position: absolute; top: 12px; right: 14px;
        background: none; border: none; font-size: 20px; cursor: pointer;
        color: var(--text-muted); line-height: 1;
    }
    .piece-info-close:hover { color: var(--text); }
    </style>
</head>
<body>
<div class="app-shell">
<% pageContext.setAttribute("activeNav", "army"); %>
<%@ include file="_sidebar.jsp" %>
<main class="page" style="overflow:auto;min-height:0">


<!-- Pass loaded army data to JS -->
<script>
<%
    Army loaded = (Army) request.getAttribute("loadedArmy");
    if (loaded == null) { loaded = (Army) pageContext.findAttribute("loadedArmy"); }
%>
var LOADED_ARMY = null;
<% if (loaded != null) { %>
LOADED_ARMY = {
    id: <%= loaded.getId() %>,
    name: "<%= loaded.getName().replace("\"", "\\\"") %>",
    team: "<%= loaded.getTeam() %>",
    preset: <%= loaded.isPreset() %>,
    pieces: [
        <% for (ArmyPiece p : loaded.getPieces()) { %>
        { pieceType: "<%= p.getPieceType() %>", col: "<%= p.getBoardCol() %>", rank: <%= p.getBoardRank() %> },
        <% } %>
    ]
};
<% } %>

var USER_ARMIES = [
<%
    List<Army> userArmies = (List<Army>) pageContext.findAttribute("userArmies");
    if (userArmies != null) {
        for (Army a : userArmies) {
%>
    { id: <%= a.getId() %>, name: "<%= a.getName().replace("\"", "\\\"") %>", team: "<%= a.getTeam() %>", pieceCount: <%= a.getPieces().size() %>, active: <%= a.isActive() %> },
<%      }
    }
%>
];

var PRESET_ARMIES = [
<%
    List<Army> presets = (List<Army>) pageContext.findAttribute("presetArmies");
    if (presets != null) {
        for (Army a : presets) {
%>
    { id: <%= a.getId() %>, name: "<%= a.getName().replace("\"", "\\\"") %>", team: "<%= a.getTeam() %>", pieceCount: <%= a.getPieces().size() %> },
<%      }
    }
%>
];

var IS_ADMIN = <%= Boolean.TRUE.equals(session.getAttribute("isAdmin")) %>;
var CTX = "${pageContext.request.contextPath}";
var USER_UNLOCKED = <s:property value="userUnlockedPiecesJson" escapeHtml="false" />;
var DEFAULT_PIECES = ['PAWN','KNIGHT','ROOK','BISHOP','QUEEN','KING'];
function isUnlockedForUser(type) {
    return DEFAULT_PIECES.indexOf(type) !== -1 || USER_UNLOCKED.indexOf(type) !== -1;
}

<%-- Piece definitions from PieceRegistry — add new pieces there, not here --%>
<% List<PieceDefinition> pieceDefs = PieceRegistry.getAll(); %>
var PIECE_DEFS = [
<% for (PieceDefinition pd : pieceDefs) { %>
    {
        type:         "<%= pd.getType() %>",
        label:        "<%= pd.getLabel().replace("\"", "\\\"") %>",
        grade:        <%= pd.getGrade() %>,
        sprite:       <%= pd.getSprite() != null ? "\"" + pd.getSprite() + "\"" : "null" %>,
        whiteUnicode: "<%= pd.getWhiteUnicode() %>",
        blackUnicode: "<%= pd.getBlackUnicode() %>",
        gameChar:     "<%= pd.getGameChar() %>",
        special:      <%= pd.isSpecial() %>,
        fwd:          <%= pd.isCanMoveForwards() %>,
        bwd:          <%= pd.isCanMoveBackwards() %>,
        side:         <%= pd.isCanMoveSideways() %>,
        diag:         <%= pd.isCanMoveDiagonally() %>,
        jump:         <%= pd.isCanJump() %>,
        lshape:       <%= pd.isCanMoveInLShape() %>,
        range:        <%= pd.getRange() %>
    },
<% } %>
];
</script>

<s:if test="hasActionErrors()">
<div class="ab-flash-error">
    <s:actionerror />
</div>
</s:if>

<div class="ab-page">
    <div class="ab-header">
        <h1 class="ab-title">&#9876; Army Builder</h1>
        <p class="ab-subtitle">Build your custom starting army for White and Black.</p>
    </div>

    <!-- Team Tabs -->
    <div class="ab-tabs">
        <button class="ab-tab active" id="tab-white" onclick="switchTeam('WHITE')">
            &#9812; White Army
        </button>
        <button class="ab-tab" id="tab-black" onclick="switchTeam('BLACK')">
            &#9818; Black Army
        </button>
    </div>

    <div class="ab-main">
        <!-- Left: Armies List -->
        <div class="ab-panel-left">
            <div class="ab-section-title">My Armies</div>

            <div id="army-list-white" class="ab-army-list">
                <!-- populated by JS -->
            </div>
            <div id="army-list-black" class="ab-army-list" style="display:none">
                <!-- populated by JS -->
            </div>

            <% if (presets != null && !presets.isEmpty()) { %>
            <div class="ab-section-title" style="margin-top:16px">AI Preset Armies</div>
            <div id="preset-list-white" class="ab-army-list">
                <!-- populated by JS -->
            </div>
            <div id="preset-list-black" class="ab-army-list" style="display:none">
                <!-- populated by JS -->
            </div>
            <% } %>
        </div>

        <!-- Center: Board + Controls -->
        <div class="ab-center">
            <div id="editing-banner" class="ab-editing-banner" style="display:none">
                <span style="color:var(--text-muted);font-size:12px">Editing:</span>
                <span id="banner-name" class="ab-editing-name"></span>
                <span id="banner-team" class="ab-editing-team"></span>
            </div>
            <div class="ab-board-header">
                <div class="ab-name-row">
                    <input type="text" id="army-name" class="form-input ab-name-input" placeholder="Army name..." maxlength="100">
                    <input type="hidden" id="army-id" value="">
                    <button class="btn btn-outline ab-btn-sm" onclick="clearBoard()" title="New army">New</button>
                </div>
                <div id="ab-status" class="ab-status ab-status-empty">Fill all 16 squares. King must be in the back rank on its own color.</div>
            </div>

            <!-- Placement Board -->
            <div class="ab-board-wrap">
                <div class="ab-rank-labels" id="rank-labels"></div>
                <div class="ab-board" id="ab-board"></div>
            </div>
            <div class="ab-file-labels">
                <span>A</span><span>B</span><span>C</span><span>D</span>
                <span>E</span><span>F</span><span>G</span><span>H</span>
            </div>

            <div class="ab-actions">
                <button class="btn btn-green" onclick="saveArmy()">Save Army</button>
                <button class="btn btn-outline ab-btn-sm" onclick="deleteCurrentArmy()" id="btn-delete" style="display:none">Delete</button>
            </div>

            <!-- Hidden save form -->
            <form id="save-form" method="POST" action="${pageContext.request.contextPath}/saveArmy">
                <input type="hidden" name="name" id="f-name">
                <input type="hidden" name="team" id="f-team">
                <input type="hidden" name="armyId" id="f-armyId">
                <input type="hidden" name="piecesJson" id="f-piecesJson">
                <% if (Boolean.TRUE.equals(session.getAttribute("isAdmin"))) { %>
                <input type="hidden" name="preset" id="f-preset" value="false">
                <% } %>
            </form>
            <form id="delete-form" method="POST" action="${pageContext.request.contextPath}/deleteArmy">
                <input type="hidden" name="armyId" id="d-armyId">
            </form>
        </div>

        <!-- Right: Piece Palette -->
        <div class="ab-panel-right">
            <div class="ab-section-title">Pieces</div>
            <div class="ab-grade-tabs" id="grade-tabs">
                <button class="ab-grade-tab active" data-grade="0" onclick="setGradeFilter(0)"><span class="ab-grade-badge g0">G0</span> Pawns</button>
                <button class="ab-grade-tab" data-grade="1" onclick="setGradeFilter(1)"><span class="ab-grade-badge g1">G1</span> Minor</button>
                <button class="ab-grade-tab" data-grade="2" onclick="setGradeFilter(2)"><span class="ab-grade-badge g2">G2</span> Major</button>
                <button class="ab-grade-tab" data-grade="3" onclick="setGradeFilter(3)"><span class="ab-grade-badge g3">G3</span> King</button>
            </div>
            <div id="piece-palette" class="ab-palette">
                <!-- populated by JS -->
            </div>

            <div class="ab-grade-legend">
                <div class="ab-legend-item"><span class="ab-grade-badge g0">G0</span> Pawn: max 8</div>
                <div class="ab-legend-item"><span class="ab-grade-badge g1">G1</span> Knight/Rook/Bishop: 2, diff. colors</div>
                <div class="ab-legend-item"><span class="ab-grade-badge g2">G2</span> Queen: max 1</div>
                <div class="ab-legend-item"><span class="ab-grade-badge g3">G3</span> King: 1, back rank, own color</div>
            </div>

            <% if (Boolean.TRUE.equals(session.getAttribute("isAdmin"))) { %>
            <div class="ab-admin-preset" style="margin-top:20px">
                <label class="ab-preset-label">
                    <input type="checkbox" id="cb-preset"> Mark as AI Preset
                </label>
            </div>
            <% } %>
        </div>
    </div>
</div>

<script>
// ─── Config ───────────────────────────────────────────────────────────────────
const COLS = ['A','B','C','D','E','F','G','H'];
const PIECES = PIECE_DEFS; // populated from PieceRegistry on the server
const GRADE_MAX = { 0: 8, 1: 2, 2: 1, 3: 1 };
const GRADE_MAX_G2_TOTAL = 2;

// ─── Piece icon helper ────────────────────────────────────────────────────────
// Returns an inline SVG element for the given piece definition and team.
// spriteClass is an optional CSS class added for size overrides.
function createPieceIconEl(pDef, team, spriteClass) {
    const svg = buildPieceSVG(pDef.gameChar, team === 'WHITE');
    if (spriteClass) svg.classList.add(spriteClass);
    return svg;
}

// ─── State ────────────────────────────────────────────────────────────────────
let currentTeam = 'WHITE';
let selectedPieceType = null;
let lastPaletteTeam = null; // tracks when palette DOM needs a full rebuild
let currentGradeFilter = 0;
// board[col][rank] = pieceType string or null
let board = {};

// ─── Square color ─────────────────────────────────────────────────────────────
// a1 is dark (standard chess), so light = (colIdx + rank) % 2 === 0
function isLightSquare(col, rank) {
    const colIdx = COLS.indexOf(col);
    return (colIdx + rank) % 2 === 0;
}

// ─── Valid rank range per team ─────────────────────────────────────────────────
function validRanks(team) {
    return team === 'WHITE' ? [1,2] : [7,8];
}
function backRank(team) {
    return team === 'WHITE' ? 1 : 8;
}
const BOARD_SIZE = 16; // 2 ranks × 8 files

// ─── Build board state from pieces array ──────────────────────────────────────
function initBoard(pieces) {
    board = {};
    COLS.forEach(c => { board[c] = {}; });
    if (pieces) {
        pieces.forEach(p => {
            board[p.col][p.rank] = p.pieceType;
        });
    }
}

// ─── Count pieces of a type on board ──────────────────────────────────────────
function countOnBoard(pieceType) {
    let n = 0;
    COLS.forEach(c => {
        Object.keys(board[c]).forEach(r => {
            if (board[c][r] === pieceType) n++;
        });
    });
    return n;
}

function countGrade2OnBoard() {
    const g2pieces = PIECES.filter(p => p.grade === 2).map(p => p.type);
    let n = 0;
    COLS.forEach(c => {
        Object.keys(board[c]).forEach(r => {
            if (g2pieces.includes(board[c][r])) n++;
        });
    });
    return n;
}

// ─── Get all placed pieces of a type ──────────────────────────────────────────
function getPlacedOfType(pieceType) {
    const result = [];
    COLS.forEach(col => {
        Object.keys(board[col]).forEach(rank => {
            if (board[col][rank] === pieceType) {
                result.push({ col, rank: parseInt(rank) });
            }
        });
    });
    return result;
}

// ─── Can we place a piece on a given square? ─────────────────────────────────
function canPlace(pieceType, col, rank) {
    // Must be in valid rank range for the team
    if (!validRanks(currentTeam).includes(rank)) return false;
    // Square must be empty
    if (board[col][rank]) return false;

    const pieceDef = PIECES.find(p => p.type === pieceType);
    if (!pieceDef) return false;
    const grade = pieceDef.grade;
    const currentCount = countOnBoard(pieceType);
    const maxAllowed = GRADE_MAX[grade];

    if (currentCount >= maxAllowed) return false;

    // Grade 2: total grade-2 cap
    if (grade === 2 && countGrade2OnBoard() >= GRADE_MAX_G2_TOTAL) return false;

    // Grade 1: if placing the 2nd of same type, must be on different color than first
    if (grade === 1 && currentCount === 1) {
        const existing = getPlacedOfType(pieceType)[0];
        const existingLight = isLightSquare(existing.col, existing.rank);
        const newLight = isLightSquare(col, rank);
        if (existingLight === newLight) return false;
    }

    // King (Grade 3): must be in back rank; white king on dark, black king on light
    if (grade === 3) {
        if (rank !== backRank(currentTeam)) return false;
        const light = isLightSquare(col, rank);
        if (currentTeam === 'WHITE' && light) return false;   // white king on dark tile
        if (currentTeam === 'BLACK' && !light) return false;  // black king on light tile
    }

    return true;
}

// ─── Render board ─────────────────────────────────────────────────────────────
function renderBoard() {
    const boardEl = document.getElementById('ab-board');
    const rankLabels = document.getElementById('rank-labels');
    boardEl.innerHTML = '';
    rankLabels.innerHTML = '';

    const ranks = currentTeam === 'WHITE' ? [2,1] : [7,8];

    ranks.forEach(rank => {
        const lbl = document.createElement('div');
        lbl.className = 'ab-rank-label';
        lbl.textContent = rank;
        rankLabels.appendChild(lbl);

        COLS.forEach(col => {
            const cell = document.createElement('div');
            const light = isLightSquare(col, rank);
            cell.className = 'ab-cell ' + (light ? 'light' : 'dark');
            cell.dataset.col = col;
            cell.dataset.rank = rank;

            const piece = board[col][rank];
            if (piece) {
                const pDef = PIECES.find(p => p.type === piece);
                const icon = pDef
                    ? createPieceIconEl(pDef, currentTeam, 'ab-board-sprite')
                    : (() => { const s = document.createElement('span'); s.textContent = '?'; s.className = 'piece-white'; return s; })();
                icon.classList.add('ab-piece');
                cell.appendChild(icon);
                cell.addEventListener('contextmenu', e => { e.preventDefault(); removePiece(col, rank); });
                cell.addEventListener('click', () => removePiece(col, rank));
                cell.title = 'Right-click or click to remove';
            } else {
                if (selectedPieceType && canPlace(selectedPieceType, col, rank)) {
                    cell.classList.add('ab-valid');
                    cell.addEventListener('click', () => placePiece(selectedPieceType, col, rank));
                } else if (selectedPieceType) {
                    cell.classList.add('ab-invalid-dim');
                }
            }

            boardEl.appendChild(cell);
        });
    });

    // Rebuild palette DOM only when team changes; otherwise just update counts/state
    if (lastPaletteTeam !== currentTeam) {
        buildPalette();
        lastPaletteTeam = currentTeam;
    } else {
        updatePaletteState();
    }
    validateAndShowStatus();
}

// ─── Place / remove ───────────────────────────────────────────────────────────
function placePiece(pieceType, col, rank) {
    if (!canPlace(pieceType, col, rank)) return;
    board[col][rank] = pieceType;
    renderBoard();
}

function removePiece(col, rank) {
    delete board[col][rank];
    renderBoard();
}

// ─── Grade filter ────────────────────────────────────────────────────────────
function setGradeFilter(grade) {
    currentGradeFilter = grade;
    document.querySelectorAll('.ab-grade-tab').forEach(t => {
        t.classList.toggle('active', parseInt(t.dataset.grade) === grade);
    });
    if (selectedPieceType) {
        const pd = PIECES.find(p => p.type === selectedPieceType);
        if (pd && pd.grade !== grade) selectedPieceType = null;
    }
    buildPalette();
    renderBoard();
}

// ─── Render palette (3-column grid, icon only, i-button for info) ─────────────
function buildPalette() {
    const pal = document.getElementById('piece-palette');
    pal.innerHTML = '';
    pal.style.display = 'grid';
    pal.style.gridTemplateColumns = 'repeat(3, 1fr)';
    pal.style.gap = '6px';

    const filtered = PIECES.filter(p => p.grade === currentGradeFilter && isUnlockedForUser(p.type));
    filtered.forEach(pDef => {
        const count = countOnBoard(pDef.type);
        const max = GRADE_MAX[pDef.grade];
        const exhausted = count >= max;
        const selected = selectedPieceType === pDef.type;

        const btn = document.createElement('button');
        btn.dataset.type = pDef.type;
        btn.className = 'ab-piece-btn' + (selected ? ' selected' : '') + (exhausted ? ' exhausted' : '');
        btn.title = pDef.label;
        btn.style.cssText = 'position:relative;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;padding:8px 4px;min-height:70px;width:100%';

        // Icon
        const iconWrap = document.createElement('span');
        iconWrap.className = 'ab-piece-icon';
        iconWrap.style.fontSize = '1.6rem';
        const icon = createPieceIconEl(pDef, currentTeam, 'ab-palette-sprite');
        iconWrap.appendChild(icon);
        btn.appendChild(iconWrap);

        // Count badge only
        const countSpan = document.createElement('span');
        countSpan.className = 'ab-piece-count' + (count > 0 ? ' used' : '');
        countSpan.textContent = count + '/' + max;
        countSpan.style.fontSize = '10px';
        btn.appendChild(countSpan);

        btn.addEventListener('click', () => {
            const c = countOnBoard(pDef.type);
            if (c >= GRADE_MAX[pDef.grade]) return;
            selectedPieceType = (selectedPieceType === pDef.type) ? null : pDef.type;
            renderBoard();
        });

        const infoBtn = document.createElement('button');
        infoBtn.className = 'ab-info-btn';
        infoBtn.title = 'Piece info: ' + pDef.label;
        infoBtn.textContent = 'i';
        infoBtn.addEventListener('click', e => {
            e.stopPropagation();
            showPieceInfo(pDef.type);
        });
        btn.appendChild(infoBtn);

        pal.appendChild(btn);
    });
}

function updatePaletteState() {
    const pal = document.getElementById('piece-palette');
    PIECES.filter(p => isUnlockedForUser(p.type)).forEach(pDef => {
        const btn = pal.querySelector('[data-type="' + pDef.type + '"]');
        if (!btn) return;
        const count = countOnBoard(pDef.type);
        const max = GRADE_MAX[pDef.grade];
        const exhausted = count >= max;
        const selected = selectedPieceType === pDef.type;
        btn.className = 'ab-piece-btn' + (selected ? ' selected' : '') + (exhausted ? ' exhausted' : '');
        const countSpan = btn.querySelector('.ab-piece-count');
        if (countSpan) {
            countSpan.className = 'ab-piece-count' + (count > 0 ? ' used' : '');
            countSpan.textContent = count + '/' + max;
        }
    });
}

// ─── Playability check ───────────────────────────────────────────────────────
function isArmyPlayable() {
    // Build an 8×8 board with only this team's pieces (row = 8 - rank)
    const fb = Array.from({length:8}, () => Array(8).fill(null));
    const plist = [];
    COLS.forEach((c, ci) => {
        Object.keys(board[c]).forEach(rs => {
            const rank = parseInt(rs);
            const ri = 8 - rank;
            fb[ri][ci] = board[c][rank];
            plist.push({row:ri, col:ci, type:board[c][rank]});
        });
    });

    const fwdD = currentTeam === 'WHITE' ? -1 : 1;
    function inB(r,c){ return r>=0&&r<8&&c>=0&&c<8; }
    function empty(r,c){ return !fb[r][c]; }

    for (const {row, col, type} of plist) {
        const pd = PIECES.find(p => p.type === type);
        if (!pd) continue;
        const gc = pd.gameChar;

        if (gc === 'k') {
            // King: adjacent empty square
            for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
                if (inB(row+dr,col+dc)&&empty(row+dr,col+dc)) return true;
            }
            continue;
        }
        if (gc === 'e') {
            // Evil Pawn: move to empty forward-diagonals
            for (const dc of [-1,1]) {
                if (inB(row+fwdD,col+dc)&&empty(row+fwdD,col+dc)) return true;
            }
            continue;
        }
        if (gc === 'l') {
            // Lancer: slide forward up to 3, or step back 1
            for (let i=1;i<=3;i++) {
                const nr=row+fwdD*i;
                if (!inB(nr,col)) break;
                if (!empty(nr,col)) break;
                return true;
            }
            if (inB(row-fwdD,col)&&empty(row-fwdD,col)) return true;
            continue;
        }
        if (gc === 'y') {
            // Prince: forward-diagonals (ray) and backward straight (ray)
            for (const [dr,dc] of [[fwdD,-1],[fwdD,1],[-fwdD,0]]) {
                for (let i=1;i<8;i++) {
                    const nr=row+dr*i,nc=col+dc*i;
                    if (!inB(nr,nc)) break;
                    if (!empty(nr,nc)) break;
                    return true;
                }
            }
            continue;
        }
        if (gc === 'd') {
            // Duke: Z-jump (jumps, ignores blocking)
            for (const [dr,dc] of [[-2,3],[-2,1],[-2,-1],[-2,-3],[2,3],[2,1],[2,-1],[2,-3]]) {
                if (inB(row+dr,col+dc)&&empty(row+dr,col+dc)) return true;
            }
            continue;
        }
        if (gc === 'z') {
            // Warden: jump anywhere in 5×5
            for (let dr=-2;dr<=2;dr++) for (let dc=-2;dc<=2;dc++) {
                if (dr===0&&dc===0) continue;
                if (inB(row+dr,col+dc)&&empty(row+dr,col+dc)) return true;
            }
            continue;
        }
        if (gc === 'c') { // Feather: checkers diagonal
            for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) {
                if (inB(row+dr,col+dc)&&empty(row+dr,col+dc)) return true;
            }
            continue;
        }
        if (gc === 'm') { // Lantern: diagonal jumper range 2
            for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) {
                if (inB(row+dr,col+dc)&&empty(row+dr,col+dc)) return true;
                if (inB(row+2*dr,col+2*dc)&&empty(row+2*dr,col+2*dc)) return true;
            }
            continue;
        }
        if (gc === 't') { // Wizard: same-color square in 5x5
            const myColor=(row+col)%2;
            for (let dr=-2;dr<=2;dr++) for (let dc=-2;dc<=2;dc++) {
                if (dr===0&&dc===0) continue;
                if (!inB(row+dr,col+dc)) continue;
                if ((row+dr+col+dc)%2!==myColor) continue;
                if (empty(row+dr,col+dc)) return true;
            }
            continue;
        }
        if (gc === 'u') { // Oracle: king movement
            for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
                if (inB(row+dr,col+dc)&&empty(row+dr,col+dc)) return true;
            }
            continue;
        }
        if (gc === 'w') { // Eclipse: rook on dark, bishop on light
            const isDark=(row+col)%2===1;
            const dirs=isDark?[[-1,0],[1,0],[0,-1],[0,1]]:[[-1,-1],[-1,1],[1,-1],[1,1]];
            for (const [dr,dc] of dirs) {
                if (inB(row+dr,col+dc)&&empty(row+dr,col+dc)) return true;
            }
            continue;
        }
        if (pd.special) {
            // Standard pawn: move forward to empty square
            if (inB(row+fwdD,col)&&empty(row+fwdD,col)) return true;
            continue;
        }

        // Generic flag-based piece
        if (pd.lshape) {
            for (const [dr,dc] of [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]) {
                if (inB(row+dr,col+dc)&&empty(row+dr,col+dc)) return true;
            }
        }
        const dirs = [];
        if (pd.fwd)  dirs.push([fwdD,0]);
        if (pd.bwd)  dirs.push([-fwdD,0]);
        if (pd.side) { dirs.push([0,-1]); dirs.push([0,1]); }
        if (pd.diag) { dirs.push([-1,-1]); dirs.push([-1,1]); dirs.push([1,-1]); dirs.push([1,1]); }
        const maxR = (pd.range||0) === 0 ? 7 : pd.range;
        for (const [dr,dc] of dirs) {
            for (let i=1;i<=maxR;i++) {
                const nr=row+dr*i, nc=col+dc*i;
                if (!inB(nr,nc)) break;
                if (!empty(nr,nc)) { if (!pd.jump) break; continue; }
                return true;
            }
        }
    }
    return false;
}

// ─── Validation ──────────────────────────────────────────────────────────────
function validateArmy() {
    const errors = [];
    const ranges = validRanks(currentTeam);
    const br = backRank(currentTeam);

    // All 16 squares must be filled
    const total = COLS.reduce((s, c) => s + Object.keys(board[c]).length, 0);
    if (total < BOARD_SIZE) {
        errors.push('All 16 squares must be filled (' + total + '/16 placed).');
    }

    // King or Oracle must exist (exactly 1 Grade-3 piece)
    const kingLikeTypes = PIECES.filter(p => p.grade === 3).map(p => p.type);
    const kingLikeCount = kingLikeTypes.reduce((s, t) => s + countOnBoard(t), 0);
    if (kingLikeCount === 0) {
        errors.push('Army needs exactly 1 King (or King-tier piece).');
    } else if (kingLikeCount > 1) {
        errors.push('Army can only have 1 King-tier piece.');
    }

    // King-tier pieces must be in back rank; white king on dark tile, black king on light tile
    kingLikeTypes.forEach(t => {
        getPlacedOfType(t).forEach(k => {
            if (k.rank !== br) {
                errors.push(PIECES.find(p=>p.type===t).label+' must be in the back rank (rank ' + br + ').');
            } else {
                const light = isLightSquare(k.col, k.rank);
                if (currentTeam === 'WHITE' && light) {
                    errors.push('White '+PIECES.find(p=>p.type===t).label+' must be on a dark square (e.g. A1, C1, E1, G1).');
                }
                if (currentTeam === 'BLACK' && !light) {
                    errors.push('Black '+PIECES.find(p=>p.type===t).label+' must be on a light square (e.g. A8, C8, E8, G8).');
                }
            }
        });
    });

    // Grade 1: if 2 same type, must be different colors
    PIECES.filter(p => p.grade === 1).forEach(pDef => {
        const placed = getPlacedOfType(pDef.type);
        if (placed.length === 2) {
            const l0 = isLightSquare(placed[0].col, placed[0].rank);
            const l1 = isLightSquare(placed[1].col, placed[1].rank);
            if (l0 === l1) {
                errors.push('Both ' + pDef.label + 's are on ' + (l0 ? 'light' : 'dark') + ' squares, they must be on different colors.');
            }
        }
    });

    // Grade 2 total cap
    if (countGrade2OnBoard() > GRADE_MAX_G2_TOTAL) {
        errors.push('Maximum ' + GRADE_MAX_G2_TOTAL + ' Grade-2 pieces allowed.');
    }

    // Army must have at least one piece that can make a move from the starting position
    if (total === BOARD_SIZE && errors.length === 0 && !isArmyPlayable()) {
        errors.push('This army is completely immobile at the start, no piece can make a move. Try changing the piece arrangement.');
    }

    return errors;
}

function validateAndShowStatus() {
    const statusEl = document.getElementById('ab-status');
    const errors = validateArmy();
    const total = COLS.reduce((s, c) => s + Object.keys(board[c]).length, 0);

    if (total === 0) {
        statusEl.className = 'ab-status ab-status-empty';
        statusEl.textContent = 'Fill all 16 squares. King must be in the back rank on its own color.';
    } else if (errors.length === 0) {
        statusEl.className = 'ab-status ab-status-ok';
        statusEl.textContent = '✓ Army is complete and ready to save!';
    } else {
        statusEl.className = 'ab-status ab-status-error';
        statusEl.innerHTML = errors.map(function(e) { return '&bull; ' + e; }).join('<br>');
    }
}

// ─── Army list rendering ──────────────────────────────────────────────────────
function renderArmyLists() {
    const teams = ['WHITE', 'BLACK'];
    teams.forEach(team => {
        const el = document.getElementById('army-list-' + team.toLowerCase());
        el.innerHTML = '';
        const mine = USER_ARMIES.filter(a => a.team === team);
        const countLabel = document.createElement('div');
        countLabel.className = 'ab-army-count-label';
        countLabel.textContent = mine.length + ' / 5 armies';
        el.appendChild(countLabel);
        if (mine.length === 0) {
            const empty = document.createElement('div');
            empty.className = 'ab-empty-list';
            empty.textContent = 'No armies yet.';
            el.appendChild(empty);
        }
        mine.forEach(a => {
            const row = document.createElement('div');
            row.className = 'ab-army-row' + (a.active ? ' ab-army-active' : '');
            const activeStar = a.active ? '<span class="ab-active-star" title="Active army">&#9733;</span>' : '';
            const activeBtn = a.active
                ? '<span class="ab-active-label">Active</span>'
                : '<form method="POST" action="' + CTX + '/setActiveArmy" style="display:inline"><input type="hidden" name="armyId" value="' + a.id + '"><button type="submit" class="ab-set-active-btn btn btn-outline ab-btn-xs">Set Active</button></form>';
            const delBtn = '<button class="btn btn-danger ab-btn-xs" style="margin-left:4px;padding:2px 8px;font-size:11px" onclick="deleteArmyById(' + a.id + ',\'' + escapeHtml(a.name) + '\')">&#128465;</button>';
            row.innerHTML =
                activeStar +
                '<a href="' + CTX + '/army-builder?loadId=' + a.id + '" class="ab-army-name ab-army-load-link">' + escapeHtml(a.name) + '</a>' +
                '<span class="ab-army-meta">' + a.pieceCount + 'p</span>' +
                activeBtn + delBtn;
            el.appendChild(row);
        });

        const presetEl = document.getElementById('preset-list-' + team.toLowerCase());
        if (presetEl) {
            presetEl.innerHTML = '';
            const pres = PRESET_ARMIES.filter(a => a.team === team);
            pres.forEach(a => {
                const row = document.createElement('div');
                row.className = 'ab-army-row ab-army-preset';
                const deleteBtn = IS_ADMIN
                    ? '<button class="btn btn-danger ab-btn-xs" style="padding:2px 8px;font-size:11px" onclick="deletePreset(' + a.id + ',\'' + escapeHtml(a.name) + '\')">&#128465;</button>'
                    : '';
                row.innerHTML =
                    '<span class="ab-army-name">' + escapeHtml(a.name) + '</span>' +
                    '<span class="ab-army-meta">' + a.pieceCount + ' pieces</span>' +
                    '<a href="' + CTX + '/army-builder?loadId=' + a.id + '" class="ab-army-load btn btn-outline ab-btn-xs">Load</a>' +
                    deleteBtn;
                presetEl.appendChild(row);
            });
        }
    });
}

function escapeHtml(str) {
    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ─── Team switching ───────────────────────────────────────────────────────────
function switchTeam(team) {
    currentTeam = team;
    selectedPieceType = null;
    initBoard(null);

    document.getElementById('tab-white').classList.toggle('active', team === 'WHITE');
    document.getElementById('tab-black').classList.toggle('active', team === 'BLACK');
    document.getElementById('army-list-white').style.display = team === 'WHITE' ? '' : 'none';
    document.getElementById('army-list-black').style.display = team === 'BLACK' ? '' : 'none';
    const pw = document.getElementById('preset-list-white');
    const pb = document.getElementById('preset-list-black');
    if (pw) pw.style.display = team === 'WHITE' ? '' : 'none';
    if (pb) pb.style.display = team === 'BLACK' ? '' : 'none';

    // If loaded army matches this team, restore it
    if (LOADED_ARMY && LOADED_ARMY.team === team) {
        loadArmyIntoBuilder(LOADED_ARMY);
    } else {
        document.getElementById('army-name').value = '';
        document.getElementById('army-id').value = '';
        document.getElementById('btn-delete').style.display = 'none';
    }
    renderBoard();
}

// ─── Editing banner ───────────────────────────────────────────────────────────
function updateBanner(name, team) {
    const banner = document.getElementById('editing-banner');
    const bannerName = document.getElementById('banner-name');
    const bannerTeam = document.getElementById('banner-team');
    if (name) {
        bannerName.textContent = name;
        bannerTeam.textContent = team || currentTeam;
        bannerTeam.className = 'ab-editing-team ' + (team || currentTeam).toLowerCase();
        banner.style.display = 'flex';
    } else {
        banner.style.display = 'none';
    }
}

// ─── Load army into builder ───────────────────────────────────────────────────
function loadArmyIntoBuilder(army) {
    document.getElementById('army-name').value = army.name;
    document.getElementById('army-id').value = army.id;
    document.getElementById('btn-delete').style.display = '';
    if (IS_ADMIN) {
        const cb = document.getElementById('cb-preset');
        if (cb) cb.checked = army.preset;
    }
    initBoard(army.pieces);
    updateBanner(army.name, army.team);
}

// Keep banner in sync with name input changes
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('army-name').addEventListener('input', function() {
        const id = document.getElementById('army-id').value;
        if (id) updateBanner(this.value || '(unnamed)', currentTeam);
    });
});

// ─── Clear board ──────────────────────────────────────────────────────────────
function clearBoard() {
    document.getElementById('army-name').value = '';
    document.getElementById('army-id').value = '';
    document.getElementById('btn-delete').style.display = 'none';
    selectedPieceType = null;
    initBoard(null);
    updateBanner(null);
    renderBoard();
}

// ─── Save army ────────────────────────────────────────────────────────────────
function saveArmy() {
    const name = document.getElementById('army-name').value.trim();
    if (!name) {
        alert('Please enter an army name.');
        document.getElementById('army-name').focus();
        return;
    }
    const errors = validateArmy();
    if (errors.length > 0) {
        alert('Fix validation errors before saving:\n\n' + errors.join('\n'));
        return;
    }

    // Enforce 5-army-per-team limit client-side for new armies
    const editId = document.getElementById('army-id').value;
    if (!editId && !IS_ADMIN) {
        const sameTeamCount = USER_ARMIES.filter(a => a.team === currentTeam).length;
        if (sameTeamCount >= 5) {
            alert('You already have 5 ' + currentTeam.toLowerCase() + ' armies. Delete one before saving a new one.');
            return;
        }
    }

    const pieces = [];
    COLS.forEach(col => {
        Object.keys(board[col]).forEach(rank => {
            pieces.push({ pieceType: board[col][rank], col, rank: parseInt(rank) });
        });
    });

    document.getElementById('f-name').value = name;
    document.getElementById('f-team').value = currentTeam;
    document.getElementById('f-armyId').value = document.getElementById('army-id').value;
    document.getElementById('f-piecesJson').value = JSON.stringify(pieces);

    if (IS_ADMIN) {
        const cb = document.getElementById('cb-preset');
        const fp = document.getElementById('f-preset');
        if (cb && fp) fp.value = cb.checked ? 'true' : 'false';
    }

    document.getElementById('save-form').submit();
}

// ─── Delete army ──────────────────────────────────────────────────────────────
function deleteCurrentArmy() {
    const id = document.getElementById('army-id').value;
    if (!id) return;
    if (!confirm('Delete this army? This cannot be undone.')) return;
    document.getElementById('d-armyId').value = id;
    document.getElementById('delete-form').submit();
}

// ─── Delete army by ID directly from list ─────────────────────────────────────
function deleteArmyById(id, name) {
    if (!confirm('Delete "' + name + '"? This cannot be undone.')) return;
    document.getElementById('d-armyId').value = id;
    document.getElementById('delete-form').submit();
}

// ─── Delete preset (admin only) ───────────────────────────────────────────────
function deletePreset(id, name) {
    if (!confirm('Delete preset army "' + name + '"? This cannot be undone.')) return;
    document.getElementById('d-armyId').value = id;
    document.getElementById('delete-form').submit();
}

// ─── Piece info ───────────────────────────────────────────────────────────────
const PIECE_INFO = {
    PAWN:         { movement: 'Marches one square forward to an empty square. Captures one square diagonally forward.', lore: 'The backbone of any army. The pawn endures all hardships and never retreats, always pressing toward destiny.' },
    EVIL_PAWN:    { movement: 'Moves diagonally forward to empty squares. Captures straight ahead.', lore: 'A twisted soul who ignores convention, striking before enemies can react and slipping sideways through every gap.' },
    SQUIRE:       { movement: 'Moves 1 square forward or 1 square sideways. Captures in the same squares it can reach.', lore: 'A loyal footsoldier who holds the flank as easily as the front. Slower than a knight but steady, it slides into gaps a pawn cannot reach.' },
    LONGPAW:      { movement: 'Always advances 1 or 2 squares forward to empty squares. Captures 1 square diagonally forward.', lore: 'The Longpaw never hesitates. Where a common pawn weighs its first step, this one charges headlong at full stride from the moment it enters the field.' },
    RETREATER:    { movement: 'Moves 1 square forward or 1 square backward to empty or enemy squares.', lore: 'Not every soldier charges blindly ahead. The Retreater commits, withdraws, and commits again, using ground itself as a weapon.' },
    HOLLOW:       { movement: 'Advances 1 or 2 squares forward, leaping over any piece in the way. Captures 1 square diagonally forward.', lore: 'Light and hollow inside, it drifts through the packed front lines without resistance. Friends, enemies, obstacles of every kind barely register as it glides past.' },
    CRAWLER:      { movement: 'Slides 1 square sideways to empty squares only. Captures 1 square straight ahead.', lore: 'The Crawler sidesteps the chaos rather than charging through it. Patient and lateral, it seizes its moment to strike forward with precise, unexpected aggression.' },
    KNIGHT:       { movement: 'Leaps in an L-shape: 2 squares in one direction and 1 to the side. Can jump over pieces.', lore: 'A rider of shadows, arriving where least expected and vanishing before the dust settles.' },
    ROOK:         { movement: 'Slides any number of squares in a straight line.', lore: 'A fortress on legs, commanding the open files. What stands in its path is either moved aside or crushed.' },
    BISHOP:       { movement: 'Slides any number of squares diagonally.', lore: 'A diagonal prophet who never strays from its ordained color. Patient, precise, and dangerous at range.' },
    JESTER:       { movement: 'Moves up to 2 squares in any direction.', lore: 'The court fool dances erratically, laughing all the way to the battlefield. Unpredictable and surprisingly versatile.' },
    LANCER:       { movement: 'Charges up to 3 squares forward (or 4 to capture). Can retreat 1 square backward but cannot capture retreating.', lore: 'Born to pierce, the Lancer drives deep into enemy lines and never truly looks back.' },
    PRINCE:       { movement: 'Slides diagonally forward or straight backward at any distance.', lore: 'Ambitious yet cautious, the Prince advances boldly along his chosen angles but always preserves an escape route behind.' },
    DUKE:         { movement: 'Jumps in a Z-pattern: 2 rows and 1 or 3 columns. Ignores all pieces in between.', lore: 'A noble eccentric who wears impossible paths as a badge of honor. The Duke goes where geometry fears to tread.' },
    HERBALIST:    { movement: 'Moves diagonally. Captures any adjacent piece in king range. Any piece that captures the Herbalist is also immediately removed.', lore: 'What poisons the Herbalist poisons you. Handle with great care, for its parting gift is devastation.' },
    BIRD:         { movement: 'Slides along straight lines. Can also jump over all pieces to reach the farthest empty square in each cardinal direction.', lore: 'Swift and unpredictable, the Bird soars above obstacles without a second glance, landing at the far edge of every horizon.' },
    BEAST_HANDLER:{ movement: 'Moves 1 square in any direction. Every 5 moves, it summons Beasts in adjacent empty squares. Beasts last 4 turns and can move 1 square forward to empty squares or capture the piece directly ahead.', lore: 'A warden of wild things who knows that true power lies in what follows. Patient, methodical, and never alone.' },
    SHIELD:       { movement: 'Slides sideways in any direction. Can jump to the farthest empty square sideways. Can also step to specific squares behind and to the side.', lore: 'The Shield guards the flanks, a bulwark that repositions across the board to where it is needed most.' },
    EAGLE:        { movement: 'Jumps exactly 3 squares in any cardinal direction. Cannot be blocked.', lore: 'High above the fray, the Eagle strikes from a precise altitude. Nothing between it and its target matters.' },
    LANTERN:      { movement: 'Moves up to 2 squares diagonally, jumping over any piece in between. When it captures, all pieces in adjacent squares cannot move on the opponent\'s next turn.', lore: 'Where its light falls, the battlefield freezes. Enemies caught in its glow are paralyzed, unable to act until the glow fades.' },
    ECLIPSE:      { movement: 'When standing on a dark square, slides like a Rook. When standing on a light square, slides like a Bishop.', lore: 'Neither fully one nor the other, the Eclipse is defined entirely by where it stands. Change its ground and change its nature.' },
    QUEEN:        { movement: 'Slides any number of squares in any direction: straight or diagonal.', lore: 'The most powerful force on the board, commanding every axis at once. Where the Queen moves, others obey.' },
    WARDEN:       { movement: 'Moves up to 2 squares in any direction. Can only capture pieces that are exactly 1 square away.', lore: 'A patient guardian who controls a broad domain but strikes with careful precision. The Warden does not waste energy.' },
    PRINCESS:     { movement: 'Moves up to 2 squares in any direction and can jump over pieces. Friendly pieces within 2 squares gain 1 extra square of range.', lore: 'A radiant figure whose very presence emboldens those around her. Under her watch, allies reach further than they ever could alone.' },
    BOOT:         { movement: 'Moves to any empty square on the board, jumping over all pieces. Can also capture any adjacent piece.', lore: 'No obstacle stops the Boot. It stomps wherever it pleases, leaping piece or no piece in the way, then strikes nearby at will.' },
    FEATHER:      { movement: 'Moves 1 square diagonally to an empty square. Captures by jumping over an adjacent enemy and landing on the empty square beyond.', lore: 'Light as a feather, it drifts across the board with graceful leaps, never colliding head-on. It passes through danger rather than meeting it.' },
    WIZARD:       { movement: 'Teleports to any empty square of the same board color within a 5x5 area. Instead of capturing, can swap positions with any enemy piece on a same-color square within range.', lore: 'The Wizard does not fight. It rearranges, shifting reality to suit its inscrutable designs. Enemies find themselves displaced rather than destroyed.' },
    ORACLE:       { movement: 'Moves 1 square in any direction like a King. Once per game, may curse an empty tile. Any piece, friend or foe, that steps onto the cursed tile is instantly removed.', lore: 'The Oracle sees futures none can escape. Mark the ground and let fate do its work. Even allies must tread carefully around what has been foretold.' },
    KING:         { movement: 'Moves 1 square in any direction. Can castle with an unmoved Rook if the squares between them are clear and neither is in check.', lore: 'The heart of every war. The King does not charge, it endures. Every sacrifice, every gambit, every maneuver on the board exists to keep this one soul alive.' },
    COIL:         { movement: 'Slides in a zigzag pattern in each cardinal direction: one step straight, then alternating diagonally left and right. Continues until blocked or the board edge.', lore: 'The Coil does not travel in straight lines, it writhes. Those who think they see its path find it has already coiled around them.' },
    CHOIR:        { movement: 'Alternates each turn between sliding like a Rook (straight lines) and sliding like a Bishop (diagonals). The mode switches every move.', lore: 'The Choir does not repeat itself. Its voice shifts from harmony to dissonance every turn, and those who expect the same song twice are already lost.' },
    HUSK:         { movement: 'Moves 1 square in any direction like a King. Each capture permanently extends its reach by 1 extra square in all directions.', lore: 'Empty inside, the Husk consumes to grow. With each enemy it destroys, it absorbs something of what it killed, reaching further with every death it causes.' },
    HYDRA:        { movement: 'Slides up to 3 squares in any direction (queen pattern, limited range). Has 3 heads: survives each checkmate or check attempt by losing a head instead.', lore: 'Cut it down and it rises again. The Hydra cannot be so easily slain, each defeat costs it only a head, and it begins with three.' },
    LIBRARY:      { movement: 'Copies the moveset of the last enemy piece it captured. Before any capture, falls back to king-pattern movement (1 square any direction).', lore: 'The Library does not create, it collects. Every fallen enemy becomes knowledge, its secrets now wielded against the allies it once served.' },
    FORK:         { movement: 'Slides up to 2 squares orthogonally (+), then up to 3 squares sideways from the tip of each arm (T-shape). Also steps 1 square diagonally. When directly attacked, the Fork cannot move — allies must defend it.', lore: 'The Fork divides and controls, its reach splitting like tines across the board. But threaten it and it freezes, holding its ground, waiting for others to clear the path.' },
};

const GRADE_LABELS = { 0: 'Grade 0 (Pawn)', 1: 'Grade 1 (Minor)', 2: 'Grade 2 (Major)', 3: 'Grade 3 (King-tier)' };

// ─── Movement pattern mini board ──────────────────────────────────────────────
function getMovePatternSquares(pDef) {
    const gc = pDef.gameChar;
    const CR = 4, CC = 4; // center of 9×9 display area on an 8×8 board
    const walk = [], capture = [];

    function inBd(r,c) { return r>=0&&r<8&&c>=0&&c<8; }

    // Special pieces with distinct walk vs capture squares
    if (pDef.special) { // Pawn (white moves up = row -1)
        if (inBd(CR-1,CC)) walk.push([CR-1,CC]);
        if (inBd(CR-2,CC)) walk.push([CR-2,CC]);
        for (const dc of [-1,1]) if (inBd(CR-1,CC+dc)) capture.push([CR-1,CC+dc]);
        return {walk, capture};
    }
    if (gc === 'e') { // Evil Pawn
        for (const dc of [-1,1]) if (inBd(CR-1,CC+dc)) walk.push([CR-1,CC+dc]);
        if (inBd(CR-1,CC)) capture.push([CR-1,CC]);
        return {walk, capture};
    }
    if (gc === 'sq') { // Squire: 1 forward or 1 sideways
        const both=[];
        if (inBd(CR-1,CC)) both.push([CR-1,CC]);
        for (const dc of [-1,1]) if (inBd(CR,CC+dc)) both.push([CR,CC+dc]);
        return {walk:both, capture};
    }
    if (gc === 'lp') { // Longpaw: 1-2 forward walk, diagonal forward capture
        if (inBd(CR-1,CC)) walk.push([CR-1,CC]);
        if (inBd(CR-2,CC)) walk.push([CR-2,CC]);
        for (const dc of [-1,1]) if (inBd(CR-1,CC+dc)) capture.push([CR-1,CC+dc]);
        return {walk, capture};
    }
    if (gc === 'rt') { // Retreater: 1 forward or 1 backward
        const both=[];
        if (inBd(CR-1,CC)) both.push([CR-1,CC]);
        if (inBd(CR+1,CC)) both.push([CR+1,CC]);
        return {walk:both, capture};
    }
    if (gc === 'ho') { // Hollow: 1-2 forward walk (jump), diagonal forward capture
        if (inBd(CR-1,CC)) walk.push([CR-1,CC]);
        if (inBd(CR-2,CC)) walk.push([CR-2,CC]);
        for (const dc of [-1,1]) if (inBd(CR-1,CC+dc)) capture.push([CR-1,CC+dc]);
        return {walk, capture};
    }
    if (gc === 'cr') { // Crawler: 1 sideways walk, 1 forward capture
        for (const dc of [-1,1]) if (inBd(CR,CC+dc)) walk.push([CR,CC+dc]);
        if (inBd(CR-1,CC)) capture.push([CR-1,CC]);
        return {walk, capture};
    }
    if (gc === 'h') { // Herbalist: moves diagonally, captures in king range
        for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) {
            for (let i=1;i<5;i++) { const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; walk.push([r,c]); }
        }
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) {
            const r=CR+dr,c=CC+dc; if(inBd(r,c)) capture.push([r,c]);
        }
        return {walk, capture};
    }
    if (gc === 'c') { // Feather: walk diagonally 1, capture by jumping
        for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) {
            const r1=CR+dr,c1=CC+dc; if(inBd(r1,c1)) walk.push([r1,c1]);
            const r2=CR+2*dr,c2=CC+2*dc; if(inBd(r1,c1)&&inBd(r2,c2)) capture.push([r2,c2]);
        }
        return {walk, capture};
    }

    // Generic: use movement flags to compute reachable squares (both walk+capture)
    const both = [];
    if (gc === 'l') { // Lancer
        for (let i=1;i<=3;i++) { const r=CR-i; if(inBd(r,CC)) both.push([r,CC]); }
        both.push([CR+1,CC]); // backward
        if (inBd(CR-4,CC)) capture.push([CR-4,CC]); // capture-only at 4th step
        return {walk: both, capture};
    }
    if (gc === 'y') { // Prince
        for (const [dr,dc] of [[-1,-1],[-1,1],[1,0]]) for (let i=1;i<5;i++) { const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'd') { // Duke
        for (const [dr,dc] of [[-2,3],[-2,1],[-2,-1],[-2,-3],[2,3],[2,1],[2,-1],[2,-3]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'z') { // Warden
        for (let dr=-2;dr<=2;dr++) for (let dc=-2;dc<=2;dc++) { if(!dr&&!dc) continue; const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'f') { // Bird
        for (const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        for (const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) { let er=CR+dr,ec=CC+dc,last=null; while(inBd(er,ec)){if(!(er===CR+dr&&ec===CC+dc))last=[er,ec];er+=dr;ec+=dc;} if(last) both.push(last); }
        return {walk: both, capture};
    }
    if (gc === 'g') { // Eagle
        for (const [dr,dc] of [[-3,0],[3,0],[0,-3],[0,3]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'm') { // Lantern
        for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) { [1,2].forEach(i=>{ const r=CR+dr*i,c=CC+dc*i; if(inBd(r,c)) both.push([r,c]); }); }
        return {walk: both, capture};
    }
    if (gc === 't') { // Wizard
        const myColor=(CR+CC)%2;
        for (let dr=-2;dr<=2;dr++) for (let dc=-2;dc<=2;dc++) { if(!dr&&!dc) continue; const r=CR+dr,c=CC+dc; if(inBd(r,c)&&(r+c)%2===myColor) both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'w') { // Eclipse — show both rook and bishop patterns
        for (const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) for (let i=1;i<4;i++) { const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; both.push([r,c]); }
        for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) for (let i=1;i<4;i++) { const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'o') { // Boot: teleport anywhere (show a few representative squares) + king captures
        [0,1,2,3,5,6,7].forEach(c=>both.push([0,c],[7,c]));
        [1,2,3,4,5,6].forEach(r=>[0,7].forEach(c=>both.push([r,c])));
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) capture.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'x') { // Coil: zigzag — show first few steps in each + direction
        for (const [dr,dc] of [[-1,0],[1,0],[0,1],[0,-1]]) {
            let cr=CR,cc=CC, side=1;
            for (let step=0;step<7;step++) {
                const nr=(step===0)?cr+dr:cr+dr+(dc===0?side:0);
                const nc=(step===0)?cc+dc:cc+dc+(dr===0?side:0);
                if(step===0){if(!inBd(cr+dr,cc+dc)) break; both.push([cr+dr,cc+dc]); cr+=dr; cc+=dc;}
                else { const sr=dr===0?side:0,sc=dc===0?side:0; const nr2=cr+dr+sr,nc2=cc+dc+sc; if(!inBd(nr2,nc2)) break; both.push([nr2,nc2]); cr=nr2; cc=nc2; side=-side; }
            }
        }
        return {walk: both, capture};
    }
    if (gc === 'ch') { // Choir: show both rook and bishop
        for (const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1],[-1,-1],[-1,1],[1,-1],[1,1]]) for (let i=1;i<5;i++) { const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'hk') { // Husk: king (range 1-3 shown)
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'hy') { // Hydra: queen range 3
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) for (let i=1;i<=3;i++) { const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'lb') { // Library: king fallback
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'fk') { // Fork: T-pattern + king diagonals
        for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        for (const [dr,dc] of [[-1,0],[1,0],[0,-1],[0,1]]) {
            const perpDirs = dr===0?[[-1,0],[1,0]]:[[0,-1],[0,1]];
            const r1=CR+dr,c1=CC+dc; if(!inBd(r1,c1)) continue; both.push([r1,c1]);
            const r2=CR+2*dr,c2=CC+2*dc; if(!inBd(r2,c2)) continue; both.push([r2,c2]);
            for (const [pdr,pdc] of perpDirs) for (let i=1;i<=1;i++) { const r=r2+pdr*i,c=c2+pdc*i; if(!inBd(r,c)) break; both.push([r,c]); }
        }
        return {walk: both, capture};
    }
    if (gc === 'i') { // Shield
        for (const dc of [-1,1]) for (let i=1;i<5;i++) { const c=CC+dc*i; if(!inBd(CR,c)) break; both.push([CR,c]); }
        both.push([CR-1,CC]);
        for (const [dr,dc] of [[1,-1],[1,0],[1,1],[2,0]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'a') { // Beast Handler
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 's') { // Princess: diagonals 1-2 + jumps
        for (const [dr,dc] of [[-1,-1],[-1,1],[1,-1],[1,1]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        for (const [dr,dc] of [[-2,0],[2,0],[0,-2],[0,2]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        return {walk: both, capture};
    }
    if (gc === 'u') { // Oracle
        for (const [dr,dc] of [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
        return {walk: both, capture};
    }

    // Generic flag-based
    if (pDef.lshape) {
        for (const [dr,dc] of [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]) { const r=CR+dr,c=CC+dc; if(inBd(r,c)) both.push([r,c]); }
    }
    const dirs = [];
    if (pDef.fwd)  dirs.push([-1,0]);
    if (pDef.bwd)  dirs.push([1,0]);
    if (pDef.side) { dirs.push([0,-1]); dirs.push([0,1]); }
    if (pDef.diag) { dirs.push([-1,-1]); dirs.push([-1,1]); dirs.push([1,-1]); dirs.push([1,1]); }
    const maxR = pDef.range === 0 ? 5 : pDef.range;
    for (const [dr,dc] of dirs) {
        for (let i=1;i<=maxR;i++) { const r=CR+dr*i,c=CC+dc*i; if(!inBd(r,c)) break; both.push([r,c]); }
    }
    return {walk: both, capture};
}

function renderPatternBoard(pDef) {
    const container = document.getElementById('piPatternBoard');
    container.innerHTML = '';
    const {walk, capture} = getMovePatternSquares(pDef);
    const walkSet = new Set(walk.map(([r,c]) => r+','+c));
    const captureSet = new Set(capture.map(([r,c]) => r+','+c));
    const CR = 4, CC = 4;
    const CELL = 32;
    const wrapper = document.createElement('div');
    wrapper.style.cssText = 'display:inline-block;border:1px solid var(--border);border-radius:4px;overflow:hidden';
    const grid = document.createElement('div');
    grid.style.cssText = 'display:grid;grid-template-columns:repeat(8,'+CELL+'px);grid-template-rows:repeat(8,'+CELL+'px)';
    for (let r=0;r<8;r++) for (let c=0;c<8;c++) {
        const cell = document.createElement('div');
        const light = (r+c)%2===0;
        const key = r+','+c;
        const isWalk = walkSet.has(key);
        const isCapture = captureSet.has(key);
        const isCenter = r===CR&&c===CC;
        cell.style.cssText = 'width:'+CELL+'px;height:'+CELL+'px;position:relative;display:flex;align-items:center;justify-content:center;font-size:18px;';
        if (isCenter) {
            cell.style.background = light ? '#d4e0a8' : '#8faa60';
        } else if (isWalk && isCapture) {
            cell.style.background = light ? 'rgba(100,170,100,0.55)' : 'rgba(60,140,60,0.65)';
        } else if (isWalk) {
            cell.style.background = light ? 'rgba(100,170,100,0.55)' : 'rgba(60,140,60,0.65)';
        } else if (isCapture) {
            cell.style.background = light ? (light ? 'rgba(220,80,80,0.2)' : 'rgba(220,80,80,0.3)') : 'rgba(220,80,80,0.3)';
        } else {
            cell.style.background = light ? 'var(--board-light, #c2d3e4)' : 'var(--board-dark, #5377a2)';
        }
        if (isCenter) {
            const icon = createPieceIconEl(pDef, 'WHITE', 'ab-board-sprite');
            icon.style.cssText = 'width:26px;height:26px;font-size:20px;line-height:1';
            cell.appendChild(icon);
        } else if (isCapture && !isWalk) {
            const dot = document.createElement('div');
            dot.style.cssText = 'width:10px;height:10px;border-radius:50%;background:rgba(220,60,60,0.9);';
            cell.appendChild(dot);
        } else if ((isWalk || isCapture) && !isCenter) {
            const dot = document.createElement('div');
            dot.style.cssText = 'width:10px;height:10px;border-radius:50%;background:rgba(60,180,60,0.75);';
            cell.appendChild(dot);
        }
        grid.appendChild(cell);
    }
    wrapper.appendChild(grid);
    container.appendChild(wrapper);
    container.style.textAlign = 'center';
}

function showPieceInfo(type) {
    const info = PIECE_INFO[type];
    const pd = PIECES.find(p => p.type === type);
    if (!info || !pd) return;
    document.getElementById('piName').textContent = pd.label;
    document.getElementById('piGrade').textContent = GRADE_LABELS[pd.grade] || ('Grade ' + pd.grade);
    document.getElementById('piMovement').textContent = info.movement;
    document.getElementById('piLore').textContent = info.lore;
    renderPatternBoard(pd);
    document.getElementById('pieceInfoOverlay').style.display = 'flex';
}
function closePieceInfo() {
    document.getElementById('pieceInfoOverlay').style.display = 'none';
}

// ─── Init ─────────────────────────────────────────────────────────────────────
(function init() {
    initBoard(null);
    renderArmyLists();

    if (LOADED_ARMY) {
        currentTeam = LOADED_ARMY.team;
        document.getElementById('tab-white').classList.toggle('active', currentTeam === 'WHITE');
        document.getElementById('tab-black').classList.toggle('active', currentTeam === 'BLACK');
        document.getElementById('army-list-white').style.display = currentTeam === 'WHITE' ? '' : 'none';
        document.getElementById('army-list-black').style.display = currentTeam === 'BLACK' ? '' : 'none';
        const pw = document.getElementById('preset-list-white');
        const pb = document.getElementById('preset-list-black');
        if (pw) pw.style.display = currentTeam === 'WHITE' ? '' : 'none';
        if (pb) pb.style.display = currentTeam === 'BLACK' ? '' : 'none';
        loadArmyIntoBuilder(LOADED_ARMY);
    }
    renderBoard();
})();
</script>

<div class="piece-info-overlay" id="pieceInfoOverlay" style="display:none" onclick="if(event.target===this) closePieceInfo()">
    <div class="piece-info-box">
        <button class="piece-info-close" onclick="closePieceInfo()">&times;</button>
        <h2 id="piName"></h2>
        <div class="piece-info-grade" id="piGrade"></div>
        <h3>Movement</h3>
        <div id="piPatternBoard" style="margin-bottom:12px"></div>
        <p id="piMovement"></p>
        <h3>Lore</h3>
        <p id="piLore"></p>
    </div>
</div>
</main>
</div>
</body>
</html>
