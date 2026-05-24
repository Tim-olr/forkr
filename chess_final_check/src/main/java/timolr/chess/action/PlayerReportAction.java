package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ServletActionContext;
import timolr.chess.support.PlayerReport;
import timolr.chess.support.PlayerReportDAO;

public class PlayerReportAction extends JsonAction {

    private Long targetId;
    private String targetUsername;
    private String reason;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return json("{\"ok\":false,\"error\":\"not logged in\"}");
        }
        if (reason == null || reason.isBlank()) {
            return json("{\"ok\":false,\"error\":\"reason required\"}");
        }
        Long reporterId = (Long) session.getAttribute("userId");
        String reporterUsername = (String) session.getAttribute("username");

        PlayerReport report = new PlayerReport();
        report.setReporterId(reporterId);
        report.setReporterUsername(reporterUsername);
        report.setTargetId(targetId);
        report.setTargetUsername(targetUsername != null ? targetUsername : "unknown");
        report.setReason(reason.trim());
        new PlayerReportDAO().save(report);
        return json("{\"ok\":true}");
    }

    public Long getTargetId() { return targetId; }
    public void setTargetId(Long targetId) { this.targetId = targetId; }
    public String getTargetUsername() { return targetUsername; }
    public void setTargetUsername(String targetUsername) { this.targetUsername = targetUsername; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
}
