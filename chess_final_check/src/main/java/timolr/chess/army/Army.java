package timolr.chess.army;

import jakarta.persistence.*;
import timolr.chess.account.User;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "armies")
public class Army {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id")
    private User owner;

    @Column(nullable = false, length = 10)
    private String team; // "WHITE" or "BLACK"

    @Column(name = "is_preset", nullable = false)
    private boolean preset = false;

    @Column(name = "is_active", nullable = false)
    private boolean active = false;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "army", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<ArmyPiece> pieces = new ArrayList<>();

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public User getOwner() { return owner; }
    public void setOwner(User owner) { this.owner = owner; }

    public String getTeam() { return team; }
    public void setTeam(String team) { this.team = team; }

    public boolean isPreset() { return preset; }
    public void setPreset(boolean preset) { this.preset = preset; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<ArmyPiece> getPieces() { return pieces; }
    public void setPieces(List<ArmyPiece> pieces) { this.pieces = pieces; }
}
