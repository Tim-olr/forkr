<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - Forkr</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
</head>
<body>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/home" class="navbar-logo">
        <span class="logo-icon">&#9816;</span>
        <span class="logo-text">Forkr</span>
    </a>
</nav>

<div class="auth-container">
    <div class="auth-card">
        <div class="auth-logo">
            <div class="logo-icon">&#9816;</div>
            <div class="logo-text">Forkr</div>
        </div>
        <h2 class="auth-title">Reset Password</h2>

        <s:if test="resetSuccess">
            <div style="background:rgba(129,182,76,0.12);border:1px solid rgba(129,182,76,0.4);border-radius:6px;padding:14px 16px;margin-bottom:20px;color:#81b64c;font-size:14px;">
                <s:property value="message"/>
            </div>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-green btn-full btn-lg">Go to Login</a>
        </s:if>
        <s:else>
            <s:if test="message != null && message != ''">
                <div style="background:rgba(232,97,97,0.12);border:1px solid rgba(232,97,97,0.4);border-radius:6px;padding:14px 16px;margin-bottom:20px;color:var(--error);font-size:14px;">
                    <s:property value="message"/>
                </div>
            </s:if>

            <s:form action="resetPasswordSubmit" method="POST" cssClass="form-submit" style="margin-top:0">
                <s:hidden name="token" value="%{token}"/>

                <div class="form-group">
                    <label class="form-label" for="newPassword">New Password</label>
                    <s:password name="newPassword" id="newPassword" cssClass="form-input" placeholder="Min. 8 characters"/>
                </div>

                <div class="form-group">
                    <label class="form-label" for="confirmPassword">Confirm Password</label>
                    <s:password name="confirmPassword" id="confirmPassword" cssClass="form-input" placeholder="Repeat new password"/>
                </div>

                <button type="submit" class="btn btn-green btn-full btn-lg" style="margin-top:8px">Set New Password</button>
            </s:form>
        </s:else>
    </div>
</div>
</body>
</html>
