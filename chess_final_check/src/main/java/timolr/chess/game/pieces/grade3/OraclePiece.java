package timolr.chess.game.pieces.grade3;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class OraclePiece extends Piece {

    public OraclePiece(Teams team) {
        setName("Oracle");
        setTeam(team);
        setGrade(Grade.GRADE_3);
        setBaseRange(1);
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
