package timolr.chess.game.pieces.grade1;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class CoilPiece extends Piece {

    public CoilPiece(Teams team) {
        setName("Coil");
        setTeam(team);
        setGrade(Grade.GRADE_1);
        setBaseRange(8);
        setCanMoveForwards(true);
        setCanMoveBackwards(true);
        setCanMoveSideways(true);
        setCanMoveDiagonal(false);
        setCanMoveInLShape(false);
        setCanJump(false);
        setCanMove(true);
        setCanCapture(true);
    }
}
