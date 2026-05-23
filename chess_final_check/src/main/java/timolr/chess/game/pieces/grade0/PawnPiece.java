package timolr.chess.game.pieces.grade0;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class PawnPiece extends Piece {

    public PawnPiece(Teams team) {
        setName("Pawn");
        setTeam(team);
        setGrade(Grade.GRADE_0);
        setBaseRange(1);
        setCanMoveForwards(true);
        setCanMoveBackwards(false);
        setCanMoveSideways(false);
        setCanMoveDiagonal(false);
        setCanOnlyCaptureDiagonal(true);
        setCanMoveInLShape(false);
        setCanJump(false);
        setCanMove(true);
        setCanCapture(true);
    }
}
