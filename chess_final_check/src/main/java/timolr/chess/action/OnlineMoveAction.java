package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.UserDAO;
import timolr.chess.online.OnlineGameStore;

public class OnlineMoveAction extends JsonAction {

    private String gameId;
    private String from;
    private String to;
    private String promo;
    private String gameoverResult;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return json("{\"ok\":false}");
        }

        OnlineGameStore store = OnlineGameStore.getInstance();
        OnlineGameStore.GameState g = store.getGame(gameId);
        if (g == null || g.result != null) {
            return json("{\"ok\":false}");
        }

        String sessionId = session.getId();
        String color = g.colorOf(sessionId);
        String opponentColor = color.equals("w") ? "b" : "w";

        String promoJson = (promo == null || promo.isEmpty() || "null".equals(promo))
                ? "null" : "\"" + promo + "\"";
        String moveJson = "{\"from\":" + from + ",\"to\":" + to + ",\"promo\":" + promoJson + "}";
        store.submitMove(gameId, color, moveJson);

        if (gameoverResult != null && !gameoverResult.isEmpty()) {
            UserDAO userDAO = new UserDAO();
            store.finishGame(gameId, gameoverResult, userDAO);
            store.submitGameoverNotification(gameId, opponentColor);

            int newElo = color.equals("w") ? g.newWhiteElo : g.newBlackElo;
            int oldElo = color.equals("w") ? g.whiteElo : g.blackElo;
            session.setAttribute("elo", newElo);
            return json("{\"ok\":true,\"gameover\":true,\"newElo\":" + newElo
                    + ",\"eloChange\":" + (newElo - oldElo) + "}");
        }

        return json("{\"ok\":true}");
    }

    public void setGameId(String gameId) { this.gameId = gameId; }
    public void setFrom(String from) { this.from = from; }
    public void setTo(String to) { this.to = to; }
    public void setPromo(String promo) { this.promo = promo; }
    public void setGameoverResult(String gameoverResult) { this.gameoverResult = gameoverResult; }
}
