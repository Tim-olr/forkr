package timolr.chess.game.board;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

public class MoveSet {
    private Set<Move> moves;

    public Set<Move> getMoveSet() {return Collections.emptySet();}

    public void addMove(Move move) {
        if (moves == null) {
            moves = new HashSet<Move>();
        }
        moves.add(move);
    }
}
