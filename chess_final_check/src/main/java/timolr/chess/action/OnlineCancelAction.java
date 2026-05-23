package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ServletActionContext;
import timolr.chess.online.OnlineGameStore;

public class OnlineCancelAction extends JsonAction {

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session != null) {
            OnlineGameStore.getInstance().cancelQueue(session.getId());
        }
        return json("{\"ok\":true}");
    }
}
