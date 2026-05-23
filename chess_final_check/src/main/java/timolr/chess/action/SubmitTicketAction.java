package timolr.chess.action;

import jakarta.servlet.http.HttpSession;
import org.apache.struts2.ActionSupport;
import org.apache.struts2.ServletActionContext;
import timolr.chess.account.User;
import timolr.chess.account.UserDAO;
import timolr.chess.support.SupportTicket;
import timolr.chess.support.SupportTicketDAO;

public class SubmitTicketAction extends ActionSupport {

    private String ticketTitle;
    private String ticketMessage;
    private String ticketEmail;
    private String loggedInUsername;

    @Override
    public String execute() {
        HttpSession session = ServletActionContext.getRequest().getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            return "login";
        }
        Long userId = (Long) session.getAttribute("userId");
        loggedInUsername = (String) session.getAttribute("username");

        if (ticketTitle == null || ticketTitle.isBlank()) {
            session.setAttribute("supportFlash", "error:Please enter a subject.");
            return SUCCESS;
        }
        if (ticketMessage == null || ticketMessage.isBlank()) {
            session.setAttribute("supportFlash", "error:Please enter a message.");
            return SUCCESS;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.findById(userId);

        String email = (ticketEmail != null && !ticketEmail.isBlank()) ? ticketEmail.trim() : (user != null ? user.getEmail() : "");

        SupportTicket ticket = new SupportTicket();
        ticket.setSubmittedBy(user);
        ticket.setUserEmail(email);
        ticket.setTitle(ticketTitle.trim());
        ticket.setMessage(ticketMessage.trim());

        new SupportTicketDAO().save(ticket);

        session.setAttribute("supportFlash", "ok:Your support ticket has been submitted. We will contact you at " + email + ".");
        return SUCCESS;
    }

    public String getTicketTitle() { return ticketTitle; }
    public void setTicketTitle(String ticketTitle) { this.ticketTitle = ticketTitle; }

    public String getTicketMessage() { return ticketMessage; }
    public void setTicketMessage(String ticketMessage) { this.ticketMessage = ticketMessage; }

    public String getTicketEmail() { return ticketEmail; }
    public void setTicketEmail(String ticketEmail) { this.ticketEmail = ticketEmail; }

    public String getLoggedInUsername() { return loggedInUsername; }
}
