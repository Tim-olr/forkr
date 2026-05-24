package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.UserDAO;
import timolr.chess.online.OnlineGameStore;

public class OnlineFinishAction extends JsonAction {

    private String gameId;
    private String result;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return json("{\"ok\":false}");
        }

        OnlineGameStore store = OnlineGameStore.getInstance();
        OnlineGameStore.GameState g = store.getGame(gameId);
        if (g == null) {
            return json("{\"ok\":false}");
        }

        String sessionId = session.getId();
        String color = g.colorOf(sessionId);
        String opponentColor = color.equals("w") ? "b" : "w";

        UserDAO userDAO = new UserDAO();
        store.finishGame(gameId, result, userDAO);

        try {
            timolr.chess.game.MatchRecord record = new timolr.chess.game.MatchRecord();
            record.setWhiteUserId(g.whiteUserId);
            record.setWhiteUsername(g.whiteUsername);
            record.setBlackUserId(g.blackUserId);
            record.setBlackUsername(g.blackUsername);
            record.setVariant("Standard");
            if ("white".equals(result)) record.setResult("1-0");
            else if ("black".equals(result)) record.setResult("0-1");
            else record.setResult("1/2-1/2");
            new timolr.chess.game.MatchRecordDAO().save(record);
        } catch (Exception ignored) {}

        store.submitGameoverNotification(gameId, opponentColor);

        int newElo = color.equals("w") ? g.newWhiteElo : g.newBlackElo;
        int oldElo = color.equals("w") ? g.whiteElo : g.blackElo;
        session.setAttribute("elo", newElo);

        return json("{\"ok\":true,\"newElo\":" + newElo + ",\"eloChange\":" + (newElo - oldElo) + "}");
    }

    public void setGameId(String gameId) { this.gameId = gameId; }
    public void setResult(String result) { this.result = result; }
}
