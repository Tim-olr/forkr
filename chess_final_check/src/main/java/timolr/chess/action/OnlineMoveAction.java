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

        // Deduct elapsed time from the moving player's clock
        long now = System.currentTimeMillis();
        long elapsed = now - g.timerLastTick;
        if (color.equals("w")) {
            g.whiteTimeMs = Math.max(0, g.whiteTimeMs - elapsed);
        } else {
            g.blackTimeMs = Math.max(0, g.blackTimeMs - elapsed);
        }
        g.timerLastTick = now;
        g.timerTurn = opponentColor;

        // Check if this player ran out of time
        boolean timedOut = (color.equals("w") && g.whiteTimeMs <= 0)
                        || (color.equals("b") && g.blackTimeMs <= 0);

        String promoJson = (promo == null || promo.isEmpty() || "null".equals(promo))
                ? "null" : "\"" + promo + "\"";
        String moveJson = "{\"from\":" + from + ",\"to\":" + to + ",\"promo\":" + promoJson + "}";
        store.submitMove(gameId, color, moveJson);

        String effectiveResult = timedOut ? opponentColor.equals("w") ? "white" : "black"
                : gameoverResult;

        if (effectiveResult != null && !effectiveResult.isEmpty()) {
            UserDAO userDAO = new UserDAO();
            store.finishGame(gameId, effectiveResult, userDAO);
            store.submitGameoverNotification(gameId, opponentColor);

            int newElo = color.equals("w") ? g.newWhiteElo : g.newBlackElo;
            int oldElo = color.equals("w") ? g.whiteElo : g.blackElo;
            session.setAttribute("elo", newElo);
            return json("{\"ok\":true,\"gameover\":true,\"newElo\":" + newElo
                    + ",\"eloChange\":" + (newElo - oldElo)
                    + ",\"wt\":" + g.whiteTimeMs + ",\"bt\":" + g.blackTimeMs + "}");
        }

        return json("{\"ok\":true,\"wt\":" + g.whiteTimeMs + ",\"bt\":" + g.blackTimeMs
                + ",\"tt\":\"" + g.timerTurn + "\"}");
    }

    public void setGameId(String gameId) { this.gameId = gameId; }
    public void setFrom(String from) { this.from = from; }
    public void setTo(String to) { this.to = to; }
    public void setPromo(String promo) { this.promo = promo; }
    public void setGameoverResult(String gameoverResult) { this.gameoverResult = gameoverResult; }
}
