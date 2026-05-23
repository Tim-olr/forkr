package timolr.chess.action;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.PasswordHasher;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.army.Army;
import timolr.chess.army.ArmyDAO;
import timolr.chess.bot.Bot;
import timolr.chess.bot.BotDAO;
import timolr.chess.util.EmailService;
import timolr.chess.account.BanLog;
import timolr.chess.account.BanLogDAO;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

public class AdminAction extends ActionSupport {

    private List<User> allUsers;
    private List<Bot> allBots;
    private List<Army> allPresetArmies;

    private Long togglePresetId;
    private boolean togglePresetValue;

    private Long toggleAdminId;
    private boolean toggleAdminValue;

    // Edit user fields
    private Long editUserId;
    private String editUsername;
    private String editEmail;
    private String editPassword;

    // Ban user fields
    private Long banUserId;
    private boolean banValue;
    private String banReason;

    // Password reset field
    private Long resetUserId;

    // Academy management fields
    private Long acadUserId;
    private int acadKpDelta;
    private String acadUnlockedPieces;
    private InputStream jsonStream;

    // Bot fields
    private Long botId;
    private String botName;
    private int botElo;
    private String botCollection;
    private List<String> botVoicelines = new ArrayList<>();
    private List<String> botG0Lines = new ArrayList<>();
    private List<String> botG1Lines = new ArrayList<>();
    private List<String> botG2Lines = new ArrayList<>();
    private List<String> botG0TakeLines = new ArrayList<>();
    private List<String> botG1TakeLines = new ArrayList<>();
    private List<String> botG2TakeLines = new ArrayList<>();
    private List<String> botWinLines = new ArrayList<>();
    private List<String> botLoseLines = new ArrayList<>();
    private List<Long> botArmyIds = new ArrayList<>();

    private String loggedInUsername;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        loggedInUsername = (String) session.getAttribute("username");
        allUsers = new UserDAO().findAll();
        allBots = new BotDAO().findAll();
        allPresetArmies = new ArmyDAO().findPresets();
        return SUCCESS;
    }

    public String togglePreset() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        if (togglePresetId != null) {
            new ArmyDAO().setPreset(togglePresetId, togglePresetValue);
        }
        return "redirect";
    }

    public String toggleAdmin() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        if (toggleAdminId != null) {
            Long currentUserId = (Long) session.getAttribute("userId");
            if (!toggleAdminId.equals(currentUserId)) {
                new UserDAO().setAdmin(toggleAdminId, toggleAdminValue);
            }
        }
        return "redirect";
    }

    public String editUser() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        if (editUserId == null) return "redirect";

        UserDAO dao = new UserDAO();
        User target = dao.findById(editUserId);
        if (target == null) return "redirect";

        String newUsername = (editUsername != null && !editUsername.isBlank()) ? editUsername.trim() : null;
        String newEmail    = (editEmail != null && !editEmail.isBlank()) ? editEmail.trim() : null;

        if (newUsername != null && !newUsername.equals(target.getUsername()) && dao.usernameExists(newUsername)) {
            return "redirect";
        }
        if (newEmail != null && !newEmail.equals(target.getEmail()) && dao.emailExists(newEmail)) {
            return "redirect";
        }

        String newHash = (editPassword != null && !editPassword.isBlank())
                ? PasswordHasher.hash(editPassword) : null;

        dao.updateAccount(editUserId, newUsername, newEmail, newHash);
        return "redirect";
    }

    public String banUser() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        if (banUserId != null) {
            Long currentUserId = (Long) session.getAttribute("userId");
            if (!banUserId.equals(currentUserId)) {
                UserDAO dao = new UserDAO();
                User target = dao.findById(banUserId);
                if (target != null) {
                    String adminName = (String) session.getAttribute("username");
                    String reason = (banReason != null && !banReason.isBlank()) ? banReason.trim() : null;
                    dao.setBannedWithReason(banUserId, banValue, reason);

                    BanLog log = new BanLog();
                    log.setTargetUserId(banUserId);
                    log.setTargetUsername(target.getUsername());
                    log.setAdminUsername(adminName);
                    log.setAction(banValue ? "BAN" : "UNBAN");
                    log.setReason(reason);
                    new BanLogDAO().save(log);

                    if (banValue) {
                        EmailService.sendBanEmail(target.getEmail(), target.getUsername(), reason);
                    } else {
                        EmailService.sendUnbanEmail(target.getEmail(), target.getUsername(), reason);
                    }
                }
            }
        }
        return "redirect";
    }

    public String sendPasswordReset() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        if (resetUserId == null) return "redirect";

        UserDAO dao = new UserDAO();
        User target = dao.findById(resetUserId);
        if (target == null) return "redirect";

        byte[] bytes = new byte[32];
        new SecureRandom().nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        LocalDateTime expiry = LocalDateTime.now().plusHours(24);

        dao.setResetToken(resetUserId, token, expiry);

        HttpServletRequest req = ServletActionContext.getRequest();
        String baseUrl = req.getRequestURL().toString().replaceAll("/adminSendPasswordReset.*", "");
        boolean sent = EmailService.sendPasswordResetEmail(target.getEmail(), token, baseUrl);

        String flash;
        if (!EmailService.isConfigured()) {
            flash = "SMTP not configured — reset link: " + baseUrl + "/resetPassword?token=" + token;
        } else if (sent) {
            flash = "Password reset email sent to " + target.getEmail() + ".";
        } else {
            flash = "Failed to send reset email to " + target.getEmail() + ". Check server SMTP settings.";
        }
        session.setAttribute("adminFlash", flash);

        return "redirect";
    }

    public String createBot() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        if (botName == null || botName.isBlank()) return "redirect";

        Bot bot = new Bot();
        bot.setName(botName.trim());
        bot.setElo(botElo);
        if (botCollection != null && !botCollection.isBlank()) bot.setCollection(botCollection.trim());
        new BotDAO().save(bot);
        return "redirect";
    }

    public String saveBot() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        if (botId == null || botName == null || botName.isBlank()) return "redirect";

        new BotDAO().update(botId, botName.trim(), botElo, botCollection,
                botVoicelines,
                botG0Lines, botG1Lines, botG2Lines,
                botG0TakeLines, botG1TakeLines, botG2TakeLines,
                botWinLines, botLoseLines,
                botArmyIds);
        return "redirect";
    }

    public String uploadBotImage() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        if (botId == null) return "redirect";

        try {
            Part part = ServletActionContext.getRequest().getPart("botImage");
            if (part != null && part.getSize() > 0) {
                String contentType = part.getContentType();
                if (contentType != null && contentType.startsWith("image/")) {
                    String submitted = part.getSubmittedFileName();
                    String ext = (submitted != null && submitted.contains("."))
                            ? submitted.substring(submitted.lastIndexOf('.')).toLowerCase() : ".png";

                    String uploadDir = ServletActionContext.getServletContext().getRealPath("/uploads/bot-images/");
                    new File(uploadDir).mkdirs();

                    String fileName = botId + ext;
                    File dest = new File(uploadDir, fileName);
                    try (InputStream in = part.getInputStream()) {
                        Files.copy(in, dest.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    }

                    new BotDAO().updateImagePath(botId, "uploads/bot-images/" + fileName);
                }
            }
        } catch (Exception e) {
            session.setAttribute("adminFlash", "Image upload failed: " + e.getMessage());
        }

        return "redirect";
    }

    public String deleteBot() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        if (botId != null) {
            new BotDAO().delete(botId);
        }
        return "redirect";
    }

    public String manageAcademy() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return sendJson("{\"ok\":false,\"error\":\"forbidden\"}");
        }
        if (acadUserId == null) return sendJson("{\"ok\":false,\"error\":\"missing userId\"}");

        UserDAO dao = new UserDAO();
        User target = dao.findById(acadUserId);
        if (target == null) return sendJson("{\"ok\":false,\"error\":\"user not found\"}");

        dao.updateAcademy(acadUserId, acadKpDelta, acadUnlockedPieces);
        User updated = dao.findById(acadUserId);
        int newKp = updated != null ? updated.getKnowledgePoints() : target.getKnowledgePoints();
        String unlocked = updated != null ? (updated.getUnlockedPieces() != null ? updated.getUnlockedPieces() : "") : "";
        return sendJson("{\"ok\":true,\"kp\":" + newKp + ",\"unlocked\":\"" + unlocked.replace("\"","\\\"") + "\"}");
    }

    private String sendJson(String json) {
        jsonStream = new ByteArrayInputStream(json.getBytes(StandardCharsets.UTF_8));
        return SUCCESS;
    }

    // ── Getters / Setters ─────────────────────────────────────────────────────

    public List<User> getAllUsers() { return allUsers; }
    public List<Bot> getAllBots() { return allBots; }
    public List<Army> getAllPresetArmies() { return allPresetArmies; }
    public String getLoggedInUsername() { return loggedInUsername; }

    public Long getTogglePresetId() { return togglePresetId; }
    public void setTogglePresetId(Long togglePresetId) { this.togglePresetId = togglePresetId; }

    public boolean isTogglePresetValue() { return togglePresetValue; }
    public void setTogglePresetValue(boolean togglePresetValue) { this.togglePresetValue = togglePresetValue; }

    public Long getToggleAdminId() { return toggleAdminId; }
    public void setToggleAdminId(Long toggleAdminId) { this.toggleAdminId = toggleAdminId; }

    public boolean isToggleAdminValue() { return toggleAdminValue; }
    public void setToggleAdminValue(boolean toggleAdminValue) { this.toggleAdminValue = toggleAdminValue; }

    public Long getEditUserId() { return editUserId; }
    public void setEditUserId(Long editUserId) { this.editUserId = editUserId; }

    public String getEditUsername() { return editUsername; }
    public void setEditUsername(String editUsername) { this.editUsername = editUsername; }

    public String getEditEmail() { return editEmail; }
    public void setEditEmail(String editEmail) { this.editEmail = editEmail; }

    public String getEditPassword() { return editPassword; }
    public void setEditPassword(String editPassword) { this.editPassword = editPassword; }

    public Long getBanUserId() { return banUserId; }
    public void setBanUserId(Long banUserId) { this.banUserId = banUserId; }

    public boolean isBanValue() { return banValue; }
    public void setBanValue(boolean banValue) { this.banValue = banValue; }

    public String getBanReason() { return banReason; }
    public void setBanReason(String banReason) { this.banReason = banReason; }

    public Long getResetUserId() { return resetUserId; }
    public void setResetUserId(Long resetUserId) { this.resetUserId = resetUserId; }

    public Long getBotId() { return botId; }
    public void setBotId(Long botId) { this.botId = botId; }

    public String getBotName() { return botName; }
    public void setBotName(String botName) { this.botName = botName; }

    public int getBotElo() { return botElo; }
    public void setBotElo(int botElo) { this.botElo = botElo; }

    public String getBotCollection() { return botCollection; }
    public void setBotCollection(String botCollection) { this.botCollection = botCollection; }

    public List<String> getBotVoicelines() { return botVoicelines; }
    public void setBotVoicelines(List<String> botVoicelines) { this.botVoicelines = botVoicelines; }

    public List<String> getBotG0Lines() { return botG0Lines; }
    public void setBotG0Lines(List<String> botG0Lines) { this.botG0Lines = botG0Lines; }

    public List<String> getBotG1Lines() { return botG1Lines; }
    public void setBotG1Lines(List<String> botG1Lines) { this.botG1Lines = botG1Lines; }

    public List<String> getBotG2Lines() { return botG2Lines; }
    public void setBotG2Lines(List<String> botG2Lines) { this.botG2Lines = botG2Lines; }

    public List<String> getBotG0TakeLines() { return botG0TakeLines; }
    public void setBotG0TakeLines(List<String> botG0TakeLines) { this.botG0TakeLines = botG0TakeLines; }

    public List<String> getBotG1TakeLines() { return botG1TakeLines; }
    public void setBotG1TakeLines(List<String> botG1TakeLines) { this.botG1TakeLines = botG1TakeLines; }

    public List<String> getBotG2TakeLines() { return botG2TakeLines; }
    public void setBotG2TakeLines(List<String> botG2TakeLines) { this.botG2TakeLines = botG2TakeLines; }

    public List<String> getBotWinLines() { return botWinLines; }
    public void setBotWinLines(List<String> botWinLines) { this.botWinLines = botWinLines; }

    public List<String> getBotLoseLines() { return botLoseLines; }
    public void setBotLoseLines(List<String> botLoseLines) { this.botLoseLines = botLoseLines; }

    public List<Long> getBotArmyIds() { return botArmyIds; }
    public void setBotArmyIds(List<Long> botArmyIds) { this.botArmyIds = botArmyIds; }

    public Long getAcadUserId() { return acadUserId; }
    public void setAcadUserId(Long acadUserId) { this.acadUserId = acadUserId; }

    public int getAcadKpDelta() { return acadKpDelta; }
    public void setAcadKpDelta(int acadKpDelta) { this.acadKpDelta = acadKpDelta; }

    public String getAcadUnlockedPieces() { return acadUnlockedPieces; }
    public void setAcadUnlockedPieces(String acadUnlockedPieces) { this.acadUnlockedPieces = acadUnlockedPieces; }

    public InputStream getJsonStream() { return jsonStream; }
}
