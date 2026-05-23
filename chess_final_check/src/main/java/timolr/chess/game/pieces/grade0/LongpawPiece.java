package timolr.chess.game.pieces.grade0;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class LongpawPiece extends Piece {
    public LongpawPiece(Teams team) {
        setName("Longpaw");
        setTeam(team);
        setGrade(Grade.GRADE_0);
        setBaseRange(2);
        setCanMoveForwards(true);
        setCanMoveBackwards(false);
        setCanMoveSideways(false);
        setCanMoveDiagonal(false);
        setCanOnlyCaptureDiagonal(true);
        setCanMoveInLShape(false);
        setCanJump(false);
        setCanMove(true);
        setCanCapture(true);
    }
}
