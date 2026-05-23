package timolr.chess.action;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.army.Army;
import timolr.chess.army.ArmyDAO;
import timolr.chess.army.ArmyPiece;
import timolr.chess.bot.Bot;
import timolr.chess.bot.BotDAO;
import timolr.chess.game.pieces.PieceDefinition;
import timolr.chess.game.pieces.PieceRegistry;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class GameAction extends ActionSupport {

    private String loggedInUsername;
    private String playerWhiteArmyJson = "null";
    private String playerBlackArmyJson = "null";
    private String presetWhiteArmyJson = "null";
    private String presetBlackArmyJson = "null";
    private String botDataJson = "null";
    private String allBotsJson = "[]";
    private final List<PieceDefinition> pieceDefinitions = PieceRegistry.getAll();

    // Optional query params
    private Long botId;
    private boolean localPlay;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            return "login";
        }
        loggedInUsername = (String) session.getAttribute("username");
        Long userId = (Long) session.getAttribute("userId");

        ArmyDAO dao = new ArmyDAO();
        ObjectMapper mapper = new ObjectMapper();

        playerWhiteArmyJson = serializeArmy(dao.findActiveByOwnerAndTeam(userId, "WHITE"), mapper);
        playerBlackArmyJson = serializeArmy(dao.findActiveByOwnerAndTeam(userId, "BLACK"), mapper);
        presetWhiteArmyJson = serializeArmy(dao.findFirstPresetByTeam("WHITE"), mapper);
        presetBlackArmyJson = serializeArmy(dao.findFirstPresetByTeam("BLACK"), mapper);

        BotDAO botDao = new BotDAO();

        if (botId != null) {
            Bot bot = botDao.findById(botId);
            if (bot != null) botDataJson = serializeBot(bot, mapper);
        }

        allBotsJson = serializeAllBots(botDao.findAllForPicker(), mapper);
        return SUCCESS;
    }

    private String serializeArmy(Army army, ObjectMapper mapper) {
        if (army == null || army.getPieces() == null || army.getPieces().isEmpty()) return "null";
        try {
            List<Map<String, Object>> pieces = army.getPieces().stream().map(p -> {
                Map<String, Object> m = new HashMap<>();
                m.put("pieceType", p.getPieceType());
                m.put("col", p.getBoardCol());
                m.put("rank", p.getBoardRank());
                return m;
            }).collect(Collectors.toList());
            return mapper.writeValueAsString(pieces);
        } catch (Exception e) {
            return "null";
        }
    }

    private String serializeBot(Bot bot, ObjectMapper mapper) {
        try {
            Map<String, Object> m = new HashMap<>();
            m.put("id", bot.getId());
            m.put("name", bot.getName());
            m.put("elo", bot.getElo());
            m.put("imagePath", bot.getImagePath() != null ? bot.getImagePath() : "");
            m.put("voicelines", bot.getVoicelines());
            m.put("g0CaptureLines", bot.getG0CaptureLines());
            m.put("g1CaptureLines", bot.getG1CaptureLines());
            m.put("g2CaptureLines", bot.getG2CaptureLines());
            m.put("g0TakeLines", bot.getG0TakeLines());
            m.put("g1TakeLines", bot.getG1TakeLines());
            m.put("g2TakeLines", bot.getG2TakeLines());
            m.put("winLines", bot.getWinLines());
            m.put("loseLines", bot.getLoseLines());
            return mapper.writeValueAsString(m);
        } catch (Exception e) {
            return "null";
        }
    }

    private String serializeAllBots(List<Object[]> bots, ObjectMapper mapper) {
        try {
            List<Map<String, Object>> list = new ArrayList<>();
            for (Object[] row : bots) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", row[0]);
                m.put("name", row[1]);
                m.put("elo", row[2]);
                m.put("collection", row[3] != null ? row[3] : "");
                m.put("imagePath", row[4] != null ? row[4] : "");
                list.add(m);
            }
            return mapper.writeValueAsString(list);
        } catch (Exception e) {
            return "[]";
        }
    }

    public String getLoggedInUsername() { return loggedInUsername; }
    public String getPlayerWhiteArmyJson() { return playerWhiteArmyJson; }
    public String getPlayerBlackArmyJson() { return playerBlackArmyJson; }
    public String getPresetWhiteArmyJson() { return presetWhiteArmyJson; }
    public String getPresetBlackArmyJson() { return presetBlackArmyJson; }
    public String getBotDataJson() { return botDataJson; }
    public String getAllBotsJson() { return allBotsJson; }
    public List<PieceDefinition> getPieceDefinitions() { return pieceDefinitions; }

    public Long getBotId() { return botId; }
    public void setBotId(Long botId) { this.botId = botId; }

    public boolean isLocalPlay() { return localPlay; }
    public void setLocalPlay(boolean localPlay) { this.localPlay = localPlay; }
}
