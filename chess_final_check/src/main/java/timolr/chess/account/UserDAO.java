package timolr.chess.account;

import org.hibernate.Session;
import timolr.chess.util.HibernateUtil;

public class UserDAO {

    public User findById(Long id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(User.class, id);
        }
    }

    public void save(User user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            session.persist(user);
            session.getTransaction().commit();
        }
    }

    public User findByUsername(String username) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM User WHERE username = :username", User.class)
                    .setParameter("username", username)
                    .uniqueResult();
        }
    }

    public User findByEmail(String email) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM User WHERE email = :email", User.class)
                    .setParameter("email", email)
                    .uniqueResult();
        }
    }

    public boolean usernameExists(String username) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Long count = session.createQuery(
                            "SELECT COUNT(u) FROM User u WHERE u.username = :username", Long.class)
                    .setParameter("username", username)
                    .uniqueResult();
            return count != null && count > 0;
        }
    }

    public boolean emailExists(String email) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Long count = session.createQuery(
                            "SELECT COUNT(u) FROM User u WHERE u.email = :email", Long.class)
                    .setParameter("email", email)
                    .uniqueResult();
            return count != null && count > 0;
        }
    }

    public boolean anyAdminExists() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Long count = session.createQuery(
                            "SELECT COUNT(u) FROM User u WHERE u.admin = true", Long.class)
                    .uniqueResult();
            return count != null && count > 0;
        }
    }

    public boolean anyOwnerExists() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Long count = session.createQuery(
                            "SELECT COUNT(u) FROM User u WHERE u.role = :role", Long.class)
                    .setParameter("role", UserRole.OWNER)
                    .uniqueResult();
            return count != null && count > 0;
        }
    }

    public void setRole(Long id, UserRole role) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                user.setRole(role);
                session.merge(user);
            }
            session.getTransaction().commit();
        }
    }

    public java.util.List<User> findAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM User ORDER BY username", User.class).list();
        }
    }

    public void setAdmin(Long id, boolean admin) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                user.setAdmin(admin);
                session.merge(user);
            }
            session.getTransaction().commit();
        }
    }

    public void updateElo(Long id, int newElo) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                user.setElo(Math.max(100, newElo));
                session.merge(user);
            }
            session.getTransaction().commit();
        }
    }

    public User findByVerificationToken(String token) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                "FROM User WHERE verificationToken = :token", User.class)
                .setParameter("token", token)
                .uniqueResult();
        }
    }

    public void markEmailVerified(Long id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                user.setEmailVerified(true);
                user.setVerificationToken(null);
                user.setVerificationExpiry(null);
                session.merge(user);
            }
            session.getTransaction().commit();
        }
    }

    public void setProfilePic(Long id, String path) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                user.setProfilePicPath(path);
                session.merge(user);
            }
            session.getTransaction().commit();
        }
    }

    public void update(User user) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            session.merge(user);
            session.getTransaction().commit();
        }
    }

    public void setBanned(Long id, boolean banned) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                user.setBanned(banned);
                session.merge(user);
            }
            session.getTransaction().commit();
        }
    }

    public void setBannedWithReason(Long id, boolean banned, String reason) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                user.setBanned(banned);
                user.setBanReason(banned ? reason : null);
                session.merge(user);
            }
            session.getTransaction().commit();
        }
    }

    public void setResetToken(Long id, String token, java.time.LocalDateTime expiry) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                user.setResetToken(token);
                user.setResetExpiry(expiry);
                session.merge(user);
            }
            session.getTransaction().commit();
        }
    }

    public void clearResetToken(Long id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                user.setResetToken(null);
                user.setResetExpiry(null);
                session.merge(user);
            }
            session.getTransaction().commit();
        }
    }

    public User findByResetToken(String token) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                "FROM User WHERE resetToken = :token", User.class)
                .setParameter("token", token)
                .uniqueResult();
        }
    }

    public void updateAccount(Long id, String username, String email, String passwordHash) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                if (username != null && !username.isBlank()) user.setUsername(username);
                if (email != null && !email.isBlank()) user.setEmail(email);
                if (passwordHash != null) user.setPasswordHash(passwordHash);
                session.merge(user);
            }
            session.getTransaction().commit();
        }
    }

    public void updateAcademy(Long id, int kpDelta, String unlockedPieces) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                int newKp = Math.max(0, user.getKnowledgePoints() + kpDelta);
                user.setKnowledgePoints(newKp);
                if (unlockedPieces != null) {
                    user.setUnlockedPieces(unlockedPieces.isBlank() ? null : unlockedPieces);
                }
                session.merge(user);
            }
            session.getTransaction().commit();
        }
    }

    public User findByGoogleId(String googleId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                "FROM User WHERE googleId = :googleId", User.class)
                .setParameter("googleId", googleId)
                .uniqueResult();
        }
    }

    public void updateChallengeState(Long id, java.time.LocalDate date, String flags) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                user.setChallengeDate(date);
                user.setChallengeFlags(flags != null ? flags : "");
                session.merge(user);
            }
            session.getTransaction().commit();
        }
    }

    public void deleteUser(Long id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            User user = session.get(User.class, id);
            if (user != null) {
                session.remove(user);
            }
            session.getTransaction().commit();
        }
    }
}
