package timolr.chess.game.pieces.grade1;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class PrincePiece extends Piece {
    public PrincePiece(Teams team) {
        setName("Prince");
        setTeam(team);
        setGrade(Grade.GRADE_1);
        setBaseRange(8);
        setCanMoveForwards(false);
        setCanMoveBackwards(true);
        setCanMoveSideways(false);
        setCanMoveDiagonal(true);
        setCanMoveInLShape(false);
        setCanJump(false);
        setCanMove(true);
        setCanCapture(true);
    }
}
