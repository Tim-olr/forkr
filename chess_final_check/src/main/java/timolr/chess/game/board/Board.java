package timolr.chess.game.board;

import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

import java.awt.Color;
import java.util.*;

public class Board {

    public static final char MIN_ROW  = 'A';
    public static final char MAX_ROW  = 'H';
    public static final int  MIN_RANK = 1;
    public static final int  MAX_RANK = 8;

    private final Cell[][] grid = new Cell[8][8];

    private final Map<Long, Piece> pieceMap = new HashMap<>();

    public Board() {
        initGrid();
    }

    private void initGrid() {
        for (int r = 0; r < 8; r++) {
            for (int f = 0; f < 8; f++) {
                Cell cell = new Cell();
                cell.setId((long) r * 8 + f);
                cell.setRow((char) (MIN_ROW + r));
                cell.setRank(MIN_RANK + f);
                cell.setColor(((r + f) % 2 == 0) ? Color.WHITE : Color.BLACK);
                grid[r][f] = cell;
            }
        }
    }

    public Cell getCell(char row, int rank) {
        int r = row  - MIN_ROW;
        int f = rank - MIN_RANK;
        if (r < 0 || r > 7 || f < 0 || f > 7) return null;
        return grid[r][f];
    }

    public boolean isInBounds(char row, int rank) {
        return getCell(row, rank) != null;
    }

    public void placePiece(Piece piece, char row, int rank) {
        Cell cell = getCell(row, rank);
        if (cell == null) throw new IllegalArgumentException(
                "Cell " + row + rank + " is out of bounds");

        if (piece.getCurrentCell() != null) {
            Cell old = piece.getCurrentCell();
            old.setHasPiece(false);
            old.setPiece(null);
        }

        cell.setHasPiece(true);
        cell.setPiece(piece);
        piece.setCurrentCell(cell);
        pieceMap.put(piece.getId(), piece);
    }

    public void removePiece(Piece piece) {
        if (piece.getCurrentCell() != null) {
            Cell cell = piece.getCurrentCell();
            cell.setHasPiece(false);
            cell.setPiece(null);
            piece.setCurrentCell(null);
        }
        pieceMap.remove(piece.getId());
    }

    public Collection<Piece> getAllPieces() {
        return Collections.unmodifiableCollection(pieceMap.values());
    }

    public List<Piece> getPiecesForTeam(Teams team) {
        List<Piece> result = new ArrayList<>();
        for (Piece p : pieceMap.values()) {
            if (p.getTeam() == team) result.add(p);
        }
        return result;
    }

    public List<Piece> getPiecesInRadius(char centreRow, int centreRank,
                                         int radius, Teams team) {
        List<Piece> result = new ArrayList<>();
        for (int dr = -radius; dr <= radius; dr++) {
            for (int df = -radius; df <= radius; df++) {
                if (dr == 0 && df == 0) continue;
                Cell c = getCell((char)(centreRow + dr), centreRank + df);
                if (c != null && c.isHasPiece() && c.getPiece().getTeam() == team) {
                    result.add(c.getPiece());
                }
            }
        }
        return result;
    }

    public Cell[][] getGrid() { return grid; }
}