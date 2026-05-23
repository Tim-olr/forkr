<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Verification - Forkr</title>
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

        <s:if test="success">
            <div style="text-align:center">
                <div style="font-size:3rem;margin-bottom:12px">&#10003;</div>
                <h2 class="auth-title" style="color:var(--green)">Email Verified!</h2>
                <p style="color:var(--text-muted);margin-bottom:24px"><s:property value="message"/></p>
                <a href="${pageContext.request.contextPath}/login" class="btn btn-green btn-full btn-lg">Log In Now</a>
            </div>
        </s:if>
        <s:else>
            <div style="text-align:center">
                <div style="font-size:3rem;margin-bottom:12px">&#10007;</div>
                <h2 class="auth-title" style="color:var(--danger)">Verification Failed</h2>
                <p style="color:var(--text-muted);margin-bottom:24px"><s:property value="message"/></p>
                <a href="${pageContext.request.contextPath}/register" class="btn btn-outline btn-full">Register Again</a>
            </div>
        </s:else>
    </div>
</div>
</body>
</html>
