<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%
    pageContext.setAttribute("pageTitle", "Owner Setup");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="_head.jsp" %>
    <style>
    body { overflow: auto; }
    .setup-wrap { min-height: 100vh; display: grid; place-items: center; padding: 40px 20px; background: var(--bg); }
    .setup-card { width: 100%; max-width: 400px; }
    </style>
</head>
<body>
<div class="setup-wrap">
    <div class="setup-card">
        <div style="text-align:center;margin-bottom:28px">
            <svg width="36" height="36" viewBox="0 0 24 24" fill="none" style="margin-bottom:12px">
                <rect x="2" y="18" width="20" height="3" rx="1" fill="#d4a44a"/>
                <rect x="9" y="15" width="6" height="3" rx="0.5" fill="#d4a44a"/>
                <circle cx="12" cy="10" r="4" fill="#d4a44a"/>
                <circle cx="12" cy="10" r="1.5" fill="#14110d"/>
            </svg>
            <h1 class="display" style="font-size:30px;margin:0 0 6px;color:var(--crimson)">Owner Setup</h1>
            <p style="color:var(--ink-mute);font-size:13px;margin:0">
                This page is only available when no owner account exists.
                Create the owner account to get started.
            </p>
        </div>

        <s:if test="hasActionErrors()">
            <div style="background:rgba(200,85,61,0.12);border:1px solid rgba(200,85,61,0.4);border-radius:4px;padding:10px 14px;margin-bottom:16px;font-size:13px;color:var(--crimson)">
                <s:iterator value="actionErrors"><s:property /></s:iterator>
            </div>
        </s:if>

        <s:form action="adminSetupSubmit" method="post" theme="simple">
            <div class="form-row">
                <label for="username">Username</label>
                <s:textfield id="username" name="username" placeholder="Admin username" />
            </div>
            <div class="form-row">
                <label for="email">Email</label>
                <s:textfield id="email" name="email" placeholder="Admin email" />
            </div>
            <div class="form-row">
                <label for="password">Password</label>
                <s:password id="password" name="password" placeholder="Create a strong password" />
            </div>
            <div class="form-row" style="margin-bottom:20px">
                <label for="confirmPassword">Confirm Password</label>
                <s:password id="confirmPassword" name="confirmPassword" placeholder="Confirm password" />
            </div>
            <button type="submit" class="btn primary lg" style="width:100%;background:var(--crimson);border-color:var(--crimson)">
                Create Owner Account
            </button>
        </s:form>

        <p style="margin-top:24px;text-align:center;font-size:13px;color:var(--ink-faint)">
            <a href="${pageContext.request.contextPath}/login" style="color:var(--amber);text-decoration:none">&#8592; Back to Login</a>
        </p>
    </div>
</div>
</body>
</html>
