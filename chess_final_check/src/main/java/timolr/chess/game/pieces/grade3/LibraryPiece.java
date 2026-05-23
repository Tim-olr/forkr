package timolr.chess.game.pieces.grade3;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class LibraryPiece extends Piece {

    public LibraryPiece(Teams team) {
        setName("Library");
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
