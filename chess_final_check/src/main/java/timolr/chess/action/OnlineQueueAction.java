package timolr.chess.action;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ServletActionContext;
import timolr.chess.army.Army;
import timolr.chess.army.ArmyDAO;
import timolr.chess.army.ArmyPiece;
import timolr.chess.online.OnlineGameStore;

import java.util.*;

public class OnlineQueueAction extends JsonAction {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    @Override
    public String execute() throws Exception {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return json("{\"error\":\"not logged in\"}");
        }

        String sessionId = session.getId();
        String username = (String) session.getAttribute("username");
        Long userId = (Long) session.getAttribute("userId");
        Object eloAttr = session.getAttribute("elo");
        int elo = eloAttr instanceof Integer ? (Integer) eloAttr : 600;

        OnlineGameStore store = OnlineGameStore.getInstance();

        OnlineGameStore.GameState existing = store.getGameForSession(sessionId);
        if (existing != null) {
            if (!existing.gameOver) {
                return buildMatchedResponse(existing, sessionId);
            }
            // Game is already finished — clear stale mapping so player can search again
            store.clearSession(sessionId);
        }

        ArmyDAO dao = new ArmyDAO();
        String whiteArmyJson = serializeArmy(dao.findActiveByOwnerAndTeam(userId, "WHITE"));
        if ("null".equals(whiteArmyJson)) whiteArmyJson = serializeArmy(dao.findFirstPresetByTeam("WHITE"));
        String blackArmyJson = serializeArmy(dao.findActiveByOwnerAndTeam(userId, "BLACK"));
        if ("null".equals(blackArmyJson)) blackArmyJson = serializeArmy(dao.findFirstPresetByTeam("BLACK"));

        OnlineGameStore.GameState game = store.tryQueue(sessionId, username, userId, elo, whiteArmyJson, blackArmyJson);
        if (game != null) {
            return buildMatchedResponse(game, sessionId);
        }
        return json("{\"status\":\"waiting\"}");
    }

    private String buildMatchedResponse(OnlineGameStore.GameState g, String sessionId) throws Exception {
        String color = g.isWhite(sessionId) ? "w" : "b";
        String oppName = g.isWhite(sessionId) ? g.blackUsername : g.whiteUsername;
        int oppElo = g.isWhite(sessionId) ? g.blackElo : g.whiteElo;
        int myElo = g.isWhite(sessionId) ? g.whiteElo : g.blackElo;

        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("status", "matched");
        resp.put("gameId", g.gameId);
        resp.put("color", color);
        resp.put("opponentUsername", oppName);
        resp.put("opponentElo", oppElo);
        resp.put("myElo", myElo);
        resp.put("whiteArmy", MAPPER.readValue(g.whiteArmyJson, Object.class));
        resp.put("blackArmy", MAPPER.readValue(g.blackArmyJson, Object.class));
        return json(MAPPER.writeValueAsString(resp));
    }

    private String serializeArmy(Army army) throws Exception {
        if (army == null || army.getPieces() == null || army.getPieces().isEmpty()) return "null";
        List<Map<String, Object>> pieces = new ArrayList<>();
        for (ArmyPiece p : army.getPieces()) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("pieceType", p.getPieceType());
            m.put("col", p.getBoardCol());
            m.put("rank", p.getBoardRank());
            pieces.add(m);
        }
        return MAPPER.writeValueAsString(pieces);
    }
}
