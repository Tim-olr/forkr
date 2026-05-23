package timolr.chess.army;

import jakarta.persistence.*;

@Entity
@Table(name = "army_pieces")
public class ArmyPiece {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "army_id", nullable = false)
    private Army army;

    @Column(name = "piece_type", nullable = false, length = 20)
    private String pieceType; // "KING", "QUEEN", "ROOK", "BISHOP", "KNIGHT", "PAWN"

    @Column(name = "board_col", nullable = false, length = 1)
    private String boardCol; // "A" through "H"

    @Column(name = "board_rank", nullable = false)
    private int boardRank; // 1-8

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Army getArmy() { return army; }
    public void setArmy(Army army) { this.army = army; }

    public String getPieceType() { return pieceType; }
    public void setPieceType(String pieceType) { this.pieceType = pieceType; }

    public String getBoardCol() { return boardCol; }
    public void setBoardCol(String boardCol) { this.boardCol = boardCol; }

    public int getBoardRank() { return boardRank; }
    public void setBoardRank(int boardRank) { this.boardRank = boardRank; }
}
