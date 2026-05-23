<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign-in Error - Forkr</title>
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
    <div class="auth-card" style="text-align:center">
        <div style="font-size:3rem;margin-bottom:12px">&#10007;</div>
        <h2 class="auth-title" style="color:var(--error)">Sign-in Failed</h2>
        <p style="color:var(--text-muted);margin-bottom:24px"><s:property value="callbackMessage"/></p>
        <a href="${pageContext.request.contextPath}/login" class="btn btn-green btn-full">Back to Login</a>
    </div>
</div>
</body>
</html>
