package timolr.chess.game.pieces.grade2;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class BootPiece extends Piece {

    public BootPiece(Teams team) {
        setName("Boot");
        setTeam(team);
        setGrade(Grade.GRADE_2);
        setBaseRange(8);
        setCanMoveForwards(true);
        setCanMoveBackwards(true);
        setCanMoveSideways(true);
        setCanMoveDiagonal(true);
        setCanMoveInLShape(false);
        setCanJump(true);
        setCanMove(true);
        setCanCapture(true);
    }
}
