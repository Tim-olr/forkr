package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.PasswordHasher;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.util.GoogleOAuthService;
import timolr.chess.util.GoogleOAuthService.GoogleUser;

import java.security.SecureRandom;
import java.util.Base64;

/**
 * Handles Google's OAuth callback (/googleCallback?code=...&state=...).
 * Finds or creates the user, then logs them in.
 */
public class GoogleCallbackAction extends ActionSupport {

    private String code;
    private String state;
    private String error;
    private String callbackMessage;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);

        // User denied access
        if (error != null && !error.isBlank()) {
            callbackMessage = "Google sign-in was cancelled.";
            return "failure";
        }

        // Validate state (CSRF protection)
        String savedState = session != null ? (String) session.getAttribute("oauthState") : null;
        if (savedState == null || !savedState.equals(state)) {
            callbackMessage = "Invalid OAuth state. Please try again.";
            return "failure";
        }
        if (session != null) session.removeAttribute("oauthState");

        if (code == null || code.isBlank()) {
            callbackMessage = "No authorization code received from Google.";
            return "failure";
        }

        // Build redirect URI (must exactly match what was sent to Google)
        String redirectUri = ServletActionContext.getRequest().getRequestURL()
                .toString().replaceAll("\\?.*", "");

        // Exchange code for user info
        GoogleUser googleUser = GoogleOAuthService.getUserFromCode(code, redirectUri);
        if (googleUser == null) {
            callbackMessage = "Could not retrieve your Google account info. Please try again.";
            return "failure";
        }

        UserDAO dao = new UserDAO();

        // 1. Try to find existing account by Google ID
        User user = dao.findByGoogleId(googleUser.googleId());

        // 2. If not found, try to find by email (link Google to existing account)
        if (user == null) {
            user = dao.findByEmail(googleUser.email().toLowerCase());
            if (user != null) {
                // Link Google ID to the existing account
                user.setGoogleId(googleUser.googleId());
                if (!user.isEmailVerified()) {
                    user.setEmailVerified(true);
                    user.setVerificationToken(null);
                    user.setVerificationExpiry(null);
                }
                dao.update(user);
            }
        }

        // 3. If still not found, create a new account
        if (user == null) {
            user = new User();
            // Derive username from the name/email, ensure uniqueness
            String baseUsername = deriveUsername(googleUser.name(), googleUser.email(), dao);
            user.setUsername(baseUsername);
            user.setEmail(googleUser.email().toLowerCase());
            // Random password hash (user can set a password later via profile)
            byte[] randPw = new byte[24];
            new SecureRandom().nextBytes(randPw);
            user.setPasswordHash(PasswordHasher.hash(Base64.getEncoder().encodeToString(randPw)));
            user.setGoogleId(googleUser.googleId());
            user.setEmailVerified(true);
            dao.save(user);
            // Reload to get generated ID and createdAt
            user = dao.findByEmail(googleUser.email().toLowerCase());
        }

        // Log in
        HttpSession newSession = ServletActionContext.getRequest().getSession(true);
        newSession.setAttribute("userId", user.getId());
        newSession.setAttribute("username", user.getUsername());
        newSession.setAttribute("isAdmin", user.isAdmin());
        newSession.setAttribute("userRole", user.getRole() != null ? user.getRole().name() : "USER");
        newSession.setAttribute("elo", user.getElo());
        newSession.setAttribute("profilePicPath", user.getProfilePicPath());

        return SUCCESS;
    }

    /** Derives a unique username from the Google display name or email. */
    private String deriveUsername(String name, String email, UserDAO dao) {
        // Try the first part of the display name (letters/numbers only)
        String base = (name != null ? name : email.split("@")[0])
                .replaceAll("[^a-zA-Z0-9_]", "")
                .toLowerCase();
        if (base.isBlank()) base = "user";
        if (base.length() > 30) base = base.substring(0, 30);

        if (!dao.usernameExists(base)) return base;

        // Append numbers until unique
        for (int i = 2; i <= 999; i++) {
            String candidate = base + i;
            if (!dao.usernameExists(candidate)) return candidate;
        }
        // Fallback: random suffix
        return base + new SecureRandom().nextInt(100000);
    }

    public String getCode()  { return code; }
    public void setCode(String code) { this.code = code; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getError() { return error; }
    public void setError(String error) { this.error = error; }

    public String getCallbackMessage() { return callbackMessage; }
}
