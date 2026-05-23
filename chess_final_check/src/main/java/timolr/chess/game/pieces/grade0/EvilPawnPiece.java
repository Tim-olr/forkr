package timolr.chess.game.pieces.grade0;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class EvilPawnPiece extends Piece {
    public EvilPawnPiece(Teams team) {
        setName("Evil Pawn");
        setTeam(team);
        setGrade(Grade.GRADE_0);
        setBaseRange(1);
        setCanMoveForwards(true);
        setCanMoveBackwards(false);
        setCanMoveSideways(false);
        setCanMoveDiagonal(true);
        setCanMoveInLShape(false);
        setCanJump(false);
        setCanMove(true);
        setCanCapture(true);
    }
}
