package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.util.GoogleOAuthService;

import java.security.SecureRandom;
import java.util.Base64;

/**
 * Redirects the browser to Google's OAuth consent screen.
 * If Google OAuth is not configured, redirects back to login with an error.
 */
public class GoogleAuthAction extends ActionSupport {

    private String redirectUrl;

    @Override
    public String execute() {
        if (!GoogleOAuthService.isConfigured()) {
            return "notConfigured";
        }

        // Generate a random state token to prevent CSRF
        byte[] stateBytes = new byte[16];
        new SecureRandom().nextBytes(stateBytes);
        String state = Base64.getUrlEncoder().withoutPadding().encodeToString(stateBytes);

        // Store state in session for verification in callback
        HttpSession session = ServletActionContext.getRequest().getSession(true);
        session.setAttribute("oauthState", state);

        String redirectUri = buildRedirectUri();
        redirectUrl = GoogleOAuthService.buildAuthUrl(redirectUri, state);
        return SUCCESS;
    }

    private String buildRedirectUri() {
        String url = ServletActionContext.getRequest().getRequestURL().toString();
        // Replace /googleAuth with /googleCallback
        return url.replaceAll("/googleAuth.*", "") + "/googleCallback";
    }

    public String getRedirectUrl() { return redirectUrl; }
}
