package timolr.chess.game.pieces.grade1;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class DukePiece extends Piece {
    public DukePiece(Teams team) {
        setName("Duke");
        setTeam(team);
        setGrade(Grade.GRADE_1);
        setBaseRange(3);
        setCanMoveForwards(false);
        setCanMoveBackwards(false);
        setCanMoveSideways(false);
        setCanMoveDiagonal(false);
        setCanMoveInLShape(false);
        setCanJump(true);
        setCanMove(true);
        setCanCapture(true);
    }
}
