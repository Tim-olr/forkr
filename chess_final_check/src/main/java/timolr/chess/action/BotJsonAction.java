package timolr.chess.action;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ServletActionContext;
import timolr.chess.bot.BotDAO;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BotJsonAction extends JsonAction {

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            return json("[]");
        }
        try {
            BotDAO dao = new BotDAO();
            List<Object[]> bots = dao.findAllForPicker();
            List<Map<String, Object>> list = new ArrayList<>();
            for (Object[] row : bots) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", row[0]);
                m.put("name", row[1]);
                m.put("elo", row[2]);
                m.put("collection", row[3] != null ? row[3] : "");
                m.put("imagePath", row[4] != null ? row[4] : "");
                list.add(m);
            }
            return json(new ObjectMapper().writeValueAsString(list));
        } catch (Exception e) {
            return json("[]");
        }
    }
}
