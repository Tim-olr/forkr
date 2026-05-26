<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%
    pageContext.setAttribute("pageTitle", "Log In");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="_head.jsp" %>
    <style>
        body { overflow: hidden; }
        .login-shell { display: grid; grid-template-columns: 1fr 1fr; height: 100vh; }
        @media (max-width: 700px) { .login-shell { grid-template-columns: 1fr; } .login-art { display: none; } }
    </style>
</head>
<body>
<div class="login-shell">
    <!-- Left: decorative chess board art -->
    <div class="login-art">
        <div class="login-art-mark">
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none"><rect x="2" y="18" width="20" height="3" rx="1" fill="#d4a44a"/><rect x="9" y="15" width="6" height="3" rx="0.5" fill="#d4a44a"/><circle cx="12" cy="10" r="4" fill="#d4a44a"/><circle cx="12" cy="10" r="1.5" fill="#14110d"/></svg>
            <span style="font-family:var(--font-display);font-size:20px;letter-spacing:-0.01em;color:var(--ink)">Gambitonline</span>
        </div>
        <div class="login-art-grid">
            <div class="login-board" id="artBoard"></div>
        </div>
        <div class="login-art-foot">
            <div style="font-family:var(--font-display);font-size:13px;color:var(--ink-mute);line-height:1.5">
                Chess, reimagined.<br>35 unique pieces. Infinite strategy.
            </div>
            <div class="login-tag">35 piece types</div>
        </div>
    </div>

    <!-- Right: login form -->
    <div class="login-form-wrap">
        <div class="login-form">
            <h1 class="display">Welcome back</h1>
            <p class="sub">Sign in to your Gambitonline account</p>

            <s:if test="hasActionErrors()">
                <div style="background:rgba(200,85,61,0.12);border:1px solid rgba(200,85,61,0.4);border-radius:4px;padding:10px 14px;margin-bottom:16px;font-size:13px;color:var(--crimson)">
                    <s:iterator value="actionErrors"><s:property /></s:iterator>
                </div>
            </s:if>

            <s:form action="login" method="post" theme="simple">
                <div class="form-row">
                    <label for="username">Username</label>
                    <s:textfield id="username" name="username" placeholder="Enter your username" />
                </div>
                <div class="form-row" style="margin-bottom:6px">
                    <label for="password">Password</label>
                    <s:password id="password" name="password" placeholder="Enter your password" />
                </div>
                <div style="text-align:right;margin-bottom:20px">
                    <a href="${pageContext.request.contextPath}/forgotPassword" style="font-size:12px;color:var(--ink-faint);text-decoration:none">Forgot password?</a>
                </div>
                <button type="submit" class="btn primary lg" style="width:100%">Log In</button>
            </s:form>

            <div style="display:flex;align-items:center;gap:12px;margin:20px 0">
                <div style="flex:1;height:1px;background:var(--line)"></div>
                <span style="font-size:12px;color:var(--ink-faint)">or</span>
                <div style="flex:1;height:1px;background:var(--line)"></div>
            </div>

            <a href="${pageContext.request.contextPath}/googleAuth" class="btn" style="width:100%;justify-content:center;gap:10px">
                <svg width="16" height="16" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
                Continue with Google
            </a>

            <p style="margin-top:28px;font-size:13px;color:var(--ink-faint);text-align:center">
                New to Gambitonline? <a href="${pageContext.request.contextPath}/register" style="color:var(--amber);text-decoration:none">Create an account</a>
            </p>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/piece-art.js"></script>
<script>
(function() {
    var board = document.getElementById('artBoard');
    if (!board) return;
    var pieces = [
        {r:1,f:0,ch:'r',w:false},{r:1,f:1,ch:'n',w:false},{r:1,f:2,ch:'b',w:false},{r:1,f:3,ch:'q',w:false},
        {r:1,f:4,ch:'k',w:false},{r:1,f:5,ch:'b',w:false},{r:1,f:6,ch:'n',w:false},{r:1,f:7,ch:'r',w:false},
        {r:2,f:0,ch:'p',w:false},{r:2,f:1,ch:'e',w:false},{r:2,f:2,ch:'sq',w:false},{r:2,f:3,ch:'p',w:false},
        {r:2,f:4,ch:'p',w:false},{r:2,f:5,ch:'lp',w:false},{r:2,f:6,ch:'p',w:false},{r:2,f:7,ch:'p',w:false},
        {r:7,f:0,ch:'p',w:true},{r:7,f:1,ch:'p',w:true},{r:7,f:2,ch:'p',w:true},{r:7,f:3,ch:'p',w:true},
        {r:7,f:4,ch:'p',w:true},{r:7,f:5,ch:'p',w:true},{r:7,f:6,ch:'p',w:true},{r:7,f:7,ch:'p',w:true},
        {r:8,f:0,ch:'r',w:true},{r:8,f:1,ch:'n',w:true},{r:8,f:2,ch:'b',w:true},{r:8,f:3,ch:'q',w:true},
        {r:8,f:4,ch:'k',w:true},{r:8,f:5,ch:'b',w:true},{r:8,f:6,ch:'n',w:true},{r:8,f:7,ch:'r',w:true}
    ];
    var pieceMap = {};
    pieces.forEach(function(p){ pieceMap[p.r+','+p.f] = p; });
    for (var row=1; row<=8; row++) {
        for (var col=0; col<8; col++) {
            var sq = document.createElement('div');
            var isLight = (row + col) % 2 === 0;
            sq.className = 'sq ' + (isLight ? 'l' : 'd');
            var key = row+','+col;
            if (pieceMap[key]) {
                var pc = pieceMap[key];
                var wrap = document.createElement('div');
                wrap.className = 'login-piece';
                wrap.appendChild(window.buildPieceSVG(pc.ch, pc.w));
                sq.appendChild(wrap);
            }
            board.appendChild(sq);
        }
    }
}());
</script>
</body>
</html>
