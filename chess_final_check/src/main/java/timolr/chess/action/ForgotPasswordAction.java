package timolr.chess.action;

import jakarta.servlet.http.HttpServletRequest;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.util.EmailService;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;

public class ForgotPasswordAction extends ActionSupport {

    private String email;
    private String message;
    private boolean submitted;

    public String show() {
        return INPUT;
    }

    @Override
    public String execute() {
        submitted = true;
        message = "If that email address is registered, you'll receive a password reset link shortly.";

        if (email == null || email.isBlank()) return SUCCESS;

        UserDAO dao = new UserDAO();
        User user = dao.findByEmail(email.trim().toLowerCase());
        if (user == null) return SUCCESS;

        byte[] bytes = new byte[32];
        new SecureRandom().nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        LocalDateTime expiry = LocalDateTime.now().plusHours(24);

        dao.setResetToken(user.getId(), token, expiry);

        HttpServletRequest req = ServletActionContext.getRequest();
        String baseUrl = req.getRequestURL().toString().replaceAll("/forgotPasswordSubmit.*", "");
        EmailService.sendPasswordResetEmail(user.getEmail(), token, baseUrl);

        return SUCCESS;
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getMessage() { return message; }
    public boolean isSubmitted() { return submitted; }
}
