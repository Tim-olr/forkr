<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%
    pageContext.setAttribute("pageTitle", "Reset Password");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="_head.jsp" %>
    <style>
    body { overflow: auto; }
    .auth-wrap { min-height: 100vh; display: grid; place-items: center; padding: 40px 20px; }
    .auth-card { width: 100%; max-width: 400px; }
    .auth-brand { display: flex; align-items: center; gap: 9px; justify-content: center; text-decoration: none; color: inherit; margin-bottom: 28px; }
    </style>
</head>
<body>
<div class="auth-wrap">
    <div class="auth-card">
        <a href="${pageContext.request.contextPath}/login" class="auth-brand">
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none">
                <rect x="2" y="18" width="20" height="3" rx="1" fill="#d4a44a"/>
                <rect x="9" y="15" width="6" height="3" rx="0.5" fill="#d4a44a"/>
                <circle cx="12" cy="10" r="4" fill="#d4a44a"/>
                <circle cx="12" cy="10" r="1.5" fill="#14110d"/>
            </svg>
            <span style="font-family:var(--font-display);font-size:20px;letter-spacing:-0.01em">Gambitonline</span>
        </a>

        <h1 class="display" style="font-size:28px;margin:0 0 24px">Reset password</h1>

        <s:if test="resetSuccess">
            <div style="background:rgba(122,148,97,0.12);border:1px solid rgba(122,148,97,0.4);border-radius:4px;padding:12px 14px;margin-bottom:20px;font-size:13px;color:var(--moss)">
                <s:property value="message"/>
            </div>
            <a href="${pageContext.request.contextPath}/login" class="btn primary lg" style="width:100%;justify-content:center">Go to Login</a>
        </s:if>
        <s:else>
            <s:if test="message != null && message != ''">
                <div style="background:rgba(200,85,61,0.12);border:1px solid rgba(200,85,61,0.4);border-radius:4px;padding:12px 14px;margin-bottom:16px;font-size:13px;color:var(--crimson)">
                    <s:property value="message"/>
                </div>
            </s:if>

            <s:form action="resetPasswordSubmit" method="POST" theme="simple">
                <s:hidden name="token" value="%{token}"/>
                <div class="form-row">
                    <label for="newPassword">New Password</label>
                    <s:password name="newPassword" id="newPassword" placeholder="Min. 8 characters"/>
                </div>
                <div class="form-row" style="margin-bottom:20px">
                    <label for="confirmPassword">Confirm Password</label>
                    <s:password name="confirmPassword" id="confirmPassword" placeholder="Repeat new password"/>
                </div>
                <button type="submit" class="btn primary lg" style="width:100%;justify-content:center">Set New Password</button>
            </s:form>
        </s:else>

        <p style="margin-top:24px;font-size:13px;color:var(--ink-faint);text-align:center">
            <a href="${pageContext.request.contextPath}/login" style="color:var(--amber);text-decoration:none">&#8592; Back to Login</a>
        </p>
    </div>
</div>
</body>
</html>
