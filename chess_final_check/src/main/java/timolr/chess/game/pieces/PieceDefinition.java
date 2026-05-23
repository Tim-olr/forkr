package timolr.chess.game.pieces;

public class PieceDefinition {

    private final String  type;
    private final String  label;
    private final int     grade;
    private final String  sprite;
    private final String  whiteUnicode;
    private final String  blackUnicode;
    private final String  gameChar;
    private final boolean special;
    private final boolean canMoveForwards;
    private final boolean canMoveBackwards;
    private final boolean canMoveSideways;
    private final boolean canMoveDiagonally;
    private final boolean canJump;
    private final boolean canMoveInLShape;
    private final int     range;

    /**
     * Build a PieceDefinition by reading movement flags directly from a Piece instance.
     *
     * @param type         Unique UPPERCASE DB key (e.g. "ROOK")
     * @param label        Human-readable name shown in the Army Builder
     * @param sprite       Base name for SVG files, or null for Unicode-only
     * @param whiteUnicode Fallback symbol for White
     * @param blackUnicode Fallback symbol for Black
     * @param gameChar     Unique lowercase letter used on the JS board
     * @param special      true = use hardcoded pawn logic in JS (only needed for Pawn)
     * @param template     A piece instance (team doesn't matter) whose flags are copied
     */
    public PieceDefinition(String type, String label, String sprite,
                           String whiteUnicode, String blackUnicode, String gameChar,
                           boolean special, Piece template) {
        this.type = type;
        this.label = label;
        this.grade = template.getGrade().ordinal();
        this.sprite = sprite;
        this.whiteUnicode = whiteUnicode;
        this.blackUnicode = blackUnicode;
        this.gameChar = gameChar;
        this.special = special;
        this.canMoveForwards = template.isCanMoveForwards();
        this.canMoveBackwards = template.isCanMoveBackwards();
        this.canMoveSideways = template.isCanMoveSideways();
        this.canMoveDiagonally = template.isCanMoveDiagonal();
        this.canJump = template.isCanJump();
        this.canMoveInLShape = template.isCanMoveInLShape();
        int br = template.getBaseRange();
        this.range = (br == 0 || br >= 8) ? 0 : br;
    }

    public String  getType() { return type; }
    public String  getLabel() { return label; }
    public int     getGrade() { return grade; }
    public String  getSprite() { return sprite; }
    public String  getWhiteUnicode() { return whiteUnicode; }
    public String  getBlackUnicode() { return blackUnicode; }
    public String  getGameChar() { return gameChar; }
    public boolean isSpecial() { return special; }
    public boolean isCanMoveForwards() { return canMoveForwards; }
    public boolean isCanMoveBackwards() { return canMoveBackwards; }
    public boolean isCanMoveSideways() { return canMoveSideways; }
    public boolean isCanMoveDiagonally() { return canMoveDiagonally; }
    public boolean isCanJump() { return canJump; }
    public boolean isCanMoveInLShape() { return canMoveInLShape; }
    public int getRange() { return range; }
}
