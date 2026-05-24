package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.PasswordHasher;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.army.Army;
import timolr.chess.army.ArmyDAO;

import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.regex.Pattern;

public class ProfileAction extends ActionSupport {

    // At least 8 chars, 1 uppercase, 1 digit, 1 special character
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
        "^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*()\\-_=+\\[\\]{};:'\",.<>/?\\\\|`~]).{8,}$");

    // Profile display
    private User profileUser;
    private List<Army> userArmies;

    // Change password
    private String oldPassword;
    private String newPassword;
    private String confirmNewPassword;
    private String profileMessage;

    // Delete account
    private String deletePassword;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) return "login";

        Long userId = (Long) session.getAttribute("userId");
        profileUser = new UserDAO().findById(userId);
        userArmies = new ArmyDAO().findByOwner(userId);
        return SUCCESS;
    }

    public String changePassword() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) return "login";

        Long userId = (Long) session.getAttribute("userId");
        UserDAO dao = new UserDAO();
        User user = dao.findById(userId);

        if (!PasswordHasher.verify(oldPassword, user.getPasswordHash())) {
            profileMessage = "Current password is incorrect.";
            profileUser = user;
            userArmies = new ArmyDAO().findByOwner(userId);
            return SUCCESS;
        }
        if (!newPassword.equals(confirmNewPassword)) {
            profileMessage = "New passwords do not match.";
            profileUser = user;
            userArmies = new ArmyDAO().findByOwner(userId);
            return SUCCESS;
        }
        if (newPassword.length() < 8) {
            profileMessage = "New password must be at least 8 characters.";
            profileUser = user;
            userArmies = new ArmyDAO().findByOwner(userId);
            return SUCCESS;
        }
        if (!PASSWORD_PATTERN.matcher(newPassword).matches()) {
            profileMessage = "Password must contain at least one uppercase letter, one number, and one special character.";
            profileUser = user;
            userArmies = new ArmyDAO().findByOwner(userId);
            return SUCCESS;
        }

        user.setPasswordHash(PasswordHasher.hash(newPassword));
        dao.update(user);
        profileMessage = "Password changed successfully!";
        profileUser = dao.findById(userId);
        userArmies = new ArmyDAO().findByOwner(userId);
        return SUCCESS;
    }

    public String uploadPic() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) return "login";

        Long userId = (Long) session.getAttribute("userId");

        try {
            // Read directly from the multipart request — works with jakarta-stream parser
            Part part = ServletActionContext.getRequest().getPart("profilePic");

            if (part == null || part.getSize() == 0) {
                profileMessage = "No file selected.";
            } else {
                String contentType = part.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    profileMessage = "Please upload an image file (JPG, PNG, etc.).";
                } else {
                    String submittedFileName = part.getSubmittedFileName();
                    String ext = (submittedFileName != null && submittedFileName.contains("."))
                        ? submittedFileName.substring(submittedFileName.lastIndexOf('.')).toLowerCase()
                        : ".jpg";

                    String uploadDir = ServletActionContext.getServletContext().getRealPath("/uploads/avatars/");
                    new File(uploadDir).mkdirs();

                    String fileName = userId + ext;
                    File dest = new File(uploadDir, fileName);

                    try (InputStream in = part.getInputStream()) {
                        Files.copy(in, dest.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    }

                    String picPath = "uploads/avatars/" + fileName;
                    new UserDAO().setProfilePic(userId, picPath);
                    session.setAttribute("profilePicPath", picPath);
                    profileMessage = "Profile picture updated!";
                }
            }
        } catch (Exception e) {
            profileMessage = "Upload error: " + e.getMessage();
        }

        UserDAO dao = new UserDAO();
        profileUser = dao.findById(userId);
        userArmies = new ArmyDAO().findByOwner(userId);
        return SUCCESS;
    }

    public String deleteAccount() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) return "login";

        Long userId = (Long) session.getAttribute("userId");
        UserDAO dao = new UserDAO();
        User user = dao.findById(userId);
        if (user == null) return "login";

        if (deletePassword == null || deletePassword.isBlank()
                || !PasswordHasher.verify(deletePassword, user.getPasswordHash())) {
            profileMessage = "Incorrect password. Your account was not deleted.";
            profileUser = user;
            userArmies = new ArmyDAO().findByOwner(userId);
            return SUCCESS;
        }

        new ArmyDAO().deleteAllByOwner(userId);
        dao.deleteUser(userId);
        session.invalidate();
        return "login";
    }

    public User getProfileUser() { return profileUser; }
    public List<Army> getUserArmies() { return userArmies; }
    public String getProfileMessage() { return profileMessage; }

    public String getOldPassword() { return oldPassword; }
    public void setOldPassword(String oldPassword) { this.oldPassword = oldPassword; }
    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
    public String getConfirmNewPassword() { return confirmNewPassword; }
    public void setConfirmNewPassword(String confirmNewPassword) { this.confirmNewPassword = confirmNewPassword; }
    public String getDeletePassword() { return deletePassword; }
    public void setDeletePassword(String deletePassword) { this.deletePassword = deletePassword; }
}
