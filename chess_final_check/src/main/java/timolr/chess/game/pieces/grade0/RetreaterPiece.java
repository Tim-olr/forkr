package timolr.chess.game.pieces.grade0;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class RetreaterPiece extends Piece {
    public RetreaterPiece(Teams team) {
        setName("Retreater");
        setTeam(team);
        setGrade(Grade.GRADE_0);
        setBaseRange(1);
        setCanMoveForwards(true);
        setCanMoveBackwards(true);
        setCanMoveSideways(false);
        setCanMoveDiagonal(false);
        setCanMoveInLShape(false);
        setCanJump(false);
        setCanMove(true);
        setCanCapture(true);
    }
}
