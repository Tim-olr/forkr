DROP SVG SPRITE FILES HERE
=========================

Naming convention:
  <sprite>_white.svg   — piece image for the White side
  <sprite>_black.svg   — piece image for the Black side

The <sprite> name must match the "sprite" field in PieceRegistry.java.

Examples for the built-in pieces (if you want custom graphics):
  pawn_white.svg / pawn_black.svg
  knight_white.svg / knight_black.svg
  rook_white.svg / rook_black.svg
  bishop_white.svg / bishop_black.svg
  jester_white.svg / jester_black.svg
  queen_white.svg / queen_black.svg
  king_white.svg / king_black.svg

If a file is missing, the Unicode symbol defined in PieceRegistry falls back automatically.

Recommended SVG canvas size: 45x45 px (the board cells are 60–70 px so the image
is scaled to fit; square canvases work best).
