<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ page import="timolr.chess.account.User, timolr.chess.account.UserDAO" %>
<%
    pageContext.setAttribute("pageTitle", "Support");
    pageContext.setAttribute("activeNav", "support");
    Long uid = (Long) session.getAttribute("userId");
    String userEmail = "";
    if (uid != null) {
        User u = new UserDAO().findById(uid);
        if (u != null && u.getEmail() != null) userEmail = u.getEmail();
    }
    String supportFlash = (String) session.getAttribute("supportFlash");
    if (supportFlash != null) session.removeAttribute("supportFlash");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="_head.jsp" %>
</head>
<body>
<div class="app-shell">
    <%@ include file="_sidebar.jsp" %>

    <main class="page">
        <div class="page-head">
            <div class="crumb">
                <span class="crumb-pre">Help</span>
                <h2>Support</h2>
            </div>
        </div>

        <div class="page-body">
            <% if (supportFlash != null) {
                boolean isOk = supportFlash.startsWith("ok:");
                String flashMsg = supportFlash.replaceFirst("^(ok:|error:)", "");
            %>
            <div style="background:rgba(<%= isOk ? "122,148,97" : "200,85,61" %>,0.12);border:1px solid rgba(<%= isOk ? "122,148,97" : "200,85,61" %>,0.4);border-radius:4px;padding:10px 14px;margin-bottom:16px;font-size:13px;color:var(--<%= isOk ? "moss" : "crimson" %>)">
                <%= flashMsg %>
            </div>
            <% } %>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;align-items:start">
                <!-- Submit ticket -->
                <div class="card" style="padding:24px">
                    <div style="font-size:15px;font-weight:500;margin-bottom:4px">Submit a Support Ticket</div>
                    <p style="color:var(--ink-faint);font-size:13px;margin:0 0 20px">Have an issue, found a bug, or need help? Fill out the form and we'll get back to you.</p>

                    <form method="POST" action="${pageContext.request.contextPath}/submitTicket">
                        <div class="form-row">
                            <label>Your Email <span style="color:var(--ink-faint);font-weight:400">(we'll reply here)</span></label>
                            <input type="email" name="ticketEmail" value="<%= userEmail.replace("\"","&quot;") %>" placeholder="email@example.com" required>
                        </div>
                        <div class="form-row">
                            <label>Subject</label>
                            <input type="text" name="ticketTitle" placeholder="Brief description of your issue…" maxlength="200" required>
                        </div>
                        <div class="form-row">
                            <label>Message</label>
                            <textarea name="ticketMessage" rows="6" placeholder="Describe your issue in detail…" style="resize:vertical" required></textarea>
                        </div>
                        <button type="submit" class="btn primary" style="width:100%;margin-top:4px">Submit Ticket</button>
                    </form>
                </div>

                <!-- Report a player + FAQ -->
                <div style="display:flex;flex-direction:column;gap:14px">
                    <!-- Report player -->
                    <div class="card" style="padding:24px">
                        <div style="font-size:15px;font-weight:500;margin-bottom:4px">Report a Player</div>
                        <p style="color:var(--ink-faint);font-size:13px;margin:0 0 20px">Experiencing unsportsmanlike behaviour, cheating, or harassment? Let us know.</p>
                        <form id="reportForm" method="POST" action="${pageContext.request.contextPath}/submitReport">
                            <div class="form-row">
                                <label>Player Username</label>
                                <input type="text" id="reportTarget" name="targetUsername" placeholder="Username of the player" required
                                    oninput="lookupReportTarget(this.value)">
                                <input type="hidden" id="reportTargetId" name="targetId" value="">
                            </div>
                            <div class="form-row">
                                <label>Reason</label>
                                <select name="reason" required>
                                    <option value="">Select a reason…</option>
                                    <option value="Cheating">Cheating / Engine Use</option>
                                    <option value="Harassment">Harassment</option>
                                    <option value="Unsportsmanlike">Unsportsmanlike Conduct</option>
                                    <option value="Hate Speech">Hate Speech</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <button type="submit" class="btn danger" style="width:100%">Submit Report</button>
                        </form>
                        <div id="reportMsg" style="margin-top:10px;font-size:13px;display:none"></div>
                    </div>

                    <!-- FAQ -->
                    <div class="card" style="padding:24px">
                        <div style="font-size:15px;font-weight:500;margin-bottom:14px">Frequently Asked Questions</div>
                        <div style="display:flex;flex-direction:column;gap:12px">
                            <details style="border:1px solid var(--line);border-radius:4px;padding:10px 14px">
                                <summary style="cursor:pointer;font-size:13px;font-weight:500;list-style:none;display:flex;justify-content:space-between;align-items:center">
                                    How do I unlock new pieces? <span style="color:var(--ink-faint);font-size:16px">+</span>
                                </summary>
                                <p style="margin-top:10px;color:var(--ink-mute);font-size:13px;line-height:1.55">
                                    Visit the Academy to spend Knowledge Points (KP) and unlock new pieces. You earn KP by playing games and completing daily challenges.
                                </p>
                            </details>
                            <details style="border:1px solid var(--line);border-radius:4px;padding:10px 14px">
                                <summary style="cursor:pointer;font-size:13px;font-weight:500;list-style:none;display:flex;justify-content:space-between;align-items:center">
                                    What are army grades? <span style="color:var(--ink-faint);font-size:16px">+</span>
                                </summary>
                                <p style="margin-top:10px;color:var(--ink-mute);font-size:13px;line-height:1.55">
                                    Pieces have grades G0–G3 that control how many you can include. G3 is your king (exactly one), G2 are major pieces (2 max total), G1 are standard pieces, and G0 are pawn-class (8 max per type).
                                </p>
                            </details>
                            <details style="border:1px solid var(--line);border-radius:4px;padding:10px 14px">
                                <summary style="cursor:pointer;font-size:13px;font-weight:500;list-style:none;display:flex;justify-content:space-between;align-items:center">
                                    How do I change my army? <span style="color:var(--ink-faint);font-size:16px">+</span>
                                </summary>
                                <p style="margin-top:10px;color:var(--ink-mute);font-size:13px;line-height:1.55">
                                    Go to the Army Builder to create or edit your army. Set one as active from the Army Builder and it will be used in online matches.
                                </p>
                            </details>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
var CTX = "${pageContext.request.contextPath}";
var _reportLookupTimer;

function lookupReportTarget(val) {
    clearTimeout(_reportLookupTimer);
    document.getElementById('reportTargetId').value = '';
    if (!val || val.length < 2) return;
    _reportLookupTimer = setTimeout(function() {
        fetch(CTX + '/profile?lookupUsername=' + encodeURIComponent(val))
            .then(function(r) { return r.json(); })
            .catch(function() { return null; });
    }, 400);
}

document.getElementById('reportForm').addEventListener('submit', function(e) {
    e.preventDefault();
    var msg = document.getElementById('reportMsg');
    var fd = new FormData(this);
    fetch(CTX + '/submitReport', { method: 'POST', body: fd })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            msg.style.display = 'block';
            if (data.ok) {
                msg.style.color = 'var(--moss)';
                msg.textContent = 'Report submitted. Thank you.';
                document.getElementById('reportForm').reset();
            } else {
                msg.style.color = 'var(--crimson)';
                msg.textContent = 'Could not submit report. Please try again.';
            }
        })
        .catch(function() {
            msg.style.display = 'block';
            msg.style.color = 'var(--crimson)';
            msg.textContent = 'Network error. Please try again.';
        });
});
</script>
<%@ include file="_bot-picker.jsp" %>
</body>
</html>
