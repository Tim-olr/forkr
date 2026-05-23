package timolr.chess.game.pieces.grade0;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class HollowPiece extends Piece {
    public HollowPiece(Teams team) {
        setName("Hollow");
        setTeam(team);
        setGrade(Grade.GRADE_0);
        setBaseRange(2);
        setCanMoveForwards(true);
        setCanMoveBackwards(false);
        setCanMoveSideways(false);
        setCanMoveDiagonal(false);
        setCanMoveInLShape(false);
        setCanJump(true);
        setCanMove(true);
        setCanCapture(true);
    }
}
