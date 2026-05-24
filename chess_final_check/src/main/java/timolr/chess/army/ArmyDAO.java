package timolr.chess.army;

import org.hibernate.Session;
import timolr.chess.util.HibernateUtil;

import java.util.List;

public class ArmyDAO {

    public void save(Army army) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            session.persist(army);
            session.getTransaction().commit();
        }
    }

    public void update(Army army) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            session.merge(army);
            session.getTransaction().commit();
        }
    }

    public Army findById(Long id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.find(Army.class, id);
        }
    }

    public List<Army> findByOwner(Long userId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                    "FROM Army a WHERE a.owner.id = :userId ORDER BY a.team, a.createdAt DESC", Army.class)
                    .setParameter("userId", userId)
                    .list();
        }
    }

    public List<Army> findByOwnerAndTeam(Long userId, String team) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                    "FROM Army a WHERE a.owner.id = :userId AND a.team = :team ORDER BY a.createdAt DESC", Army.class)
                    .setParameter("userId", userId)
                    .setParameter("team", team)
                    .list();
        }
    }

    public List<Army> findPresets() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                    "SELECT DISTINCT a FROM Army a LEFT JOIN FETCH a.pieces WHERE a.preset = true ORDER BY a.team, a.name", Army.class)
                    .list();
        }
    }

    public List<Army> findAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                    "SELECT a FROM Army a LEFT JOIN FETCH a.owner",
                    Army.class
            ).getResultList();
        }
    }

    public void delete(Long id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            Army army = session.find(Army.class, id);
            if (army != null) {
                session.remove(army);
            }
            session.getTransaction().commit();
        }
    }

    public long countByOwnerAndTeam(Long userId, String team) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Long count = session.createQuery(
                    "SELECT COUNT(a) FROM Army a WHERE a.owner.id = :userId AND a.team = :team", Long.class)
                    .setParameter("userId", userId)
                    .setParameter("team", team)
                    .uniqueResult();
            return count != null ? count : 0L;
        }
    }

    public void setActive(Long armyId, Long userId, String team) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            session.createMutationQuery(
                    "UPDATE Army SET active = false WHERE owner.id = :userId AND team = :team")
                    .setParameter("userId", userId)
                    .setParameter("team", team)
                    .executeUpdate();
            Army army = session.find(Army.class, armyId);
            if (army != null && army.getOwner() != null && army.getOwner().getId().equals(userId)) {
                army.setActive(true);
                session.merge(army);
            }
            session.getTransaction().commit();
        }
    }

    public Army findActiveByOwnerAndTeam(Long userId, String team) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            List<Army> results = session.createQuery(
                    "SELECT DISTINCT a FROM Army a LEFT JOIN FETCH a.pieces " +
                    "WHERE a.owner.id = :userId AND a.team = :team AND a.active = true", Army.class)
                    .setParameter("userId", userId)
                    .setParameter("team", team)
                    .list();
            return results.isEmpty() ? null : results.get(0);
        }
    }

    public Army findFirstPresetByTeam(String team) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            List<Army> results = session.createQuery(
                    "FROM Army a WHERE a.preset = true AND a.team = :team ORDER BY a.active DESC, a.createdAt DESC", Army.class)
                    .setParameter("team", team)
                    .setMaxResults(1)
                    .list();
            return results.isEmpty() ? null : results.get(0);
        }
    }

    public void deleteAllByOwner(Long userId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            List<Army> armies = session.createQuery(
                    "FROM Army WHERE owner.id = :uid", Army.class)
                    .setParameter("uid", userId)
                    .list();
            for (Army army : armies) {
                session.remove(army);
            }
            session.getTransaction().commit();
        }
    }

    public void setPreset(Long id, boolean preset) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            Army army = session.find(Army.class, id);
            if (army != null) {
                army.setPreset(preset);
                session.merge(army);
            }
            session.getTransaction().commit();
        }
    }
}
