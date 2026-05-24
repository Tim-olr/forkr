package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.support.PlayerReportDAO;

public class AdminReportAction extends ActionSupport {

    private Long reportId;
    private String state;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        if (reportId != null && state != null) {
            new PlayerReportDAO().updateState(reportId, state);
        }
        return "redirect";
    }

    public Long getReportId() { return reportId; }
    public void setReportId(Long reportId) { this.reportId = reportId; }
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
}
