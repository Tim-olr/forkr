package timolr.chess.util;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

public class HibernateUtil {

    private static final SessionFactory SESSION_FACTORY;

    static {
        try {
            Configuration cfg = new Configuration().configure("hibernate/hibernate.cfg.xml");
            // Allow environment variables to override hardcoded dev credentials at runtime.
            // Set DB_URL, DB_USER, DB_PASS in the server environment for production.
            String dbUrl  = System.getenv("DB_URL");
            String dbUser = System.getenv("DB_USER");
            String dbPass = System.getenv("DB_PASS");
            if (dbUrl  != null && !dbUrl.isBlank())  cfg.setProperty("hibernate.connection.url",      dbUrl);
            if (dbUser != null && !dbUser.isBlank()) cfg.setProperty("hibernate.connection.username", dbUser);
            if (dbPass != null)                      cfg.setProperty("hibernate.connection.password", dbPass);
            SESSION_FACTORY = cfg.buildSessionFactory();
        } catch (Exception e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static SessionFactory getSessionFactory() {
        return SESSION_FACTORY;
    }

    public static void shutdown() {
        SESSION_FACTORY.close();
    }
}
