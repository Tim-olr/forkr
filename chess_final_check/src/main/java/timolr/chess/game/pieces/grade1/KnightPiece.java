package timolr.chess.game.pieces.grade1;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class KnightPiece extends Piece {

    public KnightPiece(Teams team) {
        setName("Knight");
        setTeam(team);
        setGrade(Grade.GRADE_1);
        setBaseRange(2);
        setCanMoveForwards(false);
        setCanMoveBackwards(false);
        setCanMoveSideways(false);
        setCanMoveDiagonal(false);
        setCanMoveInLShape(true);
        setCanJump(true);
        setCanMove(true);
        setCanCapture(true);
    }
}
