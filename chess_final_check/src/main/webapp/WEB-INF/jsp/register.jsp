<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - Forkr</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chess.css">
</head>
<body>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/home" class="navbar-logo">
        <span class="logo-icon">&#9816;</span>
        <span class="logo-text">Chess</span>
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
        <h2 class="auth-title">Create Your Account</h2>

        <s:if test="registerMessage == 'verify'">
            <div class="auth-success-box">
                <strong>Account created!</strong><br>
                A verification link has been sent to your email address. Please check your inbox and click the link to activate your account.
            </div>
        </s:if>
        <s:elseif test="registerMessage == 'done'">
            <div class="auth-success-box">
                Account created! <a href="${pageContext.request.contextPath}/login">Log in now</a>
            </div>
        </s:elseif>
        <s:if test="hasActionErrors()">
            <ul class="error-list">
                <s:iterator value="actionErrors">
                    <li><s:property /></li>
                </s:iterator>
            </ul>
        </s:if>

        <s:if test="registerMessage == null || registerMessage == ''">
        <s:form action="register" method="post" theme="simple">
            <div class="form-group">
                <label class="form-label" for="username">Username</label>
                <s:textfield id="username" name="username" cssClass="form-input" placeholder="Choose a username" />
            </div>
            <div class="form-group">
                <label class="form-label" for="email">Email</label>
                <s:textfield id="email" name="email" cssClass="form-input" placeholder="Enter your email" />
            </div>
            <div class="form-group">
                <label class="form-label" for="password">Password</label>
                <s:password id="password" name="password" cssClass="form-input" placeholder="Create a password" />
                <div style="font-size:11px;color:var(--text-muted);margin-top:4px">
                    Min. 8 characters &bull; 1 uppercase &bull; 1 number &bull; 1 special character
                </div>
            </div>
            <div class="form-group">
                <label class="form-label" for="confirmPassword">Confirm Password</label>
                <s:password id="confirmPassword" name="confirmPassword" cssClass="form-input" placeholder="Confirm your password" />
            </div>
            <div class="form-submit">
                <button type="submit" class="btn btn-green btn-full btn-lg">Create Account</button>
            </div>
        </s:form>

        </s:if>

        <div class="auth-divider"><span>or</span></div>

        <a href="${pageContext.request.contextPath}/googleAuth" class="btn-google">
            <svg class="btn-google-icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            Continue with Google
        </a>

        <div class="auth-footer">
            Already have an account? <a href="${pageContext.request.contextPath}/login">Log In</a>
        </div>
    </div>
</div>
</body>
</html>
