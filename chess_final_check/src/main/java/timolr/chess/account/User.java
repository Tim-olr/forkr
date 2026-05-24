package timolr.chess.account;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {

    public static final String ROLE_OWNER    = "OWNER";
    public static final String ROLE_CO_OWNER = "CO_OWNER";
    public static final String ROLE_ADMIN    = "ADMIN";
    public static final String ROLE_USER     = "USER";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false, length = 50)
    private String username;

    @Column(unique = true, nullable = false, length = 100)
    private String email;

    @Column(name = "password_hash", nullable = false, length = 60)
    private String passwordHash;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "is_admin", nullable = false)
    private boolean admin = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "user_role", length = 20)
    private UserRole role;

    @Column(name = "elo", nullable = false)
    private int elo = 200;

    @Column(name = "email_verified", nullable = false)
    private boolean emailVerified = false;

    @Column(name = "verification_token", length = 64)
    private String verificationToken;

    @Column(name = "verification_expiry")
    private LocalDateTime verificationExpiry;

    @Column(name = "profile_pic_path", length = 255)
    private String profilePicPath;

    @Column(name = "google_id", length = 255)
    private String googleId;

    @Column(name = "banned", nullable = false)
    private boolean banned = false;

    @Column(name = "ban_reason", columnDefinition = "TEXT")
    private String banReason;

    @Column(name = "reset_token", length = 64)
    private String resetToken;

    @Column(name = "reset_expiry")
    private LocalDateTime resetExpiry;

    @Column(name = "knowledge_points", nullable = false)
    private int knowledgePoints = 100;

    @Column(name = "unlocked_pieces", columnDefinition = "TEXT")
    private String unlockedPieces;

    @Column(name = "challenge_date")
    private java.time.LocalDate challengeDate;

    @Column(name = "challenge_flags", length = 100)
    private String challengeFlags;

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public boolean isAdmin() {
        if (role != null) return role != UserRole.USER;
        return admin;
    }
    public void setAdmin(boolean admin) { this.admin = admin; }

    public boolean isOwner() { return role == UserRole.OWNER; }
    public boolean isCoOwner() { return role == UserRole.CO_OWNER; }

    public UserRole getRole() { return role; }
    public void setRole(UserRole role) {
        this.role = role;
        this.admin = (role != null && role != UserRole.USER);
    }

    public String getRoleName() {
        if (role == null) return "Player";
        switch (role) {
            case OWNER:    return "Owner";
            case CO_OWNER: return "Co-Owner";
            case ADMIN:    return "Admin";
            default:       return "Player";
        }
    }

    public int getElo() { return elo; }
    public void setElo(int elo) { this.elo = elo; }

    public boolean isEmailVerified() { return emailVerified; }
    public void setEmailVerified(boolean emailVerified) { this.emailVerified = emailVerified; }

    public String getVerificationToken() { return verificationToken; }
    public void setVerificationToken(String verificationToken) { this.verificationToken = verificationToken; }

    public LocalDateTime getVerificationExpiry() { return verificationExpiry; }
    public void setVerificationExpiry(LocalDateTime verificationExpiry) { this.verificationExpiry = verificationExpiry; }

    public String getProfilePicPath() { return profilePicPath; }
    public void setProfilePicPath(String profilePicPath) { this.profilePicPath = profilePicPath; }

    public String getGoogleId() { return googleId; }
    public void setGoogleId(String googleId) { this.googleId = googleId; }

    public boolean isBanned() { return banned; }
    public void setBanned(boolean banned) { this.banned = banned; }

    public String getBanReason() { return banReason; }
    public void setBanReason(String banReason) { this.banReason = banReason; }

    public String getResetToken() { return resetToken; }
    public void setResetToken(String resetToken) { this.resetToken = resetToken; }

    public LocalDateTime getResetExpiry() { return resetExpiry; }
    public void setResetExpiry(LocalDateTime resetExpiry) { this.resetExpiry = resetExpiry; }

    public int getKnowledgePoints() { return knowledgePoints; }
    public void setKnowledgePoints(int knowledgePoints) { this.knowledgePoints = knowledgePoints; }

    public String getUnlockedPieces() { return unlockedPieces; }
    public void setUnlockedPieces(String unlockedPieces) { this.unlockedPieces = unlockedPieces; }

    public java.time.LocalDate getChallengeDate() { return challengeDate; }
    public void setChallengeDate(java.time.LocalDate challengeDate) { this.challengeDate = challengeDate; }

    public String getChallengeFlags() { return challengeFlags; }
    public void setChallengeFlags(String challengeFlags) { this.challengeFlags = challengeFlags; }
}
