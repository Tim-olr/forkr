package timolr.chess.game.pieces.grade1;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class JesterPiece extends Piece {
    public JesterPiece(Teams team) {
        setName("Jester");
        setTeam(team);
        setGrade(Grade.GRADE_1);
        setCanMoveSideways(true);
        setCanMoveForwards(true);
        setCanMoveBackwards(true);
        setCanMoveDiagonal(true);
        setBaseRange(2);
        setCanMoveInLShape(false);
        setCanJump(false);
        setCanMove(true);
        setCanCapture(true);
    }
}
