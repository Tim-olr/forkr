package timolr.chess.support;

import org.hibernate.Session;
import timolr.chess.account.User;
import timolr.chess.util.HibernateUtil;

import java.util.List;

public class SupportTicketDAO {

    public void save(SupportTicket ticket) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            session.persist(ticket);
            session.getTransaction().commit();
        }
    }

    public SupportTicket findById(Long id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.find(SupportTicket.class, id);
        }
    }

    public List<SupportTicket> findAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                    "FROM SupportTicket t LEFT JOIN FETCH t.submittedBy LEFT JOIN FETCH t.claimedBy ORDER BY t.createdAt DESC",
                    SupportTicket.class).list();
        }
    }

    public void claim(Long ticketId, Long adminUserId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            SupportTicket ticket = session.find(SupportTicket.class, ticketId);
            if (ticket != null && "OPEN".equals(ticket.getStatus())) {
                User admin = session.find(User.class, adminUserId);
                ticket.setClaimedBy(admin);
                ticket.setStatus("CLAIMED");
                session.merge(ticket);
            }
            session.getTransaction().commit();
        }
    }

    public void unclaim(Long ticketId, Long adminUserId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            SupportTicket ticket = session.find(SupportTicket.class, ticketId);
            if (ticket != null && "CLAIMED".equals(ticket.getStatus())) {
                boolean isOwner = ticket.getClaimedBy() != null && ticket.getClaimedBy().getId().equals(adminUserId);
                if (isOwner) {
                    ticket.setClaimedBy(null);
                    ticket.setStatus("OPEN");
                    session.merge(ticket);
                }
            }
            session.getTransaction().commit();
        }
    }

    public void assign(Long ticketId, Long newAdminUserId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            SupportTicket ticket = session.find(SupportTicket.class, ticketId);
            if (ticket != null && !"CLOSED".equals(ticket.getStatus())) {
                User admin = session.find(User.class, newAdminUserId);
                ticket.setClaimedBy(admin);
                ticket.setStatus("CLAIMED");
                session.merge(ticket);
            }
            session.getTransaction().commit();
        }
    }

    public void close(Long ticketId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            SupportTicket ticket = session.find(SupportTicket.class, ticketId);
            if (ticket != null) {
                ticket.setStatus("CLOSED");
                session.merge(ticket);
            }
            session.getTransaction().commit();
        }
    }

    public void reopen(Long ticketId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            session.beginTransaction();
            SupportTicket ticket = session.find(SupportTicket.class, ticketId);
            if (ticket != null && "CLOSED".equals(ticket.getStatus())) {
                ticket.setStatus("OPEN");
                ticket.setClaimedBy(null);
                session.merge(ticket);
            }
            session.getTransaction().commit();
        }
    }
}
