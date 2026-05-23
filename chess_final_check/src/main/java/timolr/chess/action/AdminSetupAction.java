package timolr.chess.action;

import org.apache.struts2.ActionSupport;
import timolr.chess.account.PasswordHasher;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;

public class AdminSetupAction extends ActionSupport {

    private String username;
    private String email;
    private String password;
    private String confirmPassword;

    @Override
    public String execute() {
        UserDAO dao = new UserDAO();
        if (dao.anyAdminExists()) {
            return "redirect";
        }
        if (username == null || username.isBlank()) {
            return INPUT;
        }
        if (!password.equals(confirmPassword)) {
            addActionError("Passwords do not match.");
            return INPUT;
        }
        if (dao.usernameExists(username)) {
            addActionError("Username already taken.");
            return INPUT;
        }
        if (dao.emailExists(email)) {
            addActionError("Email already registered.");
            return INPUT;
        }
        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPasswordHash(PasswordHasher.hash(password));
        user.setAdmin(true);
        dao.save(user);
        return SUCCESS;
    }

    public String show() {
        UserDAO dao = new UserDAO();
        if (dao.anyAdminExists()) {
            return "redirect";
        }
        return INPUT;
    }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
}
