<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%
    pageContext.setAttribute("pageTitle", "Email Verification");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="_head.jsp" %>
    <style>
    body { overflow: auto; }
    .auth-wrap { min-height: 100vh; display: grid; place-items: center; padding: 40px 20px; }
    .auth-card { width: 100%; max-width: 400px; text-align: center; }
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

        <s:if test="success">
            <div style="font-size:2.5rem;margin-bottom:12px;color:var(--moss)">&#10003;</div>
            <h1 class="display" style="font-size:28px;margin:0 0 10px;color:var(--moss)">Email Verified!</h1>
            <p style="color:var(--ink-mute);margin-bottom:24px;font-size:14px"><s:property value="message"/></p>
            <a href="${pageContext.request.contextPath}/login" class="btn primary lg" style="width:100%;justify-content:center">Log In Now</a>
        </s:if>
        <s:else>
            <div style="font-size:2.5rem;margin-bottom:12px;color:var(--crimson)">&#10007;</div>
            <h1 class="display" style="font-size:28px;margin:0 0 10px;color:var(--crimson)">Verification Failed</h1>
            <p style="color:var(--ink-mute);margin-bottom:24px;font-size:14px"><s:property value="message"/></p>
            <a href="${pageContext.request.contextPath}/register" class="btn lg" style="width:100%;justify-content:center">Register Again</a>
        </s:else>
    </div>
</div>
</body>
</html>
