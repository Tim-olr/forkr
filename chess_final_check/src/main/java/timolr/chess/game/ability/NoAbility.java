package timolr.chess.game.ability;

/**
 * Default no-op ability used by pieces that have no special rules
 * beyond their movement pattern (e.g. standard Rook, Bishop, Knight).
 */
public class NoAbility implements PieceAbility {
    public static final NoAbility INSTANCE = new NoAbility();
    private NoAbility() {}
}