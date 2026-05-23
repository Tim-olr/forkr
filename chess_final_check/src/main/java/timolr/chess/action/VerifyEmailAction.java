package timolr.chess.action;

import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;

import java.time.LocalDateTime;

public class VerifyEmailAction extends ActionSupport {

    private String token;
    private String message;
    private boolean success;

    @Override
    public String execute() {
        if (token == null || token.isBlank()) {
            message = "Invalid verification link.";
            success = false;
            return SUCCESS;
        }

        UserDAO dao = new UserDAO();
        User user = dao.findByVerificationToken(token);

        if (user == null) {
            message = "Verification link not found or already used.";
            success = false;
            return SUCCESS;
        }

        if (user.getVerificationExpiry() != null && user.getVerificationExpiry().isBefore(LocalDateTime.now())) {
            message = "This verification link has expired. Please register again.";
            success = false;
            return SUCCESS;
        }

        dao.markEmailVerified(user.getId());
        message = "Email verified! You can now log in.";
        success = true;
        return SUCCESS;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public String getMessage() { return message; }
    public boolean isSuccess() { return success; }
}
