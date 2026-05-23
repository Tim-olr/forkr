package timolr.chess.game.event;

import timolr.chess.game.ability.PieceAbility;
import timolr.chess.game.board.Board;
import timolr.chess.game.board.Move;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

import java.util.ArrayList;
import java.util.List;

/**
 * Central event dispatcher. The game loop calls these methods at the right
 * moments and the bus fans out to every living piece's PieceAbility.
 */
public class TurnEventBus {

    private final Board board;

    public TurnEventBus(Board board) {
        this.board = board;
    }

    // -------------------------------------------------------------------------
    // Game-loop hooks — call these from your game loop
    // -------------------------------------------------------------------------

    /** Call after a piece physically moves. */
    public void fireOnMove(Piece piece, Move move, int moveNumber) {
        piece.getAbility().onMove(piece, board, move, moveNumber);
    }

    /**
     * Call when a capture occurs.
     * Handles Herbalist retaliation internally before removing the captured piece.
     */
    public void fireOnCapture(Piece capturer, Piece captured) {
        // Notify the captured piece first — it may retaliate (Herbalist)
        captured.getAbility().onCapturedBy(captured, board, capturer);
        // Then notify the capturer
        capturer.getAbility().onCapture(capturer, board, captured);
    }

    /** Call at the end of the given team's turn. */
    public void fireTurnEnd(Teams activeTeam, int turn) {
        for (Piece piece : snapshot()) {
            if (piece.getTeam() == activeTeam) {
                piece.getAbility().onTurnEnd(piece, board, turn);
            } else {
                piece.getAbility().onOpponentTurnEnd(piece, board, turn);
            }
        }
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    /** Snapshot to avoid ConcurrentModificationException when abilities remove pieces. */
    private List<Piece> snapshot() {
        return new ArrayList<>(board.getAllPieces());
    }
}