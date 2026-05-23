package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.army.Army;
import timolr.chess.army.ArmyDAO;

public class SetActiveArmyAction extends ActionSupport {

    private Long armyId;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return "login";
        }
        Long userId = (Long) session.getAttribute("userId");

        if (armyId == null) return SUCCESS;

        ArmyDAO dao = new ArmyDAO();
        Army army = dao.findById(armyId);
        if (army == null) return SUCCESS;

        boolean ownedByUser = army.getOwner() != null && army.getOwner().getId().equals(userId);
        if (!ownedByUser) return SUCCESS;

        dao.setActive(armyId, userId, army.getTeam());
        return SUCCESS;
    }

    public Long getArmyId() { return armyId; }
    public void setArmyId(Long armyId) { this.armyId = armyId; }
}
