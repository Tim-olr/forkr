package timolr.chess.game.pieces;

import timolr.chess.game.ability.NoAbility;
import timolr.chess.game.ability.PieceAbility;
import timolr.chess.game.board.Cell;
import timolr.chess.game.board.Move;

import java.util.Set;

public class Piece {

    private long id;

    private String name;
    private String description;
    private Grade  grade;

    private Teams team;

    private int baseRange;

    private int effectiveRange;

    private boolean canJump;
    private boolean canMoveBackwards;
    private boolean canMoveForwards;
    private boolean canMoveSideways;
    private boolean canMoveDiagonal;
    private boolean canMoveInLShape;
    private boolean canMove;
    private boolean canCapture;

    private boolean canOnlyCaptureDiagonal;
    private boolean canOnlyMoveForwardCapture;
    private boolean immovable;

    private int moveCount = 0;

    private PieceAbility ability = NoAbility.INSTANCE;

    private Set<Move> legalMoves;
    private Set<Move> possibleMoves;

    private Cell currentCell;

    public void resetEffectiveRange() {
        this.effectiveRange = this.baseRange;
    }

    public void addRangeBoost(int amount) {
        this.effectiveRange += amount;
    }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Grade getGrade() { return grade; }
    public void setGrade(Grade grade) { this.grade = grade; }

    public Teams getTeam() { return team; }
    public void setTeam(Teams team) { this.team = team; }

    public int getBaseRange() { return baseRange; }
    public void setBaseRange(int baseRange) {
        this.baseRange = baseRange;
        this.effectiveRange = baseRange;
    }

    public int getRange() { return effectiveRange; }

    public boolean isCanJump() { return canJump; }
    public void setCanJump(boolean canJump) { this.canJump = canJump; }

    public boolean isCanMoveBackwards() { return canMoveBackwards; }
    public void setCanMoveBackwards(boolean v) { this.canMoveBackwards = v; }

    public boolean isCanMoveForwards() { return canMoveForwards; }
    public void setCanMoveForwards(boolean v) { this.canMoveForwards = v; }

    public boolean isCanMoveSideways() { return canMoveSideways; }
    public void setCanMoveSideways(boolean v) { this.canMoveSideways = v; }

    public boolean isCanMoveDiagonal() { return canMoveDiagonal; }
    public void setCanMoveDiagonal(boolean v) { this.canMoveDiagonal = v; }

    public boolean isCanMoveInLShape() { return canMoveInLShape; }
    public void setCanMoveInLShape(boolean v) { this.canMoveInLShape = v; }

    public boolean isCanMove() { return canMove; }
    public void setCanMove(boolean canMove) { this.canMove = canMove; }

    public boolean isCanCapture() { return canCapture; }
    public void setCanCapture(boolean canCapture) { this.canCapture = canCapture; }

    public boolean isCanOnlyCaptureDiagonal() { return canOnlyCaptureDiagonal; }
    public void setCanOnlyCaptureDiagonal(boolean v) { this.canOnlyCaptureDiagonal = v; }

    public boolean isImmovable() { return immovable; }
    public void setImmovable(boolean immovable) { this.immovable = immovable; }

    public int getMoveCount() { return moveCount; }
    public void incrementMoveCount() { this.moveCount++; }

    public PieceAbility getAbility() { return ability; }
    public void setAbility(PieceAbility ability) {
        this.ability = (ability != null) ? ability : NoAbility.INSTANCE;
    }

    public Set<Move> getLegalMoves() { return legalMoves; }
    public void setLegalMoves(Set<Move> legalMoves) { this.legalMoves = legalMoves; }

    public Set<Move> getPossibleMoves() { return possibleMoves; }
    public void setPossibleMoves(Set<Move> possibleMoves) { this.possibleMoves = possibleMoves; }

    public Cell getCurrentCell() { return currentCell; }
    public void setCurrentCell(Cell currentCell) { this.currentCell = currentCell; }
}