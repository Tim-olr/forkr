package timolr.chess.support;

import org.hibernate.Session;
import timolr.chess.util.HibernateUtil;

import java.util.List;

public class PlayerReportDAO {

    public void save(PlayerReport report) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            session.persist(report);
            session.getTransaction().commit();
        }
    }

    public List<PlayerReport> findAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM PlayerReport ORDER BY createdAt DESC", PlayerReport.class).list();
        }
    }

    public List<PlayerReport> findByState(String state) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                "FROM PlayerReport WHERE state = :s ORDER BY createdAt DESC", PlayerReport.class)
                .setParameter("s", state).list();
        }
    }

    public long countByState(String state) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("SELECT COUNT(*) FROM PlayerReport WHERE state = :s", Long.class)
                .setParameter("s", state).uniqueResult();
        }
    }

    public void updateState(Long id, String state) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            PlayerReport r = session.get(PlayerReport.class, id);
            if (r != null) { r.setState(state); session.merge(r); }
            session.getTransaction().commit();
        }
    }
}
