package timolr.chess.game.board;

import timolr.chess.game.pieces.Piece;

import java.awt.*;

public class Cell {

    private long id;

    private char row; // eg: A
    private int rank; // eg: 1

    private Color color;

    private boolean hasPiece;
    private Piece piece;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public char getRow() {
        return row;
    }

    public void setRow(char row) {
        this.row = row;
    }

    public int getRank() {
        return rank;
    }

    public void setRank(int rank) {
        this.rank = rank;
    }

    public Color getColor() {
        return color;
    }

    public void setColor(Color color) {
        this.color = color;
    }

    public boolean isHasPiece() {
        return hasPiece;
    }

    public void setHasPiece(boolean hasPiece) {
        this.hasPiece = hasPiece;
    }

    public Piece getPiece() {
        return piece;
    }

    public void setPiece(Piece piece) {
        this.piece = piece;
    }
}
