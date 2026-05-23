package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.game.pieces.PieceDefinition;
import timolr.chess.game.pieces.PieceRegistry;

import java.util.*;

public class AcademyAction extends ActionSupport {

    public static final Set<String> DEFAULT_UNLOCKED = Collections.unmodifiableSet(
            new LinkedHashSet<>(Arrays.asList("PAWN","KNIGHT","ROOK","BISHOP","QUEEN","KING"))
    );

    private int knowledgePoints;
    private String unlockedPiecesJson;
    private String loggedInUsername;
    private final List<PieceDefinition> pieceDefinitions = PieceRegistry.getAll();

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) return "login";
        Long userId = (Long) session.getAttribute("userId");
        loggedInUsername = (String) session.getAttribute("username");
        UserDAO dao = new UserDAO();
        User user = dao.findById(userId);
        if (user == null) return "login";
        knowledgePoints = user.getKnowledgePoints();
        unlockedPiecesJson = buildUnlockedJson(user.getUnlockedPieces());
        return SUCCESS;
    }

    static String buildUnlockedJson(String stored) {
        Set<String> unlocked = new LinkedHashSet<>(DEFAULT_UNLOCKED);
        if (stored != null && !stored.isBlank()) {
            for (String t : stored.split(",")) { String s = t.trim(); if (!s.isEmpty()) unlocked.add(s); }
        }
        StringBuilder sb = new StringBuilder("[");
        boolean first = true;
        for (String t : unlocked) { if (!first) sb.append(","); sb.append("\"").append(t).append("\""); first = false; }
        sb.append("]");
        return sb.toString();
    }

    public int getKnowledgePoints() { return knowledgePoints; }
    public String getUnlockedPiecesJson() { return unlockedPiecesJson; }
    public String getLoggedInUsername() { return loggedInUsername; }
    public List<PieceDefinition> getPieceDefinitions() { return pieceDefinitions; }
}
