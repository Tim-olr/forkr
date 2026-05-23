package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;

public class OnlineGameAction extends ActionSupport {

    private String loggedInUsername;
    private int loggedInElo;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return "login";
        }
        loggedInUsername = (String) session.getAttribute("username");
        Object eloAttr = session.getAttribute("elo");
        loggedInElo = eloAttr instanceof Integer ? (Integer) eloAttr : 600;
        return SUCCESS;
    }

    public String getLoggedInUsername() { return loggedInUsername; }
    public int getLoggedInElo() { return loggedInElo; }
}
