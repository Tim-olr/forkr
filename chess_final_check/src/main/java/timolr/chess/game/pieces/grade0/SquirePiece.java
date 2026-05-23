package timolr.chess.game.pieces.grade0;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class SquirePiece extends Piece {
    public SquirePiece(Teams team) {
        setName("Squire");
        setTeam(team);
        setGrade(Grade.GRADE_0);
        setBaseRange(1);
        setCanMoveForwards(true);
        setCanMoveBackwards(false);
        setCanMoveSideways(true);
        setCanMoveDiagonal(false);
        setCanMoveInLShape(false);
        setCanJump(false);
        setCanMove(true);
        setCanCapture(true);
    }
}
