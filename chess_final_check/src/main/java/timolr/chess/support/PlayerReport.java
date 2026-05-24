package timolr.chess.support;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "player_reports")
public class PlayerReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "reporter_id")
    private Long reporterId;

    @Column(name = "reporter_username", length = 50)
    private String reporterUsername;

    @Column(name = "target_id")
    private Long targetId;

    @Column(name = "target_username", length = 50)
    private String targetUsername;

    @Column(nullable = false, length = 100)
    private String reason;

    @Column(nullable = false, length = 20)
    private String state = "open"; // "open", "review", "resolved"

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public Long getReporterId() { return reporterId; }
    public void setReporterId(Long reporterId) { this.reporterId = reporterId; }
    public String getReporterUsername() { return reporterUsername; }
    public void setReporterUsername(String reporterUsername) { this.reporterUsername = reporterUsername; }
    public Long getTargetId() { return targetId; }
    public void setTargetId(Long targetId) { this.targetId = targetId; }
    public String getTargetUsername() { return targetUsername; }
    public void setTargetUsername(String targetUsername) { this.targetUsername = targetUsername; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
