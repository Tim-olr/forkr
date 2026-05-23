package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

public class AwardKPAction extends ActionSupport {

    private static final int BOT_WIN_KP    = 3;
    private static final int ONLINE_WIN_KP = 8;

    private String reason;
    private InputStream jsonStream;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return sendJson("{\"ok\":false}");
        }
        Long userId = (Long) session.getAttribute("userId");

        int kp;
        if ("bot_win".equals(reason))    kp = BOT_WIN_KP;
        else if ("online_win".equals(reason)) kp = ONLINE_WIN_KP;
        else return sendJson("{\"ok\":false,\"error\":\"unknown reason\"}");

        UserDAO dao = new UserDAO();
        User user = dao.findById(userId);
        if (user == null) return sendJson("{\"ok\":false}");

        user.setKnowledgePoints(user.getKnowledgePoints() + kp);
        dao.update(user);
        return sendJson("{\"ok\":true,\"kp\":" + user.getKnowledgePoints() + ",\"earned\":" + kp + "}");
    }

    private String sendJson(String json) {
        jsonStream = new ByteArrayInputStream(json.getBytes(StandardCharsets.UTF_8));
        return SUCCESS;
    }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public InputStream getJsonStream() { return jsonStream; }
}
