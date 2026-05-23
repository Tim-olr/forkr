package timolr.chess.game.pieces.grade1;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class LancerPiece extends Piece {
    public LancerPiece(Teams team) {
        setName("Lancer");
        setTeam(team);
        setGrade(Grade.GRADE_1);
        setBaseRange(4);
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
