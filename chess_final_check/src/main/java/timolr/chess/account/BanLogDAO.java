package timolr.chess.account;

import org.hibernate.Session;
import timolr.chess.util.HibernateUtil;

import java.util.List;

public class BanLogDAO {

    public void save(BanLog log) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            session.persist(log);
            session.getTransaction().commit();
        }
    }

    public List<BanLog> findAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                "FROM BanLog ORDER BY createdAt DESC", BanLog.class).list();
        }
    }

    public List<BanLog> findByUserId(Long userId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                "FROM BanLog WHERE targetUserId = :uid ORDER BY createdAt DESC", BanLog.class)
                .setParameter("uid", userId)
                .list();
        }
    }
}
