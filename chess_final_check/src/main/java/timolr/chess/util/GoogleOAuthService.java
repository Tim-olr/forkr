package timolr.chess.util;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

/**
 * Google OAuth 2.0 helper.
 * Configure via system properties (e.g. in Tomcat's setenv.sh):
 *   -Dgoogle.oauth.client.id=your_client_id
 *   -Dgoogle.oauth.client.secret=your_client_secret
 *
 * In Google Cloud Console:
 *   1. Create OAuth 2.0 credentials (Web Application type)
 *   2. Add your redirect URI: http://localhost:8080/chess_final_check/googleCallback
 *   3. Enable "Google+ API" or "Google Identity" API
 */
public class GoogleOAuthService {

    private static final String CLIENT_ID     = System.getProperty("google.oauth.client.id", "");
    private static final String CLIENT_SECRET = System.getProperty("google.oauth.client.secret", "");

    private static final String AUTH_URL     = "https://accounts.google.com/o/oauth2/v2/auth";
    private static final String TOKEN_URL    = "https://oauth2.googleapis.com/token";
    private static final String USERINFO_URL = "https://www.googleapis.com/oauth2/v2/userinfo";

    private static final HttpClient HTTP = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    private static final ObjectMapper MAPPER = new ObjectMapper();

    public static boolean isConfigured() {
        return CLIENT_ID != null && !CLIENT_ID.isBlank();
    }

    /** Build the Google sign-in URL the user is redirected to. */
    public static String buildAuthUrl(String redirectUri, String state) {
        return AUTH_URL
                + "?client_id=" + enc(CLIENT_ID)
                + "&redirect_uri=" + enc(redirectUri)
                + "&response_type=code"
                + "&scope=" + enc("openid email profile")
                + "&access_type=offline"
                + "&state=" + enc(state);
    }

    /** Exchange the authorization code for user info. Returns null on failure. */
    public static GoogleUser getUserFromCode(String code, String redirectUri) {
        try {
            // 1. Exchange code for access token
            String formBody = "code=" + enc(code)
                    + "&client_id=" + enc(CLIENT_ID)
                    + "&client_secret=" + enc(CLIENT_SECRET)
                    + "&redirect_uri=" + enc(redirectUri)
                    + "&grant_type=authorization_code";

            HttpRequest tokenReq = HttpRequest.newBuilder()
                    .uri(URI.create(TOKEN_URL))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(formBody))
                    .build();

            HttpResponse<String> tokenResp = HTTP.send(tokenReq, HttpResponse.BodyHandlers.ofString());
            JsonNode tokenJson = MAPPER.readTree(tokenResp.body());

            String accessToken = tokenJson.path("access_token").asText(null);
            if (accessToken == null || accessToken.isBlank()) {
                System.err.println("[GoogleOAuth] Token exchange failed: " + tokenResp.body());
                return null;
            }

            // 2. Get user info
            HttpRequest infoReq = HttpRequest.newBuilder()
                    .uri(URI.create(USERINFO_URL))
                    .header("Authorization", "Bearer " + accessToken)
                    .GET()
                    .build();

            HttpResponse<String> infoResp = HTTP.send(infoReq, HttpResponse.BodyHandlers.ofString());
            JsonNode info = MAPPER.readTree(infoResp.body());

            String googleId = info.path("id").asText(null);
            String email    = info.path("email").asText(null);
            String name     = info.path("name").asText(null);

            if (googleId == null || email == null) {
                System.err.println("[GoogleOAuth] Missing user info fields: " + infoResp.body());
                return null;
            }

            return new GoogleUser(googleId, email, name);

        } catch (IOException | InterruptedException e) {
            System.err.println("[GoogleOAuth] Error: " + e.getMessage());
            return null;
        }
    }

    private static String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }

    /** Simple DTO for Google user info. */
    public record GoogleUser(String googleId, String email, String name) {}
}
