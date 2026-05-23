'use strict';
// piece-art.js — inline SVG piece renderer for all 36 piece types.
// Colors are baked directly into each SVG (no CSS variable dependency).
// Exposes window.buildPieceSVG(char, isWhite) → SVGSVGElement

(function () {

    var _pid = 0; // unique id counter for gradient defs

    // ── Piece art strings ─────────────────────────────────────────────────────
    // Placeholders replaced at render time:
    //   FG   → gradient fill URL
    //   ST   → stroke / dark-fill color
    //   HI   → translucent highlight fill
    //   AC   → accent color (gold for black, dark-brown for white)
    //
    // Attribute shorthands used in every path/shape:
    //   body  : fill="FG" stroke="ST" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"
    //   ring  : fill="none" stroke="ST" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"
    //   hi    : fill="HI" stroke="none"
    //   acc   : fill="AC" stroke="none"
    //   dark  : fill="ST" stroke="none"

    var B  = ' fill="FG" stroke="ST" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"';
    var R  = ' fill="none" stroke="ST" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"';
    var H  = ' fill="HI" stroke="none"';
    var A  = ' fill="AC" stroke="none"';
    var D  = ' fill="ST" stroke="none"';

    var ART = {

        // ── Grade 0 : Pawn-type ───────────────────────────────────────────────

        // Pawn – classic Staunton pawn with round head and flared base
        p: '<circle'+B+' cx="22.5" cy="11.5" r="5.5"/>'
         + '<ellipse'+H+' cx="20.5" cy="9.5" rx="2.2" ry="1.8"/>'
         + '<path'+B+' d="M19.5,17C17.5,18.5 16,21 16,24.5C16,28.5 18,31.5 21,32.5L17,34.5H28L24,32.5C27,31.5 29,28.5 29,24.5C29,21 27.5,18.5 25.5,17C24,16 21,16 19.5,17Z"/>'
         + '<rect'+B+' x="15.5" y="34.5" width="14" height="2.2" rx="0.5"/>'
         + '<rect'+B+' x="12.5" y="36.7" width="20" height="2.8" rx="1.2"/>',

        // Evil Pawn – pawn with two recurved horns
        e: '<circle'+B+' cx="22.5" cy="11.5" r="5.5"/>'
         + '<path'+A+' d="M19,8.5C18.5,5.5 16.5,3.5 14.5,4.5C16.5,5.5 18,7 19,8.5Z"/>'
         + '<path'+A+' d="M26,8.5C26.5,5.5 28.5,3.5 30.5,4.5C28.5,5.5 27,7 26,8.5Z"/>'
         + '<ellipse'+H+' cx="20.5" cy="9.5" rx="2.2" ry="1.8"/>'
         + '<path'+B+' d="M19.5,17C17.5,18.5 16,21 16,24.5C16,28.5 18,31.5 21,32.5L17,34.5H28L24,32.5C27,31.5 29,28.5 29,24.5C29,21 27.5,18.5 25.5,17C24,16 21,16 19.5,17Z"/>'
         + '<rect'+B+' x="15.5" y="34.5" width="14" height="2.2" rx="0.5"/>'
         + '<rect'+B+' x="12.5" y="36.7" width="20" height="2.8" rx="1.2"/>',

        // Squire – pawn with heraldic shield emblem
        sq: '<circle'+B+' cx="22.5" cy="11" r="4.8"/>'
          + '<ellipse'+H+' cx="20.5" cy="9.2" rx="2" ry="1.5"/>'
          + '<path'+B+' d="M19.5,15.5C17.5,17 16.5,19.5 16.5,22.5C16.5,26 18,29 21,30L17.5,32H27.5L24,30C27,29 28.5,26 28.5,22.5C28.5,19.5 27.5,17 25.5,15.5C24,14.5 21,14.5 19.5,15.5Z"/>'
          + '<path'+H+' d="M20.5,19V27C21.5,29 23.5,29 24.5,27V19Z"/>'
          + '<path'+R+' d="M20.5,19V27C21.5,29 23.5,29 24.5,27V19H20.5Z M22.5,19V29"/>'
          + '<rect'+B+' x="16" y="32" width="13" height="2" rx="0.5"/>'
          + '<rect'+B+' x="13" y="34" width="19" height="2.5" rx="1"/>',

        // Longpaw – stretched-tall pawn
        lp: '<circle'+B+' cx="22.5" cy="9" r="4.2"/>'
          + '<ellipse'+H+' cx="20.5" cy="7.5" rx="1.8" ry="1.5"/>'
          + '<path'+B+' d="M20.5,13C19,14.5 18,17 18,21C18,27 19,33.5 19.5,35H25.5C26,33.5 27,27 27,21C27,17 26,14.5 24.5,13C23.5,12.2 21.5,12.2 20.5,13Z"/>'
          + '<rect'+B+' x="16" y="35" width="13" height="1.5" rx="0.5"/>'
          + '<rect'+B+' x="13.5" y="36.5" width="18" height="1.8" rx="0.5"/>'
          + '<rect'+B+' x="11" y="38.3" width="23" height="2.2" rx="1"/>',

        // Retreater – pawn with reversed arrow
        rt: '<circle'+B+' cx="22.5" cy="11.5" r="5.5"/>'
          + '<ellipse'+H+' cx="20.5" cy="9.5" rx="2.2" ry="1.8"/>'
          + '<path'+B+' d="M19.5,17C17.5,18.5 16,21 16,24.5C16,28.5 18,31.5 21,32.5L17,34.5H28L24,32.5C27,31.5 29,28.5 29,24.5C29,21 27.5,18.5 25.5,17C24,16 21,16 19.5,17Z"/>'
          + '<path'+R+' d="M27,24.5H19.5 M22.5,21.5L19.5,24.5L22.5,27.5"/>'
          + '<rect'+B+' x="15.5" y="34.5" width="14" height="2.2" rx="0.5"/>'
          + '<rect'+B+' x="12.5" y="36.7" width="20" height="2.8" rx="1.2"/>',

        // Hollow – ghost pawn, outline only (AC = accent used for outline)
        ho: '<circle fill="none" stroke="AC" stroke-width="1.8" cx="22.5" cy="11.5" r="5.5"/>'
          + '<path fill="none" stroke="AC" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" d="M19.5,17C17.5,18.5 16,21 16,24.5C16,28.5 18,31.5 21,32.5L17,34.5H28L24,32.5C27,31.5 29,28.5 29,24.5C29,21 27.5,18.5 25.5,17C24,16 21,16 19.5,17Z"/>'
          + '<rect fill="none" stroke="AC" stroke-width="1.8" x="15.5" y="34.5" width="14" height="2.2" rx="0.5"/>'
          + '<rect fill="none" stroke="AC" stroke-width="1.8" x="12.5" y="36.7" width="20" height="2.8" rx="1.2"/>',

        // Crawler – wide, low-profile pawn
        cr: '<ellipse'+B+' cx="22.5" cy="13.5" rx="7.5" ry="5.2"/>'
          + '<ellipse'+H+' cx="19" cy="11.5" rx="3.5" ry="2.5"/>'
          + '<path'+B+' d="M13,18.5C11,20 10,23 10,26.5C10,30.5 12.5,33.5 17,34.5L12,36.5H33L28,34.5C32.5,33.5 35,30.5 35,26.5C35,23 34,20 32,18.5C29,16.5 16,16.5 13,18.5Z"/>'
          + '<rect'+B+' x="10.5" y="36.5" width="24" height="2" rx="0.5"/>'
          + '<rect'+B+' x="8" y="38.5" width="29" height="2.5" rx="1"/>',

        // ── Grade 1 : Minor pieces ────────────────────────────────────────────

        // Knight – stylised horse-head profile
        n: '<path'+B+' d="M12.5,38.5V33L16.5,25.5C14,22.5 13,19 13,16.5C13,12 16,9 20,8.5C20.5,7 22,6 24,6C26.5,6 28.5,7.5 29,9.5L30.5,11C32.5,12.5 34,16.5 34,22V27L36.5,31.5V38.5Z"/>'
         + '<circle'+H+' cx="25" cy="13" r="2.5"/>'
         + '<ellipse'+H+' cx="20" cy="8.5" rx="2.5" ry="4" transform="rotate(-15,20,8.5)"/>'
         + '<circle'+D+' cx="26.5" cy="12" r="1.2"/>'
         + '<rect'+B+' x="10.5" y="36.5" width="25" height="2" rx="0.5"/>'
         + '<rect'+B+' x="8.5" y="38.5" width="28" height="2.5" rx="1"/>',

        // Bishop – tall mitre with cross and slash
        b: '<path'+B+' d="M22.5,5.5C22.5,5.5 20,9 19,14L17,27.5C16,29.5 15,32 15,33.5H30C30,32 29,29.5 28,27.5L26,14C25,9 22.5,5.5 22.5,5.5Z"/>'
         + '<ellipse'+H+' cx="22.5" cy="9" rx="2.5" ry="4.5"/>'
         + '<ellipse'+B+' cx="22.5" cy="27.5" rx="8" ry="3.5"/>'
         + '<path'+R+' d="M22.5,5.5V14 M20,9.5H25"/>'
         + '<rect'+B+' x="14" y="33.5" width="17" height="2.2" rx="0.5"/>'
         + '<rect'+B+' x="11" y="35.7" width="23" height="2.8" rx="1.2"/>',

        // Jester – jester hat with twin bell-tips
        j: '<circle'+B+' cx="15.5" cy="4.5" r="3.2"/>'
         + '<circle'+B+' cx="29.5" cy="4.5" r="3.2"/>'
         + '<path'+B+' d="M22.5,6.5C20,8.5 16.5,7 15.5,4.5C14.5,8.5 16.5,12.5 19.5,14C19,16 18.5,18 18.5,20C18.5,23.5 20.5,26.5 22.5,26.5C24.5,26.5 26.5,23.5 26.5,20C26.5,18 26,16 25.5,14C28.5,12.5 30.5,8.5 29.5,4.5C28.5,7 25,8.5 22.5,6.5Z"/>'
         + '<ellipse'+H+' cx="20" cy="8" rx="3" ry="5" transform="rotate(-20,20,8)"/>'
         + '<path'+B+' d="M18.5,26.5L16.5,36.5H28.5L26.5,26.5C25,25.5 20,25.5 18.5,26.5Z"/>'
         + '<rect'+B+' x="14" y="36.5" width="17" height="2" rx="0.5"/>'
         + '<rect'+B+' x="11" y="38.5" width="23" height="2.5" rx="1"/>',

        // Lancer – spear with crossguard and tapering shaft
        l: '<polygon'+B+' points="22.5,3.5 19.5,9 25.5,9"/>'
         + '<rect'+B+' x="21.2" y="9" width="2.6" height="25.5" rx="1"/>'
         + '<rect'+B+' x="14" y="21" width="17" height="3.5" rx="1.5"/>'
         + '<ellipse'+H+' cx="22.5" cy="5.5" rx="1.2" ry="1.8"/>'
         + '<rect'+B+' x="16.5" y="34.5" width="12" height="2.5" rx="0.5"/>'
         + '<rect'+B+' x="13" y="37" width="19" height="2.5" rx="1"/>',

        // Prince – three-ball crown with body and base
        y: '<circle'+B+' cx="17" cy="20" r="3.2"/>'
         + '<circle'+B+' cx="22.5" cy="17.5" r="3.2"/>'
         + '<circle'+B+' cx="28" cy="20" r="3.2"/>'
         + '<ellipse'+H+' cx="15.5" cy="18.5" rx="1.3" ry="1.2"/>'
         + '<ellipse'+H+' cx="21" cy="16" rx="1.3" ry="1.2"/>'
         + '<ellipse'+H+' cx="26.5" cy="18.5" rx="1.3" ry="1.2"/>'
         + '<rect'+B+' x="14" y="20.5" width="17" height="6" rx="0.5"/>'
         + '<path'+B+' d="M14,26.5C14,29.5 17.5,33 22.5,33C27.5,33 31,29.5 31,26.5Z"/>'
         + '<rect'+B+' x="12.5" y="33" width="20" height="2" rx="0.5"/>'
         + '<rect'+B+' x="10.5" y="35" width="24" height="2.5" rx="1"/>',

        // Duke – knight with a small three-point crown
        d: '<path'+B+' d="M12.5,38.5V33L16.5,25.5C14,22.5 13,19 13,16.5C13,12 16,9 20,8.5C20.5,7 22,6 24,6C26.5,6 28.5,7.5 29,9.5L30.5,11C32.5,12.5 34,16.5 34,22V27L36.5,31.5V38.5Z"/>'
         + '<circle'+H+' cx="25" cy="13" r="2.5"/>'
         + '<path'+A+' d="M18.5,7.5L18.5,5L20.5,6.5L22.5,4.5L24.5,6.5L26.5,5L26.5,7.5Z"/>'
         + '<rect'+B+' x="10.5" y="36.5" width="25" height="2" rx="0.5"/>'
         + '<rect'+B+' x="8.5" y="38.5" width="28" height="2.5" rx="1"/>',

        // Herbalist – bishop with four-petal leaf rosette at tip
        h: '<path'+B+' d="M22.5,7C22.5,7 20,10 19,15L17,27.5C16,29.5 15,32 15,33.5H30C30,32 29,29.5 28,27.5L26,15C25,10 22.5,7 22.5,7Z"/>'
         + '<ellipse'+B+' cx="22.5" cy="27.5" rx="8" ry="3.5"/>'
         + '<ellipse'+H+' cx="22.5" cy="9.5" rx="2.5" ry="4.5"/>'
         + '<ellipse'+H+' cx="22.5" cy="9.5" rx="4.5" ry="2.5"/>'
         + '<rect'+B+' x="14" y="33.5" width="17" height="2.2" rx="0.5"/>'
         + '<rect'+B+' x="11" y="35.7" width="23" height="2.8" rx="1.2"/>',

        // Bird – stylised bird with spread wings and tail
        f: '<circle'+B+' cx="22.5" cy="13.5" r="4.5"/>'
         + '<path'+B+' d="M21,18C21,18 8,16.5 6.5,12C9,15.5 14,18 21,18ZM24,18C24,18 37,16.5 38.5,12C36,15.5 31,18 24,18Z"/>'
         + '<ellipse'+B+' cx="22.5" cy="24" rx="5.5" ry="6.5"/>'
         + '<polygon'+B+' points="26.5,13 32.5,13.5 28,16.5"/>'
         + '<circle'+H+' cx="20.5" cy="12" rx="1.8" ry="1.5"/>'
         + '<circle'+D+' cx="25.5" cy="12.5" r="1.3"/>'
         + '<path'+B+' d="M20,29.5C18,32.5 15.5,35 13,38.5C16,36.5 20,33.5 22.5,31ZM25,29.5C27,32.5 29.5,35 32,38.5C29,36.5 25,33.5 22.5,31Z"/>'
         + '<rect'+B+' x="17" y="38.5" width="11" height="2.5" rx="1"/>',

        // Beast Handler – paw-print with three toes and palm pad
        a: '<ellipse'+B+' cx="22.5" cy="30.5" rx="8.5" ry="7.5"/>'
         + '<circle'+B+' cx="15" cy="22" r="3.8"/>'
         + '<circle'+B+' cx="22.5" cy="20" r="3.8"/>'
         + '<circle'+B+' cx="30" cy="22" r="3.8"/>'
         + '<ellipse'+H+' cx="14" cy="21" rx="2" ry="1.5"/>'
         + '<ellipse'+H+' cx="21.5" cy="19" rx="2" ry="1.5"/>'
         + '<ellipse'+H+' cx="29" cy="21" rx="2" ry="1.5"/>'
         + '<ellipse'+H+' cx="21" cy="29" rx="5" ry="4"/>'
         + '<rect'+B+' x="14" y="38" width="17" height="2.5" rx="1"/>',

        // Shield – heraldic shield with cross and inner glow
        i: '<path'+B+' d="M22.5,7C22.5,7 9.5,9.5 9.5,20C9.5,30 15,36.5 22.5,40C30,36.5 35.5,30 35.5,20C35.5,9.5 22.5,7 22.5,7Z"/>'
         + '<path'+H+' d="M22.5,10.5C22.5,10.5 13.5,12.5 13.5,20C13.5,28.5 17.5,33.5 22.5,37C27.5,33.5 31.5,28.5 31.5,20C31.5,12.5 22.5,10.5 22.5,10.5Z"/>'
         + '<path'+R+' d="M22.5,10.5V37 M13.5,20H31.5"/>',

        // Eagle – frontal eagle with wings, talons and beak
        g: '<circle'+B+' cx="22.5" cy="12.5" r="4.5"/>'
         + '<path'+B+' d="M8,19.5C8,16.5 10,13.5 13,12.5L19,15V18.5L12.5,16.5C10.5,17 8,18.5 8,21ZM37,19.5C37,16.5 35,13.5 32,12.5L26,15V18.5L32.5,16.5C34.5,17 37,18.5 37,21Z"/>'
         + '<ellipse'+B+' cx="22.5" cy="22.5" rx="5" ry="8.5"/>'
         + '<polygon'+B+' points="22.5,14 28,16 25,19"/>'
         + '<circle'+H+' cx="20.5" cy="11.5" rx="2" ry="1.5"/>'
         + '<circle'+D+' cx="25" cy="11.5" r="1.3"/>'
         + '<path'+B+' d="M19,30L16.5,37L20.5,35ZM26,30L28.5,37L24.5,35Z"/>'
         + '<path'+R+' d="M15.5,36L19.5,34 M17,38L19.5,34 M18.5,40L19.5,34 M29.5,36L25.5,34 M28,38L25.5,34 M26.5,40L25.5,34"/>'
         + '<rect'+B+' x="14" y="40" width="17" height="2" rx="1"/>',

        // Lantern – lantern box on pole with glowing window
        m: '<rect'+B+' x="21" y="5.5" width="3" height="7" rx="1.5"/>'
         + '<path'+R+' d="M22.5,5.5C22.5,3.5 21,2.5 19.5,3"/>'
         + '<rect'+B+' x="15.5" y="12.5" width="14" height="19" rx="2.5"/>'
         + '<path'+R+' d="M15.5,18H29.5 M15.5,25H29.5"/>'
         + '<ellipse'+H+' cx="22.5" cy="21.5" rx="5" ry="5.5"/>'
         + '<rect'+B+' x="17.5" y="31.5" width="10" height="2.5" rx="1"/>'
         + '<rect'+B+' x="14" y="34" width="17" height="2" rx="0.5"/>'
         + '<rect'+B+' x="11" y="36" width="23" height="2.8" rx="1.2"/>',

        // Eclipse – crescent moon shape via even-odd fill-rule
        w: '<path'+B+' fill-rule="evenodd" d="M22.5,6A12,12 0 1 1 22.499,6ZM26.5,11.5A9.5,9.5 0 1 0 26.499,11.5Z"/>'
         + '<rect'+B+' x="21.2" y="30" width="2.6" height="5" rx="1"/>'
         + '<rect'+B+' x="14" y="35" width="17" height="2.2" rx="0.5"/>'
         + '<rect'+B+' x="11" y="37.2" width="23" height="2.8" rx="1.2"/>',

        // Wizard – tall pointed hat with star and sparkles
        t: '<path'+B+' d="M22.5,4.5L13,35H32Z"/>'
         + '<ellipse'+B+' cx="22.5" cy="35" rx="10.5" ry="3.2"/>'
         + '<path'+H+' d="M22.5,14.5L23.8,18.2H27.8L24.6,20.4L25.8,24.2L22.5,22L19.2,24.2L20.4,20.4L17.2,18.2H21.2Z"/>'
         + '<circle'+H+' cx="18" cy="29" r="1.6"/>'
         + '<circle'+H+' cx="27" cy="27.5" r="1.3"/>'
         + '<circle'+H+' cx="22.5" cy="9.5" r="0.8"/>'
         + '<rect'+B+' x="11" y="38.2" width="23" height="2.8" rx="1.2"/>',

        // Coil – coiled snake with visible head and tongue
        x: '<path'+B+' d="M22.5,7.5C15.5,7.5 10.5,12.5 10.5,18C10.5,22.5 14,26 19,26.5C17.5,27.5 16,30 16,32.5C16,35.5 18,38 22.5,38C27,38 29,35.5 29,32.5C29,30 27.5,27.5 26,26.5C31,26 34.5,22.5 34.5,18C34.5,12.5 29.5,7.5 22.5,7.5Z"/>'
         + '<path'+H+' d="M22.5,11C18.5,11 15,14 15,18C15,21 17.5,23 20,24C20.5,22.5 18.5,21 17,18C17,16 19.5,14 22.5,14C25.5,14 28,16 28,18C26.5,21 24.5,22.5 25,24C27.5,23 30,21 30,18C30,14 26.5,11 22.5,11Z"/>'
         + '<ellipse'+B+' cx="30" cy="8.5" rx="3.8" ry="3.2"/>'
         + '<ellipse'+H+' cx="29" cy="7.5" rx="1.5" ry="1.2"/>'
         + '<path'+R+' d="M33.2,8.5L37,7.5 M33.2,9.5L37,10.5"/>',

        // Choir – two pawn-figures side by side
        ch: '<circle'+B+' cx="16.5" cy="11.5" r="4.2"/>'
          + '<ellipse'+H+' cx="15" cy="10" rx="1.8" ry="1.5"/>'
          + '<path'+B+' d="M13.5,16C12,17.5 11,19.5 11,22.5C11,26 12.5,29 15,30L12,32H21.5L18.5,30C21,29 22.5,26 22.5,22.5C22.5,19.5 21.5,17.5 20,16C18.5,15 15,15 13.5,16Z"/>'
          + '<circle'+B+' cx="28.5" cy="11.5" r="4.2"/>'
          + '<ellipse'+H+' cx="27" cy="10" rx="1.8" ry="1.5"/>'
          + '<path'+B+' d="M25.5,16C24,17.5 23,19.5 23,22.5C23,26 24.5,29 27,30L24,32H33.5L30.5,30C33,29 34.5,26 34.5,22.5C34.5,19.5 33.5,17.5 32,16C30.5,15 27,15 25.5,16Z"/>'
          + '<rect'+B+' x="10.5" y="32" width="24" height="2.2" rx="0.5"/>'
          + '<rect'+B+' x="8.5" y="34.2" width="28" height="2.8" rx="1.2"/>',

        // Rook – classic battlement tower with portcullis
        r: '<path'+B+' d="M10,37V15H14V11H18.5V15H21V11H24V15H26.5V11H31.5V15H35V37Z"/>'
         + '<path'+R+' d="M15,16V34 M22.5,16V34 M30,16V34 M12.5,22H32.5 M12.5,28H32.5"/>'
         + '<ellipse'+H+' cx="22.5" cy="18" rx="8" ry="3"/>'
         + '<rect'+B+' x="8.5" y="37" width="28" height="2.2" rx="0.5"/>'
         + '<rect'+B+' x="7" y="39.2" width="31" height="2.3" rx="1.2"/>',

        // ── Grade 2 : Major pieces ────────────────────────────────────────────

        // Queen – five-orb crown with cape body
        q: '<circle'+B+' cx="11.5" cy="21" r="3.2"/>'
         + '<circle'+B+' cx="17" cy="17" r="3.2"/>'
         + '<circle'+B+' cx="22.5" cy="15.5" r="3.2"/>'
         + '<circle'+B+' cx="28" cy="17" r="3.2"/>'
         + '<circle'+B+' cx="33.5" cy="21" r="3.2"/>'
         + '<ellipse'+H+' cx="10" cy="19.5" rx="1.3" ry="1.2"/>'
         + '<ellipse'+H+' cx="15.5" cy="15.5" rx="1.3" ry="1.2"/>'
         + '<ellipse'+H+' cx="21" cy="14" rx="1.3" ry="1.2"/>'
         + '<ellipse'+H+' cx="26.5" cy="15.5" rx="1.3" ry="1.2"/>'
         + '<ellipse'+H+' cx="32" cy="19.5" rx="1.3" ry="1.2"/>'
         + '<path'+B+' d="M11.5,24H33.5L35.5,32.5H9.5Z"/>'
         + '<rect'+B+' x="9.5" y="32.5" width="26" height="2.2" rx="0.5"/>'
         + '<rect'+B+' x="7.5" y="34.7" width="30" height="2.8" rx="1.2"/>',

        // Princess – delicate tiara-crown with gem highlights
        s: '<path'+B+' d="M12.5,24L17,17L22.5,13.5L28,17L32.5,24Z"/>'
         + '<circle'+A+' cx="22.5" cy="14" r="2.5"/>'
         + '<circle'+A+' cx="17" cy="17.5" r="2"/>'
         + '<circle'+A+' cx="28" cy="17.5" r="2"/>'
         + '<ellipse'+H+' cx="22.5" cy="13.5" rx="1.2" ry="1"/>'
         + '<path'+B+' d="M12.5,24C12.5,28 17,33 22.5,33C28,33 32.5,28 32.5,24Z"/>'
         + '<rect'+B+' x="11.5" y="33" width="22" height="2.2" rx="0.5"/>'
         + '<rect'+B+' x="9" y="35.2" width="27" height="2.8" rx="1.2"/>',

        // Boot – leather boot silhouette
        o: '<rect'+B+' x="18.5" y="6.5" width="9.5" height="22" rx="2.5"/>'
         + '<path'+B+' d="M18.5,27C16.5,28.5 13,31.5 13,35C13,37.5 15,38.5 17,38.5C20,38.5 30,38.5 31,38.5C33,38.5 35,37 35,35C35,32 32,30 28,29.5V27Z"/>'
         + '<path'+H+' d="M15,34.5C15,36.5 18.5,38 22.5,38C26.5,38 30.5,36.5 30.5,34.5"/>'
         + '<ellipse'+H+' cx="22" cy="12" rx="2.5" ry="5" transform="rotate(5,22,12)"/>'
         + '<rect'+B+' x="12" y="38.5" width="22" height="2.5" rx="1"/>',

        // Feather – quill feather with vane lines and shaft
        c: '<path'+B+' d="M22.5,6.5C22.5,6.5 15.5,8.5 14.5,15C15.5,17.5 22.5,19.5 22.5,19.5C22.5,19.5 29.5,17.5 30.5,15C29.5,8.5 22.5,6.5 22.5,6.5Z"/>'
         + '<path'+R+' d="M22.5,6.5V19.5 M16.5,11.5C19.5,13 25.5,13 28.5,11.5 M16.5,16C19.5,17 25.5,17 28.5,16"/>'
         + '<ellipse'+H+' cx="22.5" cy="10" rx="4.5" ry="4.5" transform="rotate(-10,22.5,10)"/>'
         + '<path'+B+' d="M19.5,19.5L17,37H28L25.5,19.5C24,18.5 21,18.5 19.5,19.5Z"/>'
         + '<rect'+B+' x="15" y="37" width="15" height="2" rx="0.5"/>'
         + '<rect'+B+' x="12" y="39" width="21" height="2.5" rx="1"/>',

        // Warden – portcullis gate with wide battlements
        z: '<path'+B+' d="M8.5,38V14H13.5V10H18V14H22.5V10H27V14H31.5V10H36.5V14H36.5V38Z"/>'
         + '<path'+R+' d="M14,16V36 M20,16V36 M26,16V36 M32,16V36 M12,21H34 M12,27H34 M12,33H34"/>'
         + '<path'+R+' d="M14,36C14,37.5 14.5,38 22.5,38C30.5,38 31,37.5 31,36"/>'
         + '<ellipse'+H+' cx="22.5" cy="18" rx="10" ry="3"/>'
         + '<rect'+B+' x="7" y="38" width="31" height="2" rx="0.5"/>'
         + '<rect'+B+' x="5.5" y="40" width="34" height="1.5" rx="1"/>',

        // ── Grade 3 : King-type pieces ────────────────────────────────────────

        // King – cross finial on crown, banded body, flanged base
        k: '<rect'+B+' x="21.2" y="5.5" width="2.6" height="10" rx="1.3"/>'
         + '<rect'+B+' x="18" y="7" width="9" height="3" rx="1.2"/>'
         + '<rect'+B+' x="11" y="22" width="23" height="10" rx="1"/>'
         + '<ellipse'+H+' cx="22.5" cy="25" rx="9" ry="3.5"/>'
         + '<path'+B+' d="M11,32H34L35.5,38.5H9.5Z"/>'
         + '<rect'+B+' x="9.5" y="38.5" width="26" height="2" rx="0.5"/>'
         + '<rect'+B+' x="7.5" y="40.5" width="30" height="1.5" rx="1"/>',

        // Oracle – all-seeing eye with iris and slit pupil
        u: '<path'+B+' d="M7,20C7,20 12.5,8 22.5,8C32.5,8 38,20 38,20C38,20 32.5,32 22.5,32C12.5,32 7,20 7,20Z"/>'
         + '<circle'+B+' cx="22.5" cy="20" r="7"/>'
         + '<ellipse'+H+' cx="22.5" cy="20" rx="4.5" ry="4.5"/>'
         + '<ellipse'+D+' cx="22.5" cy="20" rx="1.5" ry="4"/>'
         + '<circle'+H+' cx="20.5" cy="17.5" r="1.2"/>'
         + '<rect'+B+' x="14" y="32" width="17" height="2.2" rx="0.5"/>'
         + '<rect'+B+' x="11" y="34.2" width="23" height="2.2" rx="0.5"/>'
         + '<rect'+B+' x="9" y="36.4" width="27" height="2.8" rx="1.2"/>',

        // Husk – hollow skull with eye sockets and teeth
        hk: '<path'+B+' d="M22.5,6.5C17,6.5 12,11 12,17C12,21 13.5,24 16.5,25.5V28.5H28.5V25.5C31.5,24 33,21 33,17C33,11 28,6.5 22.5,6.5Z"/>'
          + '<ellipse'+D+' cx="18.5" cy="16" rx="2.8" ry="2.5"/>'
          + '<ellipse'+D+' cx="26.5" cy="16" rx="2.8" ry="2.5"/>'
          + '<ellipse'+H+' cx="17.5" cy="15" rx="1.2" ry="1"/>'
          + '<ellipse'+H+' cx="25.5" cy="15" rx="1.2" ry="1"/>'
          + '<path'+H+' d="M21,20.5A1.5,2 0 1 1 20.9,20.5"/>'
          + '<path'+R+' d="M18,28.5V31.5 M22.5,28.5V31.5 M27,28.5V31.5"/>'
          + '<rect'+B+' x="14" y="31.5" width="17" height="2.5" rx="0.5"/>'
          + '<rect'+B+' x="11.5" y="34" width="22" height="2.2" rx="0.5"/>'
          + '<rect'+B+' x="9" y="36.2" width="27" height="2.8" rx="1.2"/>',

        // Hydra – three serpent heads on forked necks
        hy: '<path'+B+' d="M20,34.5C18.5,30.5 19.5,26 22.5,24C25.5,26 26.5,30.5 25,34.5Z"/>'
          + '<path'+B+' d="M20,24C18,20 16.5,15 17.5,11C18.5,7.5 19.5,9 20.5,13C21,9.5 21.5,7.5 22.5,7C23.5,7.5 24,9.5 24.5,13C25.5,9 26.5,7.5 27.5,11C28.5,15 27,20 25,24Z"/>'
          + '<ellipse'+B+' cx="17.5" cy="11" rx="4" ry="3.2"/>'
          + '<ellipse'+B+' cx="22.5" cy="8" rx="4" ry="3.2"/>'
          + '<ellipse'+B+' cx="27.5" cy="11" rx="4" ry="3.2"/>'
          + '<ellipse'+H+' cx="16.5" cy="10" rx="1.5" ry="1.2"/>'
          + '<ellipse'+H+' cx="21.5" cy="7" rx="1.5" ry="1.2"/>'
          + '<ellipse'+H+' cx="26.5" cy="10" rx="1.5" ry="1.2"/>'
          + '<ellipse'+B+' cx="22.5" cy="38" rx="9.5" ry="4"/>'
          + '<rect'+B+' x="12" y="40" width="21" height="2.5" rx="1"/>',

        // Library – open book with text-line pages
        lb: '<path'+B+' d="M22.5,7.5L11,11V37.5L22.5,35L34,37.5V11Z"/>'
          + '<rect'+B+' x="21.5" y="7.5" width="2" height="27.5" rx="0.5"/>'
          + '<path'+R+' d="M13,14H21.5 M13,18H21.5 M13,22H21.5 M13,26H21.5 M13,30H21.5"/>'
          + '<path'+R+' d="M23.5,14H32 M23.5,18H32 M23.5,22H32 M23.5,26H32 M23.5,30H32"/>'
          + '<ellipse'+H+' cx="17" cy="15" rx="3.5" ry="1.5"/>'
          + '<rect'+B+' x="9.5" y="37.5" width="26" height="2" rx="0.5"/>'
          + '<rect'+B+' x="7.5" y="39.5" width="30" height="2" rx="1"/>',

        // Fork – three tines with webbed join and handle
        fk: '<rect'+B+' x="14.5" y="6.5" width="4" height="16.5" rx="2"/>'
          + '<rect'+B+' x="21.2" y="6.5" width="3.5" height="16.5" rx="1.7"/>'
          + '<rect'+B+' x="27.5" y="6.5" width="4" height="16.5" rx="2"/>'
          + '<path'+B+' d="M14.5,23.5C14.5,27 18.5,29.5 22.5,29.5C26.5,29.5 30.5,27 30.5,23.5Z"/>'
          + '<ellipse'+H+' cx="22.5" cy="24" rx="7" ry="2"/>'
          + '<rect'+B+' x="20.5" y="29.5" width="4.5" height="8.5" rx="1.5"/>'
          + '<rect'+B+' x="15.5" y="38" width="14" height="2" rx="0.5"/>'
          + '<rect'+B+' x="12.5" y="40" width="20" height="2" rx="1"/>',

        // ── Special : Beast (spawned by Beast Handler) ────────────────────────

        // Beast – wild creature with fangs, horns and glowing eyes
        v: '<path'+B+' d="M22.5,9.5C18,9.5 13,13.5 13,18.5C13,22 15,25 18,26L16,29.5C14.5,32 15,35.5 17.5,36.5H27.5C30,35.5 30.5,32 29,29.5L27,26C30,25 32,22 32,18.5C32,13.5 27,9.5 22.5,9.5Z"/>'
         + '<polygon'+A+' points="14,11 11,6 17,10"/>'
         + '<polygon'+A+' points="31,11 34,6 28,10"/>'
         + '<circle'+H+' cx="19" cy="17.5" r="3"/>'
         + '<circle'+H+' cx="26" cy="17.5" r="3"/>'
         + '<circle'+D+' cx="19.5" cy="17" r="1.2"/>'
         + '<circle'+D+' cx="26.5" cy="17" r="1.2"/>'
         + '<path'+A+' d="M20,22.5L19,27H21ZM25,22.5L24,27H26Z"/>'
         + '<rect'+B+' x="12.5" y="36.5" width="20" height="2.2" rx="0.5"/>'
         + '<rect'+B+' x="10.5" y="38.7" width="24" height="2.8" rx="1.2"/>',
    };

    // ── Public API ────────────────────────────────────────────────────────────

    window.buildPieceSVG = function buildPieceSVG(char, isWhite) {
        var id  = 'pc' + (++_pid);
        var lc  = String(char || 'p').toLowerCase();
        var art = ART[lc] || ART['p'];

        // Color palette ─ baked directly into SVG attributes, no CSS required
        var gL, gM, gD, st, hi, ac;
        if (isWhite) {
            gL = '#fffef2';   // gradient light (top-left highlight)
            gM = '#f0dda0';   // gradient mid (main body)
            gD = '#c49040';   // gradient dark (shadow edge)
            st = '#3a1800';   // stroke / dark-fill
            hi = 'rgba(255,255,220,0.72)'; // inner highlight
            ac = '#3a1800';   // accent (white pieces use same dark for details)
        } else {
            gL = '#3c2010';   // dark pieces: light edge is just dark brown
            gM = '#180904';   // main dark body
            gD = '#060301';   // deepest shadow
            st = '#060301';   // stroke
            hi = 'rgba(210,165,40,0.55)'; // gold highlight
            ac = '#d4aa30';   // gold accent
        }

        // userSpaceOnUse: light source at upper-left of the 45×45 viewBox
        var defs = '<defs>'
            + '<radialGradient id="' + id + '" cx="16" cy="11" r="36" gradientUnits="userSpaceOnUse">'
            + '<stop offset="0%"   stop-color="' + gL + '"/>'
            + '<stop offset="48%"  stop-color="' + gM + '"/>'
            + '<stop offset="100%" stop-color="' + gD + '"/>'
            + '</radialGradient>'
            + '</defs>';

        var inner = art
            .replace(/FG/g,  'url(#' + id + ')')
            .replace(/\bST\b/g,  st)
            .replace(/\bHI\b/g,  hi)
            .replace(/\bAC\b/g,  ac);

        var svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        svg.setAttribute('viewBox', '0 0 45 45');
        svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
        svg.classList.add('piece-svg', 'piece-svg--' + (isWhite ? 'white' : 'black'));
        svg.innerHTML = defs + inner;
        return svg;
    };

}());
