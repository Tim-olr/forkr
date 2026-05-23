package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.PasswordHasher;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;

public class LoginAction extends ActionSupport {

    private String username;
    private String password;

    @Override
    public String execute() {
        if (username == null || username.isBlank()) {
            return INPUT;
        }
        UserDAO dao = new UserDAO();
        User user = dao.findByUsername(username);
        if (user == null || !PasswordHasher.verify(password, user.getPasswordHash())) {
            addActionError("Invalid username or password.");
            return INPUT;
        }
        // Block login if email verification is pending (token still set + not verified)
        if (!user.isEmailVerified() && user.getVerificationToken() != null) {
            addActionError("Please verify your email address before logging in. Check your inbox for the verification link.");
            return INPUT;
        }
        if (user.isBanned()) {
            String reason = user.getBanReason();
            if (reason != null && !reason.isBlank()) {
                addActionError("This account has been banned. Reason: " + reason + " — Contact support if you believe this is a mistake.");
            } else {
                addActionError("This account has been banned. Contact support if you believe this is a mistake.");
            }
            return INPUT;
        }
        HttpSession session = ServletActionContext.getRequest().getSession();
        session.setAttribute("userId", user.getId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("isAdmin", user.isAdmin());
        session.setAttribute("elo", user.getElo());
        session.setAttribute("profilePicPath", user.getProfilePicPath());
        return SUCCESS;
    }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
