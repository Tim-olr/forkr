'use strict';
// piece-art.js — inline SVG piece renderer for all piece types.
// ViewBox: 0 0 45 45. White: fill=#fefbf2/stroke=#1a1408. Black: fill=#1a1408/stroke=#fefbf2.
// Exposes window.buildPieceSVG(char, isWhite) → SVGSVGElement

(function () {

    // Attribute shorthands — placeholders FG/ST/AC replaced at render time.
    var B  = ' fill="FG" stroke="ST" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"';
    var AA = ' fill="AC" stroke="AC" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"';
    var A  = ' fill="AC" stroke="none"';

    // Shared components
    var PED = '<path'+B+' d="M11 36 L34 36 L35 39 L10 39 Z"/>'
            + '<path'+B+' d="M8 39 L37 39 L39 43 L6 43 Z"/>';
    var BOD = '<path'+B+' d="M14 26 L31 26 L31 36 L14 36 Z"/>';

    var ART = {

        // ── Grade 0 : Pawn-type ───────────────────────────────────────────────

        p:  '<circle'+B+' cx="22.5" cy="13" r="4.6"/>'
          + '<path'+B+' d="M18 17 L27 17 L28 22 L17 22 Z"/>'
          + '<path'+B+' d="M16 22 L29 22 L31 36 L14 36 Z"/>'
          + PED,

        e:  '<path'+B+' d="M17 7 L19 13 L20 13 L20 9 Z"/>'
          + '<path'+B+' d="M28 7 L26 13 L25 13 L25 9 Z"/>'
          + '<circle'+B+' cx="22.5" cy="14" r="4.6"/>'
          + '<path'+B+' d="M18 18 L27 18 L28 23 L17 23 Z"/>'
          + '<path'+B+' d="M16 23 L29 23 L31 36 L14 36 Z"/>'
          + PED,

        v:  '<path'+B+' d="M17 7 L19 13 L20 13 L20 9 Z"/>'
          + '<path'+B+' d="M28 7 L26 13 L25 13 L25 9 Z"/>'
          + '<circle'+B+' cx="22.5" cy="14" r="4.6"/>'
          + '<path'+B+' d="M18 18 L27 18 L28 23 L17 23 Z"/>'
          + '<path'+B+' d="M16 23 L29 23 L31 36 L14 36 Z"/>'
          + PED,

        sq: '<circle'+B+' cx="22.5" cy="13" r="4.6"/>'
          + '<path'+B+' d="M18 17 L27 17 L28 22 L17 22 Z"/>'
          + '<path'+B+' d="M16 22 L29 22 L31 36 L14 36 Z"/>'
          + PED,

        lp: '<circle'+B+' cx="22.5" cy="13" r="4.6"/>'
          + '<path'+B+' d="M18 17 L27 17 L28 22 L17 22 Z"/>'
          + '<path'+B+' d="M16 22 L29 22 L31 36 L14 36 Z"/>'
          + PED,

        rt: '<circle'+B+' cx="22.5" cy="13" r="4.6"/>'
          + '<path'+B+' d="M18 17 L27 17 L28 22 L17 22 Z"/>'
          + '<path'+B+' d="M16 22 L29 22 L31 36 L14 36 Z"/>'
          + PED,

        ho: '<circle'+B+' cx="22.5" cy="13" r="4.6"/>'
          + '<path'+B+' d="M18 17 L27 17 L28 22 L17 22 Z"/>'
          + '<path'+B+' d="M16 22 L29 22 L31 36 L14 36 Z"/>'
          + PED,

        cr: '<circle'+B+' cx="22.5" cy="13" r="4.6"/>'
          + '<path'+B+' d="M18 17 L27 17 L28 22 L17 22 Z"/>'
          + '<path'+B+' d="M16 22 L29 22 L31 36 L14 36 Z"/>'
          + PED,

        // ── Grade 1 : Minor pieces ────────────────────────────────────────────

        n:  '<path'+B+' d="M22 6 C27 6,31 10,32 16 L33 22 L32 27 L33 32 L34 36 L12 36 L12 32 C12 28,10 26,8 25 L4 24 L4 21 L7 20 L9 17 L12 14 L16 11 L19 8 Z"/>'
          + '<path'+B+' d="M19 4 L22 6 L20 9 Z"/>'
          + '<path'+AA+' d="M24 10 L30 14 L30 19 L27 16 Z"/>'
          + '<circle'+A+' cx="17" cy="14" r="1.1"/>'
          + '<circle'+A+' cx="8" cy="22" r="0.7"/>'
          + PED,

        b:  '<circle'+B+' cx="22.5" cy="7" r="1.8"/>'
          + '<path'+B+' d="M22.5 9 C16 10,14 18,14 24 L31 24 C31 18,29 10,22.5 9 Z"/>'
          + '<path fill="none" stroke="AC" stroke-width="1.4" stroke-linecap="round" d="M20 16 L25 21"/>'
          + '<path'+B+' d="M13 24 L32 24 L33 28 L12 28 Z"/>'
          + '<path'+B+' d="M13 28 L32 28 L31 36 L14 36 Z"/>'
          + PED,

        r:  '<path'+B+' d="M11 8 L15 8 L15 12 L18 12 L18 8 L22 8 L22 12 L23 12 L23 8 L27 8 L27 12 L30 12 L30 8 L34 8 L34 16 L11 16 Z"/>'
          + '<path'+B+' d="M13 16 L32 16 L32 19 L13 19 Z"/>'
          + '<path'+B+' d="M14 19 L31 19 L31 36 L14 36 Z"/>'
          + PED,

        j:  '<path'+B+' d="M14 22 L12 14 L18 18 L22.5 8 L27 18 L33 14 L31 22 Z"/>'
          + '<circle'+B+' cx="12" cy="14" r="1.6"/>'
          + '<circle'+B+' cx="22.5" cy="8" r="1.6"/>'
          + '<circle'+B+' cx="33" cy="14" r="1.6"/>'
          + '<path'+B+' d="M14 22 L31 22 L32 26 L13 26 Z"/>'
          + '<path'+B+' d="M14 26 L31 26 L31 36 L14 36 Z"/>'
          + PED,

        l:  '<path'+B+' d="M22 5 L24 5 L24 22 L22 22 Z"/>'
          + '<path'+B+' d="M21 4 L25 4 L23 8 Z"/>'
          + '<path'+B+' d="M16 22 L29 22 L30 26 L15 26 Z"/>'
          + '<path'+B+' d="M15 26 L30 26 L31 36 L14 36 Z"/>'
          + PED,

        f:  '<path'+B+' d="M14 16 L16 8 L19 13 L22.5 6 L26 13 L29 8 L31 16 Z"/>'
          + '<circle'+B+' cx="22.5" cy="6" r="1.4"/>'
          + '<path'+B+' d="M14 16 L31 16 L32 20 L13 20 Z"/>'
          + '<path'+B+' d="M13 20 L32 20 L31 36 L14 36 Z"/>'
          + PED,

        z:  '<path'+B+' d="M14 6 L31 6 L31 11 L21 11 L31 21 L14 21 L14 16 L24 16 L14 6 Z"/>'
          + '<path'+B+' d="M14 21 L31 21 L31 26 L14 26 Z"/>'
          + BOD
          + PED,

        y:  '<path'+B+' d="M22.5 5 C16 8,14 14,15 22 C22 22,28 18,30 12 C27 10,24 8,22.5 5 Z"/>'
          + '<path fill="none" stroke="AC" stroke-width="1.2" stroke-linecap="round" d="M22.5 8 L22.5 22"/>'
          + '<path'+B+' d="M14 22 L31 22 L31 26 L14 26 Z"/>'
          + BOD
          + PED,

        o:  '<path'+B+' d="M22.5 8 L32 14 L28 16 L22.5 12 L17 16 L13 14 Z"/>'
          + '<circle'+B+' cx="22.5" cy="10" r="1.6"/>'
          + '<path'+B+' d="M16 18 L29 18 L31 26 L14 26 Z"/>'
          + BOD
          + PED,

        a:  '<circle'+B+' cx="22.5" cy="10" r="3"/>'
          + '<path'+B+' d="M19 13 L26 13 L28 22 L17 22 Z"/>'
          + '<path fill="none" stroke="AC" stroke-width="1.4" stroke-linecap="round" d="M28 14 C33 12,35 16,32 20"/>'
          + '<path'+B+' d="M14 22 L31 22 L31 26 L14 26 Z"/>'
          + BOD
          + PED,

        h:  '<path'+B+' d="M22.5 4 L33 7 L32 18 C32 22,28 25,22.5 26 C17 25,13 22,13 18 L12 7 Z"/>'
          + '<path fill="none" stroke="AC" stroke-width="1.2" stroke-linecap="round" d="M22.5 9 L22.5 23"/>'
          + '<path fill="none" stroke="AC" stroke-width="1" stroke-linecap="round" d="M14 9 L31 9"/>'
          + '<path'+B+' d="M14 26 L31 26 L31 36 L14 36 Z"/>'
          + PED,

        i:  '<path'+B+' d="M22.5 7 L36 14 L32 17 L26 14 L26 22 L19 22 L19 14 L13 17 L9 14 Z"/>'
          + '<circle'+B+' cx="22.5" cy="9" r="1.8"/>'
          + '<path'+B+' d="M16 22 L29 22 L31 26 L14 26 Z"/>'
          + BOD
          + PED,

        w:  '<circle'+B+' cx="22.5" cy="14" r="8"/>'
          + '<path'+A+' d="M22.5 6 A8 8 0 0 1 22.5 22 Z"/>'
          + '<path'+B+' d="M14 23 L31 23 L31 27 L14 27 Z"/>'
          + BOD
          + PED,

        x:  '<path'+B+' d="M11 22 C11 18,16 18,16 14 C16 10,21 10,21 14 C21 18,26 18,26 14 C26 10,31 10,31 14 L34 14 C34 8,26 6,24 12 C22 6,14 8,14 14 C14 18,9 18,9 22 Z"/>'
          + '<circle'+A+' cx="11" cy="22" r="1.2"/>'
          + '<path'+B+' d="M14 22 L31 22 L31 26 L14 26 Z"/>'
          + BOD
          + PED,

        ch: '<path'+B+' d="M22.5 5 L25 10 L30 12.5 L25 15 L22.5 20 L20 15 L15 12.5 L20 10 Z"/>'
          + '<path'+A+' d="M22 8 L23 8 L23 18 L22 18 Z"/>'
          + '<path'+A+' d="M17.5 12 L27.5 12 L27.5 13 L17.5 13 Z"/>'
          + '<path'+B+' d="M14 22 L31 22 L31 26 L14 26 Z"/>'
          + BOD
          + PED,

        m:  '<path'+B+' d="M22 4 L23 4 L23 7 L22 7 Z"/>'
          + '<path'+B+' d="M19 7 L26 7 L26 8 L19 8 Z"/>'
          + '<path'+B+' d="M17 9 L28 9 L30 22 L15 22 Z"/>'
          + '<path'+A+' d="M22 12 L23 12 L23 19 L22 19 Z"/>'
          + '<path'+A+' d="M18 12 L27 12 L27 13 L18 13 Z"/>'
          + '<path'+B+' d="M14 22 L31 22 L31 26 L14 26 Z"/>'
          + BOD
          + PED,

        // ── Grade 2 : Major pieces ────────────────────────────────────────────

        q:  '<path'+B+' d="M10 18 L12 8 L17 14 L19 6 L22.5 13 L26 6 L28 14 L33 8 L35 18 Z"/>'
          + '<circle'+B+' cx="12" cy="7.5" r="1.5"/>'
          + '<circle'+B+' cx="19" cy="5.5" r="1.5"/>'
          + '<circle'+B+' cx="22.5" cy="12.5" r="1.5"/>'
          + '<circle'+B+' cx="26" cy="5.5" r="1.5"/>'
          + '<circle'+B+' cx="33" cy="7.5" r="1.5"/>'
          + '<path'+B+' d="M11 18 L34 18 L33 22 L12 22 Z"/>'
          + '<path'+B+' d="M12 22 L33 22 L31 36 L14 36 Z"/>'
          + PED,

        d:  '<path'+B+' d="M13 18 L15 10 L19 14 L22.5 4 L26 14 L30 10 L32 18 Z"/>'
          + '<circle'+B+' cx="22.5" cy="4" r="1.6"/>'
          + '<path'+B+' d="M13 18 L32 18 L32 22 L13 22 Z"/>'
          + '<path'+B+' d="M13 22 L32 22 L31 36 L14 36 Z"/>'
          + PED,

        s:  '<circle'+B+' cx="15" cy="10" r="2"/>'
          + '<circle'+B+' cx="22.5" cy="8" r="2"/>'
          + '<circle'+B+' cx="30" cy="10" r="2"/>'
          + '<path'+B+' d="M13 14 L15 11 L19 14 L22.5 9 L26 14 L30 11 L32 14 L32 18 L13 18 Z"/>'
          + '<path'+B+' d="M13 18 L32 18 L32 22 L13 22 Z"/>'
          + '<path'+B+' d="M13 22 L32 22 L31 36 L14 36 Z"/>'
          + PED,

        g:  '<path'+B+' d="M16 6 L26 6 L26 18 L32 18 L32 22 L16 22 Z"/>'
          + '<path'+A+' d="M19 9 L23 9 L23 12 L19 12 Z"/>'
          + '<path'+B+' d="M14 22 L31 22 L31 26 L14 26 Z"/>'
          + BOD
          + PED,

        c:  '<path'+B+' d="M22.5 5 C18 8,16 14,18 22 L22 24 L22 8 L22 24 L27 22 C29 14,27 8,22.5 5 Z"/>'
          + '<path fill="none" stroke="AC" stroke-width="0.6" stroke-linecap="round" d="M16 14 L23 18 M19 11 L23 13 M17 19 L23 21"/>'
          + '<path'+B+' d="M19 24 L26 24 L28 26 L17 26 Z"/>'
          + BOD
          + PED,

        t:  '<path'+B+' d="M22.5 4 L30 22 L15 22 Z"/>'
          + '<circle'+A+' cx="22.5" cy="8" r="1.4"/>'
          + '<path'+A+' d="M22.5 14 L23.5 17 L26.5 17 L24 18.5 L25 21.5 L22.5 20 L20 21.5 L21 18.5 L18.5 17 L21.5 17 Z"/>'
          + '<path'+B+' d="M14 22 L31 22 L31 26 L14 26 Z"/>'
          + BOD
          + PED,

        // ── Grade 3 : King-type ───────────────────────────────────────────────

        k:  '<path'+B+' d="M21 3 L24 3 L24 6 L27 6 L27 9 L24 9 L24 13 L21 13 L21 9 L18 9 L18 6 L21 6 Z"/>'
          + '<path'+B+' d="M22.5 13 C16 13,13 17,13 22 L32 22 C32 17,29 13,22.5 13 Z"/>'
          + '<path'+B+' d="M13 22 L32 22 L31 26 L14 26 Z"/>'
          + '<path'+B+' d="M14 26 L31 26 L31 36 L14 36 Z"/>'
          + PED,

        fk: '<path'+B+' d="M14 4 L16 4 L16 12 L18 12 L18 4 L20 4 L20 12 L22 12 L22 4 L24 4 L24 12 L25 14 L25 22 L15 22 L15 14 Z"/>'
          + '<path'+B+' d="M13 22 L32 22 L31 26 L14 26 Z"/>'
          + BOD
          + PED,

        u:  '<circle'+B+' cx="22.5" cy="14" r="9"/>'
          + '<ellipse'+A+' cx="22.5" cy="14" rx="7" ry="4.5"/>'
          + '<circle fill="FG" stroke="none" cx="22.5" cy="14" r="3"/>'
          + '<circle'+A+' cx="22.5" cy="14" r="1.3"/>'
          + '<path'+B+' d="M14 25 L31 25 L31 28 L14 28 Z"/>'
          + BOD
          + PED,

        hk: '<path'+B+' d="M21 4 L24 4 L24 7 L27 7 L27 10 L24 10 L24 14 L21 14 L21 10 L18 10 L18 7 L21 7 Z"/>'
          + '<path'+B+' d="M22.5 14 C16 14,13 18,13 23 L32 23 C32 18,29 14,22.5 14 Z"/>'
          + '<path'+A+' d="M18 18 L19 22 L17 21 Z"/>'
          + '<path'+A+' d="M25 18 L27 22 L28 19 Z"/>'
          + '<path'+B+' d="M14 23 L31 23 L31 26 L14 26 Z"/>'
          + BOD
          + PED,

        hy: '<circle'+B+' cx="13" cy="11" r="3"/>'
          + '<circle'+B+' cx="22.5" cy="8" r="3"/>'
          + '<circle'+B+' cx="32" cy="11" r="3"/>'
          + '<circle'+A+' cx="13" cy="11" r="0.8"/>'
          + '<circle'+A+' cx="22.5" cy="8" r="0.8"/>'
          + '<circle'+A+' cx="32" cy="11" r="0.8"/>'
          + '<path'+B+' d="M11 14 C14 18,16 20,16 24 L29 24 C29 20,31 18,34 14 L32 14 L25 18 L20 18 L13 14 Z"/>'
          + '<path'+B+' d="M14 24 L31 24 L31 28 L14 28 Z"/>'
          + BOD
          + PED,

        lb: '<path'+B+' d="M10 8 L22.5 11 L35 8 L35 22 L22.5 25 L10 22 Z"/>'
          + '<path fill="none" stroke="AC" stroke-width="1.2" stroke-linecap="round" d="M22.5 11 L22.5 25"/>'
          + '<path fill="none" stroke="AC" stroke-width="0.6" stroke-linecap="round" d="M14 14 L20 15.5 M14 17 L20 18.5 M25 15.5 L31 14 M25 18.5 L31 17"/>'
          + '<path'+B+' d="M14 25 L31 25 L31 28 L14 28 Z"/>'
          + BOD
          + PED,
    };

    // ── Public API ────────────────────────────────────────────────────────────

    window.buildPieceSVG = function buildPieceSVG(char, isWhite) {
        var lc  = String(char || 'p').toLowerCase();
        var art = ART[lc] || ART['p'];

        var fg, st, ac;
        if (isWhite) {
            fg = '#fefbf2';
            st = '#1a1408';
            ac = '#1a1408';
        } else {
            fg = '#1a1408';
            st = '#fefbf2';
            ac = '#fefbf2';
        }

        var inner = art
            .replace(/FG/g, fg)
            .replace(/\bST\b/g, st)
            .replace(/\bAC\b/g, ac);

        var svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        svg.setAttribute('viewBox', '0 0 45 45');
        svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
        svg.classList.add('piece-svg', 'piece-svg--' + (isWhite ? 'white' : 'black'));
        svg.innerHTML = inner;
        return svg;
    };

}());
