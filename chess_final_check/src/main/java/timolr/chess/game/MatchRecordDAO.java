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

    public long countTodayByUserId(Long userId) {
        java.time.LocalDateTime start = java.time.LocalDate.now().atStartOfDay();
        java.time.LocalDateTime end = start.plusDays(1);
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Long count = session.createQuery(
                "SELECT COUNT(m) FROM MatchRecord m WHERE (m.whiteUserId = :uid OR m.blackUserId = :uid) " +
                "AND m.playedAt >= :start AND m.playedAt < :end", Long.class)
                .setParameter("uid", userId)
                .setParameter("start", start)
                .setParameter("end", end)
                .uniqueResult();
            return count != null ? count : 0L;
        }
    }

    public long countTodayWinsByUserId(Long userId) {
        java.time.LocalDateTime start = java.time.LocalDate.now().atStartOfDay();
        java.time.LocalDateTime end = start.plusDays(1);
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Long count = session.createQuery(
                "SELECT COUNT(m) FROM MatchRecord m WHERE " +
                "((m.whiteUserId = :uid AND m.result = '1-0') OR (m.blackUserId = :uid AND m.result = '0-1')) " +
                "AND m.playedAt >= :start AND m.playedAt < :end", Long.class)
                .setParameter("uid", userId)
                .setParameter("start", start)
                .setParameter("end", end)
                .uniqueResult();
            return count != null ? count : 0L;
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
