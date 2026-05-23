package timolr.chess.game.pieces;

public enum Teams {
    WHITE( 1),   // "forward" is increasing row A→H
    BLACK(-1);   // "forward" is decreasing row H→A

    private final int forwardDirection;

    Teams(int forwardDirection) {
        this.forwardDirection = forwardDirection;
    }

    public int getForwardDirection() { return forwardDirection; }
}