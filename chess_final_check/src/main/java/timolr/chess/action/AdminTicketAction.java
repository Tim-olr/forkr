package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.support.SupportTicket;
import timolr.chess.support.SupportTicketDAO;

import java.util.List;
import java.util.stream.Collectors;

public class AdminTicketAction extends ActionSupport {

    private List<SupportTicket> allTickets;
    private List<User> adminUsers;
    private String loggedInUsername;

    private Long ticketId;
    private Long assignAdminId;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            return "forbidden";
        }
        loggedInUsername = (String) session.getAttribute("username");
        allTickets = new SupportTicketDAO().findAll();
        adminUsers = new UserDAO().findAll().stream()
                .filter(User::isAdmin)
                .collect(Collectors.toList());
        return SUCCESS;
    }

    public String claim() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) return "forbidden";
        Long adminId = (Long) session.getAttribute("userId");
        if (ticketId != null) new SupportTicketDAO().claim(ticketId, adminId);
        session.setAttribute("adminTicketFlash", "Ticket claimed.");
        return "redirect";
    }

    public String unclaim() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) return "forbidden";
        Long adminId = (Long) session.getAttribute("userId");
        if (ticketId != null) new SupportTicketDAO().unclaim(ticketId, adminId);
        session.setAttribute("adminTicketFlash", "Ticket unclaimed.");
        return "redirect";
    }

    public String assign() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) return "forbidden";
        if (ticketId != null && assignAdminId != null) new SupportTicketDAO().assign(ticketId, assignAdminId);
        session.setAttribute("adminTicketFlash", "Ticket assigned.");
        return "redirect";
    }

    public String close() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) return "forbidden";
        if (ticketId != null) new SupportTicketDAO().close(ticketId);
        session.setAttribute("adminTicketFlash", "Ticket closed.");
        return "redirect";
    }

    public String reopen() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) return "forbidden";
        if (ticketId != null) new SupportTicketDAO().reopen(ticketId);
        session.setAttribute("adminTicketFlash", "Ticket reopened.");
        return "redirect";
    }

    public List<SupportTicket> getAllTickets() { return allTickets; }
    public List<User> getAdminUsers() { return adminUsers; }
    public String getLoggedInUsername() { return loggedInUsername; }

    public Long getTicketId() { return ticketId; }
    public void setTicketId(Long ticketId) { this.ticketId = ticketId; }

    public Long getAssignAdminId() { return assignAdminId; }
    public void setAssignAdminId(Long assignAdminId) { this.assignAdminId = assignAdminId; }
}
