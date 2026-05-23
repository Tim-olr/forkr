package timolr.chess.game.ability;

import timolr.chess.game.board.Board;
import timolr.chess.game.board.Move;
import timolr.chess.game.board.MoveCalculator;
import timolr.chess.game.pieces.Piece;

import java.util.Set;

public class HerbalistAbility implements PieceAbility {

    @Override
    public void afterMoveCalculation(Piece piece, Board board, Set<Move> moves) {
        MoveCalculator calc = new MoveCalculator(board);
        Set<Move> kingMoves = calc.getKingPatternMoves(piece);
        for (Move m : kingMoves) {
            if (m.isCapture()) moves.add(m);
        }
    }

    @Override
    public void onCapturedBy(Piece piece, Board board, Piece capturer) {
        board.removePiece(capturer);
    }
}