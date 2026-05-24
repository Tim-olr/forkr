package timolr.chess.action;

import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.PasswordHasher;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.util.EmailService;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.regex.Pattern;

public class RegisterAction extends ActionSupport {

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$");

    // At least 8 chars, 1 uppercase, 1 digit, 1 special character
    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
        "^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*()\\-_=+\\[\\]{};:'\",.<>/?\\\\|`~]).{8,}$");

    private String username;
    private String email;
    private String password;
    private String confirmPassword;
    private String registerMessage;
    private boolean agreeTerms;
    private boolean ageConfirm;

    @Override
    public String execute() {
        if (!agreeTerms) {
            addActionError("You must agree to the Terms of Service and Privacy Policy.");
            return INPUT;
        }
        if (!ageConfirm) {
            addActionError("You must confirm that you are 13 years of age or older.");
            return INPUT;
        }
        if (username == null || username.isBlank()) {
            addActionError("Username is required.");
            return INPUT;
        }
        if (email == null || email.isBlank()) {
            addActionError("Email is required.");
            return INPUT;
        }
        if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
            addActionError("Please enter a valid email address.");
            return INPUT;
        }
        if (password == null || password.length() < 8) {
            addActionError("Password must be at least 8 characters.");
            return INPUT;
        }
        if (!PASSWORD_PATTERN.matcher(password).matches()) {
            addActionError("Password must contain at least one uppercase letter, one number, and one special character (e.g. !@#$%).");
            return INPUT;
        }
        if (!password.equals(confirmPassword)) {
            addActionError("Passwords do not match.");
            return INPUT;
        }

        UserDAO dao = new UserDAO();
        if (dao.usernameExists(username.trim())) {
            addActionError("Username already taken.");
            return INPUT;
        }
        if (dao.emailExists(email.trim())) {
            addActionError("Email already registered.");
            return INPUT;
        }

        User user = new User();
        user.setUsername(username.trim());
        user.setEmail(email.trim().toLowerCase());
        user.setPasswordHash(PasswordHasher.hash(password));

        if (EmailService.isConfigured()) {
            // Generate 32-byte URL-safe token
            byte[] bytes = new byte[32];
            new SecureRandom().nextBytes(bytes);
            String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            user.setVerificationToken(token);
            user.setVerificationExpiry(LocalDateTime.now().plusHours(24));
            user.setEmailVerified(false);

            dao.save(user);

            // Build base URL from request
            String baseUrl = ServletActionContext.getRequest().getRequestURL()
                .toString().replaceAll("/register.*", "");
            EmailService.sendVerificationEmail(user.getEmail(), token, baseUrl);

            registerMessage = "verify";
        } else {
            // No SMTP configured — skip verification, allow immediate login
            user.setEmailVerified(true);
            dao.save(user);
            registerMessage = "done";
        }

        return SUCCESS;
    }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }

    public String getRegisterMessage() { return registerMessage; }
    public boolean isAgreeTerms() { return agreeTerms; }
    public void setAgreeTerms(boolean agreeTerms) { this.agreeTerms = agreeTerms; }
    public boolean isAgeConfirm() { return ageConfirm; }
    public void setAgeConfirm(boolean ageConfirm) { this.ageConfirm = ageConfirm; }
}
