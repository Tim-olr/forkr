package timolr.chess.game.pieces.grade2;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class FeatherPiece extends Piece {

    public FeatherPiece(Teams team) {
        setName("Feather");
        setTeam(team);
        setGrade(Grade.GRADE_2);
        setBaseRange(1);
        setCanMoveForwards(false);
        setCanMoveBackwards(false);
        setCanMoveSideways(false);
        setCanMoveDiagonal(true);
        setCanMoveInLShape(false);
        setCanJump(false);
        setCanMove(true);
        setCanCapture(true);
    }
}
