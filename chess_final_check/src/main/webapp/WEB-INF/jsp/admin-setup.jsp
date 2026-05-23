<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>First Admin Setup - Forkr</title>
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
            <div class="logo-icon">&#9876;</div>
            <div class="logo-text" style="color:var(--error)">First Admin Setup</div>
        </div>
        <p style="text-align:center;color:var(--text-muted);font-size:13px;margin-bottom:20px">
            This page is only available when no admin account exists.
            Create the first administrator account to get started.
        </p>

        <s:if test="hasActionErrors()">
            <ul class="error-list">
                <s:iterator value="actionErrors">
                    <li><s:property /></li>
                </s:iterator>
            </ul>
        </s:if>

        <s:form action="adminSetupSubmit" method="post" theme="simple">
            <div class="form-group">
                <label class="form-label" for="username">Username</label>
                <s:textfield id="username" name="username" cssClass="form-input" placeholder="Admin username" />
            </div>
            <div class="form-group">
                <label class="form-label" for="email">Email</label>
                <s:textfield id="email" name="email" cssClass="form-input" placeholder="Admin email" />
            </div>
            <div class="form-group">
                <label class="form-label" for="password">Password</label>
                <s:password id="password" name="password" cssClass="form-input" placeholder="Create a strong password" />
            </div>
            <div class="form-group">
                <label class="form-label" for="confirmPassword">Confirm Password</label>
                <s:password id="confirmPassword" name="confirmPassword" cssClass="form-input" placeholder="Confirm password" />
            </div>
            <div class="form-submit">
                <button type="submit" class="btn btn-full btn-lg" style="background:var(--error);color:#fff">
                    Create Admin Account
                </button>
            </div>
        </s:form>

        <div class="auth-footer">
            <a href="${pageContext.request.contextPath}/login">Back to Login</a>
        </div>
    </div>
</div>
</body>
</html>
