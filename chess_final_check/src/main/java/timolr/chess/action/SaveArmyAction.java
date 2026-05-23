package timolr.chess.action;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.army.Army;
import timolr.chess.army.ArmyDAO;
import timolr.chess.army.ArmyPiece;
import timolr.chess.game.pieces.PieceDefinition;
import timolr.chess.game.pieces.PieceRegistry;

import java.util.List;

public class SaveArmyAction extends ActionSupport {

    private String name;
    private String team;
    private boolean preset;
    private Long armyId;
    private String piecesJson;
    private Long savedArmyId;

    // Populated on INPUT so army-builder.jsp has data to render
    private List<Army> userArmies;
    private List<Army> presetArmies;
    private Army loadedArmy;
    private final List<PieceDefinition> pieceDefinitions = PieceRegistry.getAll();

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return "login";
        }
        Long userId = (Long) session.getAttribute("userId");
        boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin"));

        ArmyDAO armyDAO = new ArmyDAO();

        if (name == null || name.isBlank()) {
            addActionError("Army name is required.");
            populateViewData(armyDAO, userId);
            return INPUT;
        }
        if (!"WHITE".equals(team) && !"BLACK".equals(team)) {
            addActionError("Invalid team selection.");
            populateViewData(armyDAO, userId);
            return INPUT;
        }
        Army army;
        boolean isPreset = isAdmin && preset;

        if (armyId == null && !isPreset) {
            long existing = armyDAO.countByOwnerAndTeam(userId, team);
            if (existing >= 5) {
                addActionError("You can have a maximum of 5 armies per team. Delete one before saving a new one.");
                populateViewData(armyDAO, userId);
                return INPUT;
            }
        }

        if (armyId != null) {
            army = armyDAO.findById(armyId);
            if (army == null) {
                addActionError("Army not found.");
                populateViewData(armyDAO, userId);
                return INPUT;
            }
            boolean ownedByUser = army.getOwner() != null && army.getOwner().getId().equals(userId);
            if (!isAdmin && !ownedByUser) {
                addActionError("Not authorized to edit this army.");
                populateViewData(armyDAO, userId);
                return INPUT;
            }
            army.getPieces().clear();
            if (isPreset && army.getOwner() != null) {
                army.setOwner(null);
            }
        } else {
            army = new Army();
            if (!isPreset) {
                UserDAO userDAO = new UserDAO();
                User owner = userDAO.findById(userId);
                army.setOwner(owner);
            }
        }

        army.setName(name.trim());
        army.setTeam(team);
        if (isAdmin) {
            army.setPreset(preset);
        }

        if (piecesJson != null && !piecesJson.isBlank()) {
            try {
                ObjectMapper mapper = new ObjectMapper();
                JsonNode arr = mapper.readTree(piecesJson);
                for (JsonNode node : arr) {
                    ArmyPiece piece = new ArmyPiece();
                    piece.setArmy(army);
                    piece.setPieceType(node.get("pieceType").asText().toUpperCase());
                    piece.setBoardCol(node.get("col").asText().toUpperCase());
                    piece.setBoardRank(node.get("rank").asInt());
                    army.getPieces().add(piece);
                }
            } catch (Exception e) {
                addActionError("Invalid pieces data.");
                populateViewData(armyDAO, userId);
                return INPUT;
            }
        }

        if (armyId != null) {
            armyDAO.update(army);
            savedArmyId = army.getId();
        } else {
            armyDAO.save(army);
            savedArmyId = army.getId();
            // Auto-activate the newly created army so it is used in the next game
            if (!isPreset) {
                armyDAO.setActive(savedArmyId, userId, team);
            }
        }
        return SUCCESS;
    }

    private void populateViewData(ArmyDAO armyDAO, Long userId) {
        userArmies = armyDAO.findByOwner(userId);
        presetArmies = armyDAO.findPresets();
        if (armyId != null) {
            loadedArmy = armyDAO.findById(armyId);
        }
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getTeam() { return team; }
    public void setTeam(String team) { this.team = team; }

    public boolean isPreset() { return preset; }
    public void setPreset(boolean preset) { this.preset = preset; }

    public Long getArmyId() { return armyId; }
    public void setArmyId(Long armyId) { this.armyId = armyId; }

    public String getPiecesJson() { return piecesJson; }
    public void setPiecesJson(String piecesJson) { this.piecesJson = piecesJson; }

    public Long getSavedArmyId() { return savedArmyId; }

    public List<Army> getUserArmies() { return userArmies; }
    public List<Army> getPresetArmies() { return presetArmies; }
    public Army getLoadedArmy() { return loadedArmy; }
    public List<PieceDefinition> getPieceDefinitions() { return pieceDefinitions; }
}
