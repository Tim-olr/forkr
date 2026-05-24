package timolr.chess.game;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "match_records")
public class MatchRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "white_user_id")
    private Long whiteUserId;

    @Column(name = "white_username", length = 50)
    private String whiteUsername;

    @Column(name = "black_user_id")
    private Long blackUserId;

    @Column(name = "black_username", length = 50)
    private String blackUsername;

    @Column(length = 30)
    private String variant;

    @Column(length = 10)
    private String result; // "1-0", "0-1", "1/2-1/2"

    @Column(name = "move_count")
    private int moveCount;

    @Column(name = "duration_seconds")
    private int durationSeconds;

    @Column(nullable = false)
    private boolean flagged = false;

    @Column(name = "played_at", nullable = false)
    private LocalDateTime playedAt;

    @PrePersist
    public void prePersist() {
        if (playedAt == null) playedAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public Long getWhiteUserId() { return whiteUserId; }
    public void setWhiteUserId(Long whiteUserId) { this.whiteUserId = whiteUserId; }
    public String getWhiteUsername() { return whiteUsername; }
    public void setWhiteUsername(String whiteUsername) { this.whiteUsername = whiteUsername; }
    public Long getBlackUserId() { return blackUserId; }
    public void setBlackUserId(Long blackUserId) { this.blackUserId = blackUserId; }
    public String getBlackUsername() { return blackUsername; }
    public void setBlackUsername(String blackUsername) { this.blackUsername = blackUsername; }
    public String getVariant() { return variant; }
    public void setVariant(String variant) { this.variant = variant; }
    public String getResult() { return result; }
    public void setResult(String result) { this.result = result; }
    public int getMoveCount() { return moveCount; }
    public void setMoveCount(int moveCount) { this.moveCount = moveCount; }
    public int getDurationSeconds() { return durationSeconds; }
    public void setDurationSeconds(int durationSeconds) { this.durationSeconds = durationSeconds; }
    public boolean isFlagged() { return flagged; }
    public void setFlagged(boolean flagged) { this.flagged = flagged; }
    public LocalDateTime getPlayedAt() { return playedAt; }
    public void setPlayedAt(LocalDateTime playedAt) { this.playedAt = playedAt; }

    public String getFormattedDuration() {
        int h = durationSeconds / 3600;
        int m = (durationSeconds % 3600) / 60;
        int s = durationSeconds % 60;
        if (h > 0) return String.format("%d:%02d:%02d", h, m, s);
        return String.format("%d:%02d", m, s);
    }
}
