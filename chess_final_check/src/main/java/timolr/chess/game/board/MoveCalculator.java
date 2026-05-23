package timolr.chess.game.board;

import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

public class MoveCalculator {

    private final Board board;

    public MoveCalculator(Board board) {
        this.board = board;
    }

    public Set<Move> getMoveSet(Piece piece) {
        if (piece == null || piece.getCurrentCell() == null) {
            return Collections.emptySet();
        }
        if (piece.isImmovable()) return Collections.emptySet();

        int fwd = forwardDir(piece);
        Set<Move> moves = new HashSet<>();

        if (piece.isCanMoveForwards())  moves.addAll(slide(piece, fwd,  0));
        if (piece.isCanMoveBackwards()) moves.addAll(slide(piece, -fwd, 0));
        if (piece.isCanMoveSideways()) {
            moves.addAll(slide(piece, 0,  1));
            moves.addAll(slide(piece, 0, -1));
        }
        if (piece.isCanMoveDiagonal()) {
            moves.addAll(slide(piece,  fwd,  1));
            moves.addAll(slide(piece,  fwd, -1));
            moves.addAll(slide(piece, -fwd,  1));
            moves.addAll(slide(piece, -fwd, -1));
        }
        if (piece.isCanMoveInLShape()) moves.addAll(getLShapeMoves(piece));

        return moves;
    }

    public Set<Move> slide(Piece piece, int rowDelta, int rankDelta) {
        Set<Move> moves = new HashSet<>();
        if (piece == null || piece.getCurrentCell() == null) return moves;

        Cell current = piece.getCurrentCell();
        for (int i = 1; i <= piece.getRange(); i++) {
            char newRow  = (char)(current.getRow()  + rowDelta  * i);
            int  newRank = current.getRank() + rankDelta * i;

            Cell target = board.getCell(newRow, newRank);
            if (target == null) break;  // off board

            if (target.isHasPiece()) {
                if (isFriendly(target, piece)) {
                    if (!piece.isCanJump()) break; // blocked
                    continue;
                } else {
                    if (piece.isCanCapture()) moves.add(captureMove(piece, target));
                    break;
                }
            }

            moves.add(quietMove(piece, target));
        }
        return moves;
    }

    public Set<Move> slideWithCaptureRange(Piece piece, int rowDelta, int rankDelta,
                                           int moveRange, int captureRange) {
        Set<Move> moves = new HashSet<>();
        if (piece == null || piece.getCurrentCell() == null) return moves;

        Cell current = piece.getCurrentCell();
        int  maxRange = Math.max(moveRange, captureRange);

        for (int i = 1; i <= maxRange; i++) {
            char newRow  = (char)(current.getRow()  + rowDelta  * i);
            int  newRank = current.getRank() + rankDelta * i;
            Cell target  = board.getCell(newRow, newRank);
            if (target == null) break;

            boolean inMoveRange    = i <= moveRange;
            boolean inCaptureRange = i <= captureRange;

            if (target.isHasPiece()) {
                if (isFriendly(target, piece)) {
                    break; // blocked
                } else if (inCaptureRange && piece.isCanCapture()) {
                    moves.add(captureMove(piece, target));
                }
                break;
            }

            if (inMoveRange) moves.add(quietMove(piece, target));
        }
        return moves;
    }

    public Set<Move> getLShapeMoves(Piece piece) {
        Set<Move> moves = new HashSet<>();
        if (piece == null || piece.getCurrentCell() == null) return moves;

        int[][] offsets = {
                { 2,  1}, { 2, -1}, {-2,  1}, {-2, -1},
                { 1,  2}, { 1, -2}, {-1,  2}, {-1, -2}
        };
        Cell current = piece.getCurrentCell();
        for (int[] off : offsets) {
            char newRow  = (char)(current.getRow()  + off[0]);
            int  newRank = current.getRank() + off[1];
            Cell target  = board.getCell(newRow, newRank);
            if (target == null) continue;
            if (target.isHasPiece()) {
                if (!isFriendly(target, piece) && piece.isCanCapture())
                    moves.add(captureMove(piece, target));
            } else {
                moves.add(quietMove(piece, target));
            }
        }
        return moves;
    }

    public Set<Move> getKingPatternMoves(Piece piece) {
        Set<Move> moves = new HashSet<>();
        if (piece == null || piece.getCurrentCell() == null) return moves;
        Cell cur = piece.getCurrentCell();
        for (int dr = -1; dr <= 1; dr++) {
            for (int df = -1; df <= 1; df++) {
                if (dr == 0 && df == 0) continue;
                Cell target = board.getCell((char)(cur.getRow() + dr), cur.getRank() + df);
                if (target == null) continue;
                if (target.isHasPiece()) {
                    if (!isFriendly(target, piece) && piece.isCanCapture())
                        moves.add(captureMove(piece, target));
                } else {
                    moves.add(quietMove(piece, target));
                }
            }
        }
        return moves;
    }

    public Set<Move> getWardenZMoves(Piece piece) {
        Set<Move> moves = new HashSet<>();
        if (piece == null || piece.getCurrentCell() == null) return moves;
        int fwd = forwardDir(piece);
        Cell cur = piece.getCurrentCell();

        int[][] diagEnds = {
                { fwd * 2,  2 },
                { fwd * 2, -2 },
                {-fwd * 2,  2 },
                {-fwd * 2, -2 }
        };

        for (int[] end : diagEnds) {
            char tipRow  = (char)(cur.getRow()  + end[0]);
            int  tipRank = cur.getRank() + end[1];
            for (int df = -2; df <= 2; df++) {
                if (df == 0) continue;
                char newRow  = tipRow;
                int  newRank = tipRank + df;
                Cell target  = board.getCell(newRow, newRank);
                if (target == null) continue;
                if (target.isHasPiece()) {
                    if (!isFriendly(target, piece) && piece.isCanCapture())
                        moves.add(captureMove(piece, target));
                } else {
                    moves.add(quietMove(piece, target));
                }
            }
        }
        return moves;
    }

    public Set<Move> getPrinceYMoves(Piece piece) {
        Set<Move> moves = new HashSet<>();
        int fwd = forwardDir(piece);
        moves.addAll(slide(piece,  fwd,  1));
        moves.addAll(slide(piece,  fwd, -1));
        moves.addAll(slide(piece, -fwd,  0));
        return moves;
    }

    public Set<Move> getBirdPlusMoves(Piece piece) {
        Set<Move> moves = new HashSet<>();
        if (piece == null || piece.getCurrentCell() == null) return moves;

        int[][] dirs = {{1,0},{-1,0},{0,1},{0,-1}};
        Cell cur = piece.getCurrentCell();

        for (int[] dir : dirs) {
            // Adjacent capture cell (1 step)
            char adjRow  = (char)(cur.getRow()  + dir[0]);
            int  adjRank = cur.getRank() + dir[1];
            Cell adjCell = board.getCell(adjRow, adjRank);
            if (adjCell != null && adjCell.isHasPiece()
                    && !isFriendly(adjCell, piece) && piece.isCanCapture()) {
                moves.add(captureMove(piece, adjCell));
            }

            Cell farthest = null;
            for (int i = 1; i <= 8; i++) {
                char newRow  = (char)(cur.getRow()  + dir[0] * i);
                int  newRank = cur.getRank() + dir[1] * i;
                Cell target  = board.getCell(newRow, newRank);
                if (target == null) break;
                if (!target.isHasPiece()) farthest = target;
                // Keep scanning (bird jumps over occupied cells)
            }
            if (farthest != null) moves.add(quietMove(piece, farthest));
        }
        return moves;
    }

    public Set<Move> getPrincessOMoves(Piece piece) {
        Set<Move> moves = new HashSet<>();
        if (piece == null || piece.getCurrentCell() == null) return moves;
        Cell cur = piece.getCurrentCell();

        int[][] cardinals = {{2,0},{-2,0},{0,2},{0,-2}};
        for (int[] c : cardinals) {
            char newRow  = (char)(cur.getRow()  + c[0]);
            int  newRank = cur.getRank() + c[1];
            Cell target  = board.getCell(newRow, newRank);
            if (target == null) continue;
            if (target.isHasPiece()) {
                if (!isFriendly(target, piece) && piece.isCanCapture())
                    moves.add(captureMove(piece, target));
            } else {
                moves.add(quietMove(piece, target));
            }
        }

        int[][] diags = {{1,1},{1,-1},{-1,1},{-1,-1}};
        for (int[] d : diags) {
            char newRow  = (char)(cur.getRow()  + d[0]);
            int  newRank = cur.getRank() + d[1];
            Cell target  = board.getCell(newRow, newRank);
            if (target == null) continue;
            if (target.isHasPiece()) {
                if (!isFriendly(target, piece) && piece.isCanCapture())
                    moves.add(captureMove(piece, target));
            } else {
                moves.add(quietMove(piece, target));
            }
        }
        return moves;
    }

    private int forwardDir(Piece piece) {
        return (piece.getTeam() != null)
                ? piece.getTeam().getForwardDirection()
                : 1;
    }

    private boolean isFriendly(Cell cell, Piece piece) {
        return cell.isHasPiece()
                && cell.getPiece() != null
                && cell.getPiece().getTeam() == piece.getTeam();
    }

    private Move quietMove(Piece piece, Cell target) {
        Move m = new Move();
        m.setPiece(piece);
        m.setCell(target);
        m.setLegal(true);
        m.setCapture(false);
        return m;
    }

    private Move captureMove(Piece piece, Cell target) {
        Move m = new Move();
        m.setPiece(piece);
        m.setCell(target);
        m.setLegal(true);
        m.setCapture(true);
        return m;
    }
}