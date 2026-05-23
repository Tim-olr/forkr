package timolr.chess.game.ability;

import timolr.chess.game.board.Board;
import timolr.chess.game.board.Move;
import timolr.chess.game.pieces.Piece;

import java.util.Set;

/**
 * A PieceAbility encapsulates everything a piece can do beyond plain movement.
 *
 * Implement only the hooks you need — all methods have empty defaults so
 * simple pieces can implement just one or two.
 *
 * Hook call order each turn:
 *   1. beforeMoveCalculation  — modify effective range / flags before moves are generated
 *   2. afterMoveCalculation   — add or remove moves after the standard set is built
 *   3. onMove                 — called when the piece actually moves
 *   4. onCapture              — called when this piece captures another
 *   5. onCapturedBy           — called when this piece is captured
 *   6. onTurnEnd              — called at the end of the owning team's turn
 *   7. onOpponentTurnEnd      — called at the end of the opponent's turn
 */
public interface PieceAbility {

    /**
     * Called before move generation. Can mutate temporary state on the piece
     * (e.g. apply a Princess range boost). Do NOT permanently change base stats.
     *
     * @param piece the piece being evaluated
     * @param board current board state
     */
    default void beforeMoveCalculation(Piece piece, Board board) {}

    /**
     * Called after the standard move set is generated. Can add or veto moves.
     *
     * @param piece  the piece being evaluated
     * @param board  current board state
     * @param moves  the move set — mutate freely
     */
    default void afterMoveCalculation(Piece piece, Board board, Set<Move> moves) {}

    /**
     * Called when the piece physically moves from one cell to another.
     *
     * @param piece    the moving piece
     * @param board    current board state
     * @param move     the move that was executed
     * @param moveNumber total move count for this piece (1-indexed)
     */
    default void onMove(Piece piece, Board board, Move move, int moveNumber) {}

    /**
     * Called when this piece captures an enemy piece.
     *
     * @param piece   the capturing piece
     * @param board   current board state
     * @param captured the piece that was captured
     */
    default void onCapture(Piece piece, Board board, Piece captured) {}

    /**
     * Called when this piece is captured by an enemy.
     *
     * @param piece    this piece (about to be removed)
     * @param board    current board state
     * @param capturer the enemy piece that performed the capture
     */
    default void onCapturedBy(Piece piece, Board board, Piece capturer) {}

    /**
     * Called at the end of the owning team's turn.
     *
     * @param piece the piece
     * @param board current board state
     * @param turn  the turn number that just ended
     */
    default void onTurnEnd(Piece piece, Board board, int turn) {}

    /**
     * Called at the end of the opponent's turn.
     *
     * @param piece the piece
     * @param board current board state
     * @param turn  the opponent turn number that just ended
     */
    default void onOpponentTurnEnd(Piece piece, Board board, int turn) {}
}