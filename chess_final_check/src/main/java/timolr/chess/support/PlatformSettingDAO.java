package timolr.chess.support;

import org.hibernate.Session;
import timolr.chess.util.HibernateUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PlatformSettingDAO {

    private static final Map<String, String> DEFAULTS = new HashMap<>();
    static {
        DEFAULTS.put("matchmaking",     "true");
        DEFAULTS.put("tournaments",     "true");
        DEFAULTS.put("custom_pieces_ranked", "true");
        DEFAULTS.put("guest_play",      "false");
        DEFAULTS.put("default_variant", "Standard");
        DEFAULTS.put("default_time",    "10+0");
        DEFAULTS.put("piece_review_sla","48");
    }

    public List<PlatformSetting> findAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            List<PlatformSetting> stored = session.createQuery("FROM PlatformSetting", PlatformSetting.class).list();
            // Seed missing defaults
            Map<String, PlatformSetting> map = new HashMap<>();
            for (PlatformSetting s : stored) map.put(s.getKey(), s);
            for (Map.Entry<String, String> e : DEFAULTS.entrySet()) {
                if (!map.containsKey(e.getKey())) {
                    PlatformSetting def = new PlatformSetting(e.getKey(), e.getValue(), null);
                    session.beginTransaction();
                    session.persist(def);
                    session.getTransaction().commit();
                    map.put(e.getKey(), def);
                }
            }
            return session.createQuery("FROM PlatformSetting ORDER BY key", PlatformSetting.class).list();
        }
    }

    public String getValue(String key) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            PlatformSetting s = session.get(PlatformSetting.class, key);
            return s != null ? s.getValue() : DEFAULTS.getOrDefault(key, "");
        }
    }

    public boolean isEnabled(String key) {
        return "true".equalsIgnoreCase(getValue(key));
    }

    public void set(String key, String value) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            PlatformSetting s = session.get(PlatformSetting.class, key);
            if (s == null) {
                s = new PlatformSetting(key, value, null);
                session.persist(s);
            } else {
                s.setValue(value);
                session.merge(s);
            }
            session.getTransaction().commit();
        }
    }
}
