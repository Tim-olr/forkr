package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;

public class SupportAction extends ActionSupport {

    private String loggedInUsername;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return "login";
        }
        loggedInUsername = (String) session.getAttribute("username");
        return SUCCESS;
    }

    public String getLoggedInUsername() { return loggedInUsername; }
}
