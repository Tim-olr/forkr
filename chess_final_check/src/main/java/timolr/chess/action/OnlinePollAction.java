package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ServletActionContext;
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

        String item = store.pollNext(gameId, color);
        if (item != null) {
            if (item.contains("\"type\":\"gameover\"")) {
                return json(item);
            }
            return json("{\"type\":\"move\",\"move\":" + item + "}");
        }

        // Fallback: game ended but notification was already consumed or missed
        if (g.result != null) {
            boolean isWhite = "w".equals(color);
            int newElo = isWhite ? g.newWhiteElo : g.newBlackElo;
            int oldElo = isWhite ? g.whiteElo : g.blackElo;
            return json("{\"type\":\"gameover\",\"result\":\"" + g.result
                    + "\",\"newElo\":" + newElo + ",\"eloChange\":" + (newElo - oldElo) + "}");
        }

        return json("{\"type\":\"waiting\"}");
    }

    public void setGameId(String gameId) { this.gameId = gameId; }
    public void setColor(String color) { this.color = color; }
}
