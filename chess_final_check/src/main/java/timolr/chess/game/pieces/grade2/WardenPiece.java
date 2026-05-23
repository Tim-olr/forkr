package timolr.chess.game.pieces.grade2;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class WardenPiece extends Piece {
    public WardenPiece(Teams team) {
        setName("Warden");
        setTeam(team);
        setGrade(Grade.GRADE_2);
        setBaseRange(2);
        setCanMoveForwards(true);
        setCanMoveBackwards(true);
        setCanMoveSideways(true);
        setCanMoveDiagonal(true);
        setCanMoveInLShape(false);
        setCanJump(false);
        setCanMove(true);
        setCanCapture(true);
    }
}
