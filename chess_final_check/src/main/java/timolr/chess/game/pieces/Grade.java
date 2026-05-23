package timolr.chess.game.pieces;

/**
 * Grade controls how many of a piece type can exist in a deck/on the board.
 *
 * GRADE_0 = max 8 per deck
 * GRADE_1 = max 2 per deck
 * GRADE_2 = max 1 per type, max 2 total grade-2 pieces
 * GRADE_3 = exactly 1 king. This grade is for different kings
 */
public enum Grade {
    GRADE_0(8),
    GRADE_1(2),
    GRADE_2(1),
    GRADE_3(1);

    private final int maxPerType;

    Grade(int maxPerType) {
        this.maxPerType = maxPerType;
    }

    public int getMaxPerType() { return maxPerType; }
}