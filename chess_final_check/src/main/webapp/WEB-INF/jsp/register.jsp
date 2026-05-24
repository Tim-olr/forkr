<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%
    pageContext.setAttribute("pageTitle", "Sign Up");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="_head.jsp" %>
    <style>body { overflow: hidden; } .login-shell { display:grid; grid-template-columns:1fr 1fr; height:100vh; } @media(max-width:700px){.login-shell{grid-template-columns:1fr}.login-art{display:none}}</style>
</head>
<body>
<div class="login-shell">
    <div class="login-art">
        <div class="login-art-mark">
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none"><rect x="2" y="18" width="20" height="3" rx="1" fill="#d4a44a"/><rect x="9" y="15" width="6" height="3" rx="0.5" fill="#d4a44a"/><circle cx="12" cy="10" r="4" fill="#d4a44a"/><circle cx="12" cy="10" r="1.5" fill="#14110d"/></svg>
            <span style="font-family:var(--font-display);font-size:20px;letter-spacing:-0.01em;color:var(--ink)">Forkr</span>
        </div>
        <div class="login-art-grid">
            <div class="login-board" id="artBoard"></div>
        </div>
        <div class="login-art-foot">
            <div style="font-family:var(--font-display);font-size:13px;color:var(--ink-mute);line-height:1.5">Join thousands of players.<br>Build your army. Master the pieces.</div>
            <div class="login-tag">Free to play</div>
        </div>
    </div>

    <div class="login-form-wrap">
        <div class="login-form">
            <h1 class="display">Create account</h1>
            <p class="sub">Join Forkr and start playing</p>

            <s:if test="registerMessage == 'verify'">
                <div style="background:rgba(122,148,97,0.12);border:1px solid rgba(122,148,97,0.4);border-radius:4px;padding:12px 14px;margin-bottom:20px;font-size:13px;color:var(--moss)">
                    <strong>Account created!</strong> A verification link has been sent to your email. Check your inbox to activate your account.
                </div>
            </s:if>
            <s:elseif test="registerMessage == 'done'">
                <div style="background:rgba(122,148,97,0.12);border:1px solid rgba(122,148,97,0.4);border-radius:4px;padding:12px 14px;margin-bottom:20px;font-size:13px;color:var(--moss)">
                    Account created! <a href="${pageContext.request.contextPath}/login" style="color:var(--amber)">Log in now →</a>
                </div>
            </s:elseif>

            <s:if test="hasActionErrors()">
                <div style="background:rgba(200,85,61,0.12);border:1px solid rgba(200,85,61,0.4);border-radius:4px;padding:10px 14px;margin-bottom:16px;font-size:13px;color:var(--crimson)">
                    <s:iterator value="actionErrors"><s:property /><br /></s:iterator>
                </div>
            </s:if>

            <s:if test="registerMessage == null || registerMessage == ''">
            <s:form action="register" method="post" theme="simple">
                <div class="form-row">
                    <label for="username">Username</label>
                    <s:textfield id="username" name="username" placeholder="Choose a username" />
                </div>
                <div class="form-row">
                    <label for="email">Email</label>
                    <s:textfield id="email" name="email" placeholder="Enter your email" />
                </div>
                <div class="form-row">
                    <label for="password">Password</label>
                    <s:password id="password" name="password" placeholder="Min 8 chars, 1 uppercase, 1 number" />
                </div>
                <div class="form-row">
                    <label for="confirmPassword">Confirm Password</label>
                    <s:password id="confirmPassword" name="confirmPassword" placeholder="Confirm your password" />
                </div>
                <div style="display:flex;flex-direction:column;gap:10px;margin-top:10px;padding:12px;background:var(--bg-elev);border:1px solid var(--line);border-radius:5px">
                    <label style="display:flex;align-items:flex-start;gap:9px;cursor:pointer;font-size:13px;color:var(--ink-mute);line-height:1.4">
                        <input type="checkbox" name="agreeTerms" value="true" style="margin-top:2px;flex-shrink:0;accent-color:var(--amber)">
                        <span>I have read and agree to the <a href="${pageContext.request.contextPath}/terms" target="_blank" style="color:var(--amber);text-decoration:none">Terms of Service</a> and <a href="${pageContext.request.contextPath}/privacy-policy" target="_blank" style="color:var(--amber);text-decoration:none">Privacy Policy</a>.</span>
                    </label>
                    <label style="display:flex;align-items:flex-start;gap:9px;cursor:pointer;font-size:13px;color:var(--ink-mute);line-height:1.4">
                        <input type="checkbox" name="ageConfirm" value="true" style="margin-top:2px;flex-shrink:0;accent-color:var(--amber)">
                        <span>I confirm that I am <strong style="color:var(--ink)">13 years of age or older</strong>. I understand that accounts found to belong to users under 13 may be permanently deleted.</span>
                    </label>
                </div>
                <button type="submit" class="btn primary lg" style="width:100%;margin-top:6px">Create Account</button>
            </s:form>
            </s:if>

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
                Already have an account? <a href="${pageContext.request.contextPath}/login" style="color:var(--amber);text-decoration:none">Log in</a>
            </p>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/piece-art.js"></script>
<script>
(function(){var b=document.getElementById('artBoard');if(!b)return;for(var r=1;r<=8;r++){for(var c=0;c<8;c++){var sq=document.createElement('div');sq.className='sq '+((r+c)%2===0?'l':'d');b.appendChild(sq);}}
var arts=[{r:1,f:0,ch:'r',w:false},{r:1,f:1,ch:'n',w:false},{r:1,f:2,ch:'b',w:false},{r:1,f:3,ch:'q',w:false},{r:1,f:4,ch:'k',w:false},{r:1,f:5,ch:'b',w:false},{r:1,f:6,ch:'n',w:false},{r:1,f:7,ch:'r',w:false},{r:2,f:0,ch:'p',w:false},{r:2,f:1,ch:'p',w:false},{r:2,f:2,ch:'p',w:false},{r:2,f:3,ch:'p',w:false},{r:2,f:4,ch:'p',w:false},{r:2,f:5,ch:'p',w:false},{r:2,f:6,ch:'p',w:false},{r:2,f:7,ch:'p',w:false},{r:7,f:0,ch:'p',w:true},{r:7,f:1,ch:'p',w:true},{r:7,f:2,ch:'p',w:true},{r:7,f:3,ch:'p',w:true},{r:7,f:4,ch:'p',w:true},{r:7,f:5,ch:'p',w:true},{r:7,f:6,ch:'p',w:true},{r:7,f:7,ch:'p',w:true},{r:8,f:0,ch:'r',w:true},{r:8,f:1,ch:'n',w:true},{r:8,f:2,ch:'b',w:true},{r:8,f:3,ch:'q',w:true},{r:8,f:4,ch:'k',w:true},{r:8,f:5,ch:'b',w:true},{r:8,f:6,ch:'n',w:true},{r:8,f:7,ch:'r',w:true}];
var m={};arts.forEach(function(p){m[p.r+','+p.f]=p;});var sqs=b.querySelectorAll('.sq');var i=0;for(var rr=1;rr<=8;rr++){for(var cc=0;cc<8;cc++){var key=rr+','+cc;if(m[key]){var wr=document.createElement('div');wr.className='login-piece';wr.appendChild(window.buildPieceSVG(m[key].ch,m[key].w));sqs[i].appendChild(wr);}i++;}}
}());
</script>
</body>
</html>
