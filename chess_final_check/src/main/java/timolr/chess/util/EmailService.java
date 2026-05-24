package timolr.chess.util;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

/**
 * Sends emails via SMTP. Configure via system properties (e.g., in Tomcat's setenv.sh):
 *   -Dmail.smtp.host=smtp.gmail.com
 *   -Dmail.smtp.port=587
 *   -Dmail.smtp.user=your@gmail.com
 *   -Dmail.smtp.pass=yourAppPassword
 * If mail.smtp.user is empty, email sending is silently skipped.
 */
public class EmailService {

    private static final String HOST = System.getProperty("mail.smtp.host", "smtp.gmail.com");
    private static final String PORT = System.getProperty("mail.smtp.port", "587");
    private static final String USER = System.getProperty("mail.smtp.user", "");
    private static final String PASS = System.getProperty("mail.smtp.pass", "");

    public static boolean isConfigured() {
        return USER != null && !USER.isBlank();
    }

    public static void sendVerificationEmail(String toEmail, String token, String baseUrl) {
        if (!isConfigured()) return;
        try {
            Properties props = buildProps();

            Session session = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USER, PASS);
                }
            });

            String link = baseUrl + "/verifyEmail?token=" + token;
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(USER, "Forkr Chess"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("Verify your Forkr account");
            msg.setText(
                "Welcome to Forkr!\n\n" +
                "Please verify your email address by clicking the link below:\n\n" +
                link + "\n\n" +
                "This link expires in 24 hours.\n\n" +
                "If you did not create an account, you can safely ignore this email."
            );
            Transport.send(msg);
        } catch (Exception e) {
            System.err.println("[EmailService] Failed to send verification email: " + e.getMessage());
        }
    }

    public static void sendBanEmail(String toEmail, String username, String reason) {
        if (!isConfigured()) return;
        try {
            Properties props = buildProps();
            Session session = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USER, PASS);
                }
            });
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(USER, "Forkr Chess"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("Your Forkr account has been banned");
            msg.setText(
                "Hello " + username + ",\n\n" +
                "Your Forkr account has been banned.\n\n" +
                "Reason: " + (reason != null && !reason.isBlank() ? reason : "No reason provided.") + "\n\n" +
                "If you believe this is a mistake, please contact support.\n\n" +
                "— The Forkr Team"
            );
            Transport.send(msg);
        } catch (Exception e) {
            System.err.println("[EmailService] Failed to send ban email: " + e.getMessage());
        }
    }

    public static void sendUnbanEmail(String toEmail, String username, String reason) {
        if (!isConfigured()) return;
        try {
            Properties props = buildProps();
            Session session = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USER, PASS);
                }
            });
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(USER, "Forkr Chess"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("Your Forkr account has been unbanned");
            msg.setText(
                "Hello " + username + ",\n\n" +
                "Your Forkr account has been unbanned and you may log in again.\n\n" +
                "Note from admin: " + (reason != null && !reason.isBlank() ? reason : "No note provided.") + "\n\n" +
                "— The Forkr Team"
            );
            Transport.send(msg);
        } catch (Exception e) {
            System.err.println("[EmailService] Failed to send unban email: " + e.getMessage());
        }
    }

    public static void sendPolicyUpdateEmail(String toEmail, String username, String policyType, String policyLink) {
        if (!isConfigured()) return;
        try {
            Properties props = buildProps();
            Session session = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USER, PASS);
                }
            });
            String policyName = "terms".equals(policyType) ? "Terms of Service" : "Privacy Policy";
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(USER, "Forkr Chess"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("Forkr " + policyName + " Updated");
            msg.setText(
                "Hello " + username + ",\n\n" +
                "We've updated our " + policyName + ".\n\n" +
                "Please review the updated policy at the link below:\n\n" +
                policyLink + "\n\n" +
                "By continuing to use Forkr, you agree to the updated " + policyName + ".\n\n" +
                "If you have any questions, please contact our support team.\n\n" +
                "— The Forkr Team"
            );
            Transport.send(msg);
        } catch (Exception e) {
            System.err.println("[EmailService] Failed to send policy update email to " + toEmail + ": " + e.getMessage());
        }
    }

    private static Properties buildProps() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", HOST);
        props.put("mail.smtp.port", PORT);
        props.put("mail.smtp.ssl.trust", HOST);
        return props;
    }

    public static boolean sendPasswordResetEmail(String toEmail, String token, String baseUrl) {
        if (!isConfigured()) return false;
        try {
            Properties props = buildProps();

            Session session = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USER, PASS);
                }
            });

            String link = baseUrl + "/resetPassword?token=" + token;
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(USER, "Forkr Chess"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("Reset your Forkr password");
            msg.setText(
                "A password reset was requested for your Forkr account.\n\n" +
                "Click the link below to set a new password:\n\n" +
                link + "\n\n" +
                "This link expires in 24 hours.\n\n" +
                "If you did not request a password reset, you can safely ignore this email."
            );
            Transport.send(msg);
            return true;
        } catch (Exception e) {
            System.err.println("[EmailService] Failed to send password reset email: " + e.getMessage());
            return false;
        }
    }
}
