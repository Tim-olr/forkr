package timolr.chess.action;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.bot.Bot;
import timolr.chess.bot.BotDAO;
import timolr.chess.game.MatchRecord;
import timolr.chess.game.MatchRecordDAO;
import timolr.chess.game.pieces.PieceRegistry;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class HomeAction extends ActionSupport {

    private String loggedInUsername;
    private int userElo;
    private int knowledgePoints;
    private int unlockedCount;
    private String allBotsJson = "[]";
    private List<MatchRecord> recentMatches;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            return "login";
        }
        loggedInUsername = (String) session.getAttribute("username");
        Long userId = (Long) session.getAttribute("userId");
        userElo = session.getAttribute("elo") != null ? (int) session.getAttribute("elo") : 0;

        UserDAO userDAO = new UserDAO();
        User user = userDAO.findById(userId);
        if (user != null) {
            knowledgePoints = user.getKnowledgePoints();
            // Count unlocked pieces
            String stored = user.getUnlockedPieces();
            int base = AcademyAction.DEFAULT_UNLOCKED.size();
            int extra = 0;
            if (stored != null && !stored.isBlank()) {
                for (String t : stored.split(",")) { if (!t.isBlank()) extra++; }
            }
            unlockedCount = base + extra;
        }

        int totalPieces = PieceRegistry.getAll().size();
        allBotsJson = serializeBots(new BotDAO().findAll());

        try {
            recentMatches = new MatchRecordDAO().findByUserId(userId, 5);
        } catch (Exception e) {
            recentMatches = new ArrayList<>();
        }

        return SUCCESS;
    }

    public String logout() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session != null) session.invalidate();
        return "login";
    }

    private String serializeBots(List<Bot> bots) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            List<Map<String, Object>> list = new ArrayList<>();
            for (Bot b : bots) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", b.getId()); m.put("name", b.getName());
                m.put("elo", b.getElo());
                m.put("collection", b.getCollection() != null ? b.getCollection() : "");
                m.put("imagePath", b.getImagePath() != null ? b.getImagePath() : "");
                list.add(m);
            }
            return mapper.writeValueAsString(list);
        } catch (Exception e) { return "[]"; }
    }

    public String getLoggedInUsername() { return loggedInUsername; }
    public int getUserElo() { return userElo; }
    public int getKnowledgePoints() { return knowledgePoints; }
    public int getUnlockedCount() { return unlockedCount; }
    public int getTotalPieces() { return PieceRegistry.getAll().size(); }
    public String getAllBotsJson() { return allBotsJson; }
    public List<MatchRecord> getRecentMatches() { return recentMatches; }
}
