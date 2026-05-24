package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.game.MatchRecordDAO;

public class AdminFlagMatchAction extends ActionSupport {
    private Long matchId;
    private boolean flagged;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) return "forbidden";
        if (matchId != null) new MatchRecordDAO().setFlagged(matchId, flagged);
        return "redirect";
    }

    public Long getMatchId() { return matchId; }
    public void setMatchId(Long matchId) { this.matchId = matchId; }
    public boolean isFlagged() { return flagged; }
    public void setFlagged(boolean flagged) { this.flagged = flagged; }
}
