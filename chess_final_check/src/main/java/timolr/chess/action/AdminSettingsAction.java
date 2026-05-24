package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.support.PlatformSettingDAO;

public class AdminSettingsAction extends ActionSupport {

    private String settingKey;
    private String settingValue;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        if (settingKey != null && !settingKey.isBlank() && settingValue != null) {
            new PlatformSettingDAO().set(settingKey.trim(), settingValue.trim());
        }
        return "redirect";
    }

    public String getSettingKey() { return settingKey; }
    public void setSettingKey(String settingKey) { this.settingKey = settingKey; }
    public String getSettingValue() { return settingValue; }
    public void setSettingValue(String settingValue) { this.settingValue = settingValue; }
}
