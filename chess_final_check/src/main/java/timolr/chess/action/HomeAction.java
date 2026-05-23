package timolr.chess.action;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.bot.Bot;
import timolr.chess.bot.BotDAO;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class HomeAction extends ActionSupport {

    private String loggedInUsername;
    private String allBotsJson = "[]";

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            return "login";
        }
        loggedInUsername = (String) session.getAttribute("username");
        allBotsJson = serializeBots(new BotDAO().findAll());
        return SUCCESS;
    }

    public String logout() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session != null) {
            session.invalidate();
        }
        return "login";
    }

    private String serializeBots(List<Bot> bots) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            List<Map<String, Object>> list = new ArrayList<>();
            for (Bot b : bots) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", b.getId());
                m.put("name", b.getName());
                m.put("elo", b.getElo());
                m.put("collection", b.getCollection() != null ? b.getCollection() : "");
                m.put("imagePath", b.getImagePath() != null ? b.getImagePath() : "");
                list.add(m);
            }
            return mapper.writeValueAsString(list);
        } catch (Exception e) {
            return "[]";
        }
    }

    public String getLoggedInUsername() { return loggedInUsername; }
    public String getAllBotsJson() { return allBotsJson; }
}
