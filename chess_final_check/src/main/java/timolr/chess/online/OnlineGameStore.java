package timolr.chess.online;

import timolr.chess.account.UserDAO;

import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

public class OnlineGameStore {

    private static final OnlineGameStore INSTANCE = new OnlineGameStore();
    public static OnlineGameStore getInstance() { return INSTANCE; }
    private OnlineGameStore() {}

    private final ConcurrentHashMap<String, QueueEntry> queue = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, GameState> games = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, String> sessionToGame = new ConcurrentHashMap<>();

    public static class QueueEntry {
        public final String sessionId, username, whiteArmyJson, blackArmyJson;
        public final Long userId;
        public final int elo;
        public final long joinTime;

        public QueueEntry(String sessionId, String username, Long userId, int elo,
                          String whiteArmyJson, String blackArmyJson) {
            this.sessionId = sessionId;
            this.username = username;
            this.userId = userId;
            this.elo = elo;
            this.joinTime = System.currentTimeMillis();
            this.whiteArmyJson = whiteArmyJson;
            this.blackArmyJson = blackArmyJson;
        }
    }

    public static class GameState {
        public final String gameId;
        public final String whiteSessionId, blackSessionId;
        public final String whiteUsername, blackUsername;
        public final Long whiteUserId, blackUserId;
        public final int whiteElo, blackElo;
        public final String whiteArmyJson, blackArmyJson;
        public final ConcurrentLinkedQueue<String> pendingForWhite = new ConcurrentLinkedQueue<>();
        public final ConcurrentLinkedQueue<String> pendingForBlack = new ConcurrentLinkedQueue<>();
        public volatile boolean gameOver = false;
        public volatile String result = null;
        public volatile int newWhiteElo, newBlackElo;

        public GameState(String gameId, QueueEntry white, QueueEntry black) {
            this.gameId = gameId;
            this.whiteSessionId = white.sessionId;
            this.blackSessionId = black.sessionId;
            this.whiteUsername = white.username;
            this.blackUsername = black.username;
            this.whiteUserId = white.userId;
            this.blackUserId = black.userId;
            this.whiteElo = white.elo;
            this.blackElo = black.elo;
            this.whiteArmyJson = white.whiteArmyJson;
            this.blackArmyJson = black.blackArmyJson;
            this.newWhiteElo = white.elo;
            this.newBlackElo = black.elo;
        }

        public boolean isWhite(String sid) { return whiteSessionId.equals(sid); }
        public String colorOf(String sid) { return isWhite(sid) ? "w" : "b"; }
    }

    public synchronized GameState tryQueue(String sessionId, String username, Long userId, int elo,
                                            String whiteArmyJson, String blackArmyJson) {
        String existingId = sessionToGame.get(sessionId);
        if (existingId != null) return games.get(existingId);

        QueueEntry me = new QueueEntry(sessionId, username, userId, elo, whiteArmyJson, blackArmyJson);
        long now = System.currentTimeMillis();
        QueueEntry best = null;
        int bestDiff = Integer.MAX_VALUE;

        for (QueueEntry w : queue.values()) {
            if (w.sessionId.equals(sessionId)) continue;
            int diff = Math.abs(w.elo - elo);
            long waitedSec = (now - w.joinTime) / 1000;
            int maxDiff = (int) Math.min(200 + waitedSec * 15, 1500);
            if (diff <= maxDiff && diff < bestDiff) {
                best = w;
                bestDiff = diff;
            }
        }

        if (best != null) {
            queue.remove(best.sessionId);
            boolean meIsWhite = Math.random() < 0.5;
            QueueEntry white = meIsWhite ? me : best;
            QueueEntry black = meIsWhite ? best : me;
            String gameId = UUID.randomUUID().toString();
            GameState game = new GameState(gameId, white, black);
            games.put(gameId, game);
            sessionToGame.put(white.sessionId, gameId);
            sessionToGame.put(black.sessionId, gameId);
            return game;
        }

        queue.put(sessionId, me);
        return null;
    }

    public void cancelQueue(String sessionId) {
        queue.remove(sessionId);
    }

    public GameState getGameForSession(String sessionId) {
        String gid = sessionToGame.get(sessionId);
        return gid != null ? games.get(gid) : null;
    }

    public GameState getGame(String gameId) {
        return games.get(gameId);
    }

    public void submitMove(String gameId, String fromColor, String moveJson) {
        GameState g = games.get(gameId);
        if (g == null || g.result != null) return;
        (fromColor.equals("w") ? g.pendingForBlack : g.pendingForWhite).add(moveJson);
    }

    public String pollNext(String gameId, String myColor) {
        GameState g = games.get(gameId);
        if (g == null) return null;
        return (myColor.equals("w") ? g.pendingForWhite : g.pendingForBlack).poll();
    }

    public synchronized void finishGame(String gameId, String result, UserDAO userDAO) {
        GameState g = games.get(gameId);
        if (g == null || g.result != null) return;
        double expectedW = 1.0 / (1 + Math.pow(10, (g.blackElo - g.whiteElo) / 400.0));
        double actualW = result.equals("white") ? 1.0 : result.equals("black") ? 0.0 : 0.5;
        g.newWhiteElo = Math.max(100, g.whiteElo + (int) Math.round(32 * (actualW - expectedW)));
        g.newBlackElo = Math.max(100, g.blackElo + (int) Math.round(32 * ((1 - actualW) - (1 - expectedW))));
        g.result = result;
        g.gameOver = true;
        if (userDAO != null) {
            userDAO.updateElo(g.whiteUserId, g.newWhiteElo);
            userDAO.updateElo(g.blackUserId, g.newBlackElo);
        }
    }

    public void submitGameoverNotification(String gameId, String toColor) {
        GameState g = games.get(gameId);
        if (g == null || g.result == null) return;
        int newElo = toColor.equals("w") ? g.newWhiteElo : g.newBlackElo;
        int oldElo = toColor.equals("w") ? g.whiteElo : g.blackElo;
        String notif = "{\"type\":\"gameover\",\"result\":\"" + g.result
                + "\",\"newElo\":" + newElo + ",\"eloChange\":" + (newElo - oldElo) + "}";
        (toColor.equals("w") ? g.pendingForWhite : g.pendingForBlack).add(notif);
    }
}
