package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.UserDAO;
import timolr.chess.online.OnlineGameStore;

public class OnlinePollAction extends JsonAction {

    private String gameId;
    private String color;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return json("{\"type\":\"error\"}");
        }
        if (gameId == null || color == null) {
            return json("{\"type\":\"error\",\"msg\":\"missing params\"}");
        }

        OnlineGameStore store = OnlineGameStore.getInstance();
        OnlineGameStore.GameState g = store.getGame(gameId);
        if (g == null) {
            return json("{\"type\":\"error\",\"msg\":\"game not found\"}");
        }

        // Compute current effective timer values (accounting for elapsed ticking time)
        long now = System.currentTimeMillis();
        long elapsed = now - g.timerLastTick;
        long wt = g.whiteTimeMs - ("w".equals(g.timerTurn) ? Math.max(0, elapsed) : 0);
        long bt = g.blackTimeMs - ("b".equals(g.timerTurn) ? Math.max(0, elapsed) : 0);
        wt = Math.max(0, wt);
        bt = Math.max(0, bt);
        String timerSuffix = ",\"wt\":" + wt + ",\"bt\":" + bt + ",\"tt\":\"" + g.timerTurn + "\"";

        // Detect server-side timeout
        if (g.result == null) {
            boolean whiteTimedOut = "w".equals(g.timerTurn) && wt <= 0;
            boolean blackTimedOut = "b".equals(g.timerTurn) && bt <= 0;
            if (whiteTimedOut || blackTimedOut) {
                String winner = whiteTimedOut ? "black" : "white";
                String otherColor = color.equals("w") ? "b" : "w";
                UserDAO userDAO = new UserDAO();
                store.finishGame(gameId, winner, userDAO);
                store.submitGameoverNotification(gameId, otherColor);
                boolean isWhitePoll = "w".equals(color);
                int newElo = isWhitePoll ? g.newWhiteElo : g.newBlackElo;
                int oldElo = isWhitePoll ? g.whiteElo : g.blackElo;
                return json("{\"type\":\"gameover\",\"result\":\"" + winner
                        + "\",\"newElo\":" + newElo + ",\"eloChange\":" + (newElo - oldElo) + "}");
            }
        }

        String item = store.pollNext(gameId, color);
        if (item != null) {
            if (item.contains("\"type\":\"gameover\"")) {
                return json(item);
            }
            return json("{\"type\":\"move\",\"move\":" + item + timerSuffix + "}");
        }

        // Fallback: game ended but notification was already consumed or missed
        if (g.result != null) {
            boolean isWhite = "w".equals(color);
            int newElo = isWhite ? g.newWhiteElo : g.newBlackElo;
            int oldElo = isWhite ? g.whiteElo : g.blackElo;
            return json("{\"type\":\"gameover\",\"result\":\"" + g.result
                    + "\",\"newElo\":" + newElo + ",\"eloChange\":" + (newElo - oldElo) + "}");
        }

        return json("{\"type\":\"waiting\"" + timerSuffix + "}");
    }

    public void setGameId(String gameId) { this.gameId = gameId; }
    public void setColor(String color) { this.color = color; }
}
