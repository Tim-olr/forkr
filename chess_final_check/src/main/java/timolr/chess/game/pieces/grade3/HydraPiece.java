package timolr.chess.game.pieces.grade3;

import timolr.chess.game.pieces.Grade;
import timolr.chess.game.pieces.Piece;
import timolr.chess.game.pieces.Teams;

public class HydraPiece extends Piece {

    public HydraPiece(Teams team) {
        setName("Hydra");
        setTeam(team);
        setGrade(Grade.GRADE_3);
        setBaseRange(3);
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
