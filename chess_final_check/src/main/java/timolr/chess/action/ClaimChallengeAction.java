package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.army.ArmyDAO;
import timolr.chess.game.MatchRecordDAO;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class ClaimChallengeAction extends ActionSupport {

    private static final int REWARD_PLAY3     = 50;
    private static final int REWARD_WIN1      = 75;
    private static final int REWARD_BUILD_ARMY = 30;

    private String challengeId;
    private InputStream jsonStream;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return json("{\"ok\":false,\"error\":\"not logged in\"}");
        }
        Long userId = (Long) session.getAttribute("userId");

        if (challengeId == null || challengeId.isBlank()) {
            return json("{\"ok\":false,\"error\":\"missing challenge id\"}");
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.findById(userId);
        if (user == null) return json("{\"ok\":false,\"error\":\"user not found\"}");

        // Reset flags if it's a new day
        LocalDate today = LocalDate.now();
        String flags = user.getChallengeFlags() != null ? user.getChallengeFlags() : "";
        if (user.getChallengeDate() == null || !user.getChallengeDate().equals(today)) {
            flags = "";
        }
        Set<String> flagSet = new HashSet<>(Arrays.asList(flags.split(",")));

        if (flagSet.contains(challengeId)) {
            return json("{\"ok\":false,\"error\":\"already claimed\"}");
        }

        // Verify the challenge is actually complete
        boolean eligible = false;
        int reward = 0;
        MatchRecordDAO mrDAO = new MatchRecordDAO();

        switch (challengeId) {
            case "play3":
                eligible = mrDAO.countTodayByUserId(userId) >= 3;
                reward = REWARD_PLAY3;
                break;
            case "win1":
                eligible = mrDAO.countTodayWinsByUserId(userId) >= 1;
                reward = REWARD_WIN1;
                break;
            case "build_army":
                eligible = !new ArmyDAO().findByOwner(userId).isEmpty();
                reward = REWARD_BUILD_ARMY;
                break;
            default:
                return json("{\"ok\":false,\"error\":\"unknown challenge\"}");
        }

        if (!eligible) {
            return json("{\"ok\":false,\"error\":\"challenge not complete\"}");
        }

        // Award KP and record the claim
        flagSet.add(challengeId);
        flagSet.remove(""); // remove empty string from initial split
        String newFlags = String.join(",", flagSet);
        int newKp = user.getKnowledgePoints() + reward;
        user.setKnowledgePoints(newKp);
        user.setChallengeDate(today);
        user.setChallengeFlags(newFlags);
        userDAO.update(user);

        return json("{\"ok\":true,\"earned\":" + reward + ",\"kp\":" + newKp + "}");
    }

    private String json(String s) {
        jsonStream = new ByteArrayInputStream(s.getBytes(StandardCharsets.UTF_8));
        return SUCCESS;
    }

    public String getChallengeId() { return challengeId; }
    public void setChallengeId(String challengeId) { this.challengeId = challengeId; }
    public InputStream getJsonStream() { return jsonStream; }
}
