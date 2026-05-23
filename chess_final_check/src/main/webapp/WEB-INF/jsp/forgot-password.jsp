<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - Forkr</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
</head>
<body>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/home" class="navbar-logo">
        <span class="logo-icon">&#9816;</span>
        <span class="logo-text">Forkr</span>
    </a>
    <div class="navbar-right">
        <a href="${pageContext.request.contextPath}/login" class="btn btn-outline">Log In</a>
    </div>
</nav>

<div class="auth-container">
    <div class="auth-card">
        <div class="auth-logo">
            <div class="logo-icon">&#9816;</div>
            <div class="logo-text">Forkr</div>
        </div>
        <h2 class="auth-title">Forgot Password</h2>

        <s:if test="submitted">
            <div class="auth-success-box">
                <s:property value="message"/>
            </div>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-green btn-full btn-lg" style="margin-top:8px">Back to Login</a>
        </s:if>
        <s:else>
            <p style="color:var(--text-muted);font-size:14px;margin-bottom:20px;text-align:center;line-height:1.5">
                Enter your email address and we'll send you a link to reset your password.
            </p>

            <s:form action="forgotPasswordSubmit" method="post" theme="simple">
                <div class="form-group">
                    <label class="form-label" for="email">Email Address</label>
                    <s:textfield id="email" name="email" cssClass="form-input" placeholder="Enter your email address"/>
                </div>
                <div class="form-submit">
                    <button type="submit" class="btn btn-green btn-full btn-lg">Send Reset Link</button>
                </div>
            </s:form>

            <div class="auth-footer">
                <a href="${pageContext.request.contextPath}/login">Back to Login</a>
            </div>
        </s:else>
    </div>
</div>
</body>
</html>
