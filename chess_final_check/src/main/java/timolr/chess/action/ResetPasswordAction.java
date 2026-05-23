package timolr.chess.action;

import org.apache.struts2.ActionSupport;
import timolr.chess.account.PasswordHasher;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;

import java.time.LocalDateTime;

public class ResetPasswordAction extends ActionSupport {

    private String token;
    private String newPassword;
    private String confirmPassword;
    private String message;
    private boolean resetSuccess;

    public String show() {
        if (token == null || token.isBlank()) return "redirect";
        User user = new UserDAO().findByResetToken(token);
        if (user == null || user.getResetExpiry() == null || user.getResetExpiry().isBefore(LocalDateTime.now())) {
            message = "This password reset link is invalid or has expired.";
        }
        return INPUT;
    }

    @Override
    public String execute() {
        if (token == null || token.isBlank()) return "redirect";

        UserDAO dao = new UserDAO();
        User user = dao.findByResetToken(token);

        if (user == null || user.getResetExpiry() == null || user.getResetExpiry().isBefore(LocalDateTime.now())) {
            message = "This password reset link is invalid or has expired.";
            return INPUT;
        }
        if (newPassword == null || newPassword.length() < 8) {
            message = "Password must be at least 8 characters.";
            return INPUT;
        }
        if (!newPassword.equals(confirmPassword)) {
            message = "Passwords do not match.";
            return INPUT;
        }

        user.setPasswordHash(PasswordHasher.hash(newPassword));
        user.setResetToken(null);
        user.setResetExpiry(null);
        dao.update(user);

        message = "Your password has been reset. You can now log in.";
        resetSuccess = true;
        return SUCCESS;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }

    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }

    public String getMessage() { return message; }
    public boolean isResetSuccess() { return resetSuccess; }
}
