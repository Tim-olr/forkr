package timolr.chess.game;

import org.hibernate.Session;
import timolr.chess.util.HibernateUtil;

import java.util.List;

public class MatchRecordDAO {

    public void save(MatchRecord record) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            session.persist(record);
            session.getTransaction().commit();
        }
    }

    public List<MatchRecord> findAll(int limit) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                "FROM MatchRecord ORDER BY playedAt DESC", MatchRecord.class)
                .setMaxResults(limit).list();
        }
    }

    public List<MatchRecord> findByUserId(Long userId, int limit) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                "FROM MatchRecord WHERE whiteUserId = :uid OR blackUserId = :uid ORDER BY playedAt DESC",
                MatchRecord.class)
                .setParameter("uid", userId)
                .setMaxResults(limit).list();
        }
    }

    public List<MatchRecord> findFlagged(int limit) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                "FROM MatchRecord WHERE flagged = true ORDER BY playedAt DESC", MatchRecord.class)
                .setMaxResults(limit).list();
        }
    }

    public long countAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("SELECT COUNT(*) FROM MatchRecord", Long.class)
                .uniqueResult();
        }
    }

    public void setFlagged(Long id, boolean flagged) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            MatchRecord r = session.get(MatchRecord.class, id);
            if (r != null) { r.setFlagged(flagged); session.merge(r); }
            session.getTransaction().commit();
        }
    }
}
