package timolr.chess.game.pieces.grade2;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class QueenPiece extends Piece {

    public QueenPiece(Teams team) {
        setName("Queen");
        setTeam(team);
        setGrade(Grade.GRADE_2);
        setBaseRange(8);
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
