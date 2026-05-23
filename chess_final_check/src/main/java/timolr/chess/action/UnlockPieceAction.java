package timolr.chess.action;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.game.pieces.PieceDefinition;
import timolr.chess.game.pieces.PieceRegistry;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class UnlockPieceAction extends ActionSupport {

    private String pieceType;
    private InputStream jsonStream;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return sendJson("{\"ok\":false,\"error\":\"Not logged in\"}");
        }
        Long userId = (Long) session.getAttribute("userId");

        // Validate piece type exists and is unlockable
        PieceDefinition pd = PieceRegistry.getAll().stream()
                .filter(p -> p.getType().equals(pieceType))
                .findFirst().orElse(null);
        if (pd == null) return sendJson("{\"ok\":false,\"error\":\"Unknown piece\"}");
        if (AcademyAction.DEFAULT_UNLOCKED.contains(pieceType)) {
            return sendJson("{\"ok\":false,\"error\":\"Already default\"}");
        }

        // Find cost from tree definition (we keep it server-side too)
        int cost = getNodeCost(pieceType);
        if (cost <= 0) return sendJson("{\"ok\":false,\"error\":\"Not purchasable\"}");

        UserDAO dao = new UserDAO();
        User user = dao.findById(userId);
        if (user == null) return sendJson("{\"ok\":false,\"error\":\"User not found\"}");

        // Check already unlocked
        Set<String> unlocked = parseUnlocked(user.getUnlockedPieces());
        if (unlocked.contains(pieceType)) {
            return sendJson("{\"ok\":false,\"error\":\"Already unlocked\"}");
        }

        // Check prerequisites
        List<String> reqs = getRequirements(pieceType);
        for (String req : reqs) {
            if (!AcademyAction.DEFAULT_UNLOCKED.contains(req) && !unlocked.contains(req)) {
                return sendJson("{\"ok\":false,\"error\":\"Prerequisites not met\"}");
            }
        }

        // Check knowledge points
        if (user.getKnowledgePoints() < cost) {
            return sendJson("{\"ok\":false,\"error\":\"Not enough knowledge points\"}");
        }

        // Deduct and save
        user.setKnowledgePoints(user.getKnowledgePoints() - cost);
        unlocked.add(pieceType);
        user.setUnlockedPieces(String.join(",", unlocked));
        dao.update(user);

        return sendJson("{\"ok\":true,\"kp\":" + user.getKnowledgePoints() + "}");
    }

    private String sendJson(String json) {
        jsonStream = new ByteArrayInputStream(json.getBytes(StandardCharsets.UTF_8));
        return SUCCESS;
    }

    private Set<String> parseUnlocked(String stored) {
        Set<String> s = new LinkedHashSet<>(AcademyAction.DEFAULT_UNLOCKED);
        if (stored != null && !stored.isBlank()) {
            for (String t : stored.split(",")) { String v = t.trim(); if (!v.isEmpty()) s.add(v); }
        }
        return s;
    }

    // Keep costs in sync with the JS ACADEMY_TREE definition
    private static int getNodeCost(String type) {
        switch (type) {
            case "EVIL_PAWN": return 5;
            case "JESTER": return 8;
            case "LANCER": return 8;
            case "ECLIPSE": return 8;
            case "DUKE": return 15;
            case "BEAST_HANDLER": return 18;
            case "BIRD": return 15;
            case "SHIELD": return 12;
            case "PRINCE": return 12;
            case "CHOIR": return 20;
            case "EAGLE": return 20;
            case "COIL": return 22;
            case "BOOT": return 25;
            case "FEATHER": return 18;
            case "WIZARD": return 25;
            case "HERBALIST": return 18;
            case "PRINCESS": return 25;
            case "LANTERN": return 22;
            case "ORACLE": return 35;
            case "WARDEN": return 20;
            case "HUSK": return 30;
            case "HYDRA": return 35;
            case "LIBRARY": return 40;
            case "FORK": return 50;
            default: return 0;
        }
    }

    private static List<String> getRequirements(String type) {
        switch (type) {
            case "DUKE": return Collections.singletonList("JESTER");
            case "BEAST_HANDLER": return Collections.singletonList("JESTER");
            case "BIRD": return Collections.singletonList("LANCER");
            case "SHIELD": return Collections.singletonList("LANCER");
            case "PRINCE": return Collections.singletonList("ECLIPSE");
            case "CHOIR": return Collections.singletonList("ECLIPSE");
            case "EAGLE": return Collections.singletonList("DUKE");
            case "COIL": return Collections.singletonList("BEAST_HANDLER");
            case "BOOT": return Collections.singletonList("BIRD");
            case "FEATHER": return Collections.singletonList("BIRD");
            case "WIZARD": return Collections.singletonList("SHIELD");
            case "HERBALIST": return Collections.singletonList("PRINCE");
            case "PRINCESS": return Collections.singletonList("PRINCE");
            case "LANTERN": return Collections.singletonList("FEATHER");
            case "ORACLE": return Collections.singletonList("HERBALIST");
            case "WARDEN": return Collections.singletonList("PRINCESS");
            case "HUSK": return Collections.singletonList("BOOT");
            case "HYDRA": return Collections.singletonList("HUSK");
            case "LIBRARY": return Collections.singletonList("HYDRA");
            case "FORK": return Arrays.asList("LIBRARY", "ORACLE");
            default: return Collections.emptyList();
        }
    }

    public String getPieceType() { return pieceType; }
    public void setPieceType(String pieceType) { this.pieceType = pieceType; }
    public InputStream getJsonStream() { return jsonStream; }
}
