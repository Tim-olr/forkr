package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.BanLog;
import timolr.chess.account.BanLogDAO;

import java.util.List;

public class AdminBanLogsAction extends ActionSupport {

    private List<BanLog> banLogs;
    private String loggedInUsername;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        loggedInUsername = (String) session.getAttribute("username");
        banLogs = new BanLogDAO().findAll();
        return SUCCESS;
    }

    public List<BanLog> getBanLogs() { return banLogs; }
    public String getLoggedInUsername() { return loggedInUsername; }
}
