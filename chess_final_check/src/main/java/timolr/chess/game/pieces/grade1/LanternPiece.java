package timolr.chess.game.pieces.grade1;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class LanternPiece extends Piece {

    public LanternPiece(Teams team) {
        setName("Lantern");
        setTeam(team);
        setGrade(Grade.GRADE_1);
        setBaseRange(2);
        setCanMoveForwards(false);
        setCanMoveBackwards(false);
        setCanMoveSideways(false);
        setCanMoveDiagonal(true);
        setCanMoveInLShape(false);
        setCanJump(true);
        setCanMove(true);
        setCanCapture(true);
    }
}
