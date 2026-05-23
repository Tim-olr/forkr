package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.army.Army;
import timolr.chess.army.ArmyDAO;
import timolr.chess.game.pieces.PieceDefinition;
import timolr.chess.game.pieces.PieceRegistry;

import java.util.List;

public class ArmyBuilderAction extends ActionSupport {

    private List<Army> userArmies;
    private List<Army> presetArmies;
    private Army loadedArmy;
    private Long loadId;
    private final List<PieceDefinition> pieceDefinitions = PieceRegistry.getAll();
    private String userUnlockedPiecesJson;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return "login";
        }
        Long userId = (Long) session.getAttribute("userId");
        ArmyDAO dao = new ArmyDAO();
        userArmies = dao.findByOwner(userId);
        presetArmies = dao.findPresets();

        User user = new UserDAO().findById(userId);
        userUnlockedPiecesJson = AcademyAction.buildUnlockedJson(user != null ? user.getUnlockedPieces() : null);

        if (loadId != null) {
            Army candidate = dao.findById(loadId);
            if (candidate != null) {
                boolean ownedByUser = candidate.getOwner() != null
                        && candidate.getOwner().getId().equals(userId);
                if (candidate.isPreset() || ownedByUser) {
                    loadedArmy = candidate;
                }
            }
        }
        return SUCCESS;
    }

    public List<Army> getUserArmies() { return userArmies; }
    public List<Army> getPresetArmies() { return presetArmies; }
    public Army getLoadedArmy() { return loadedArmy; }
    public Long getLoadId() { return loadId; }
    public void setLoadId(Long loadId) { this.loadId = loadId; }
    public List<PieceDefinition> getPieceDefinitions() { return pieceDefinitions; }
    public String getUserUnlockedPiecesJson() { return userUnlockedPiecesJson; }
}
