<%@ page contentType="text/html;charset=UTF-8" %>
<%
    pageContext.setAttribute("pageTitle", "Privacy Policy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="_head.jsp" %>
    <style>
        html, body { overflow-y: auto; height: auto; }
        body { background: var(--bg); color: var(--ink); font-family: var(--font-body, sans-serif); margin: 0; }
        .policy-wrap { max-width: 760px; margin: 0 auto; padding: 48px 24px 80px; }
        .policy-nav { display: flex; align-items: center; gap: 12px; margin-bottom: 40px; }
        .policy-nav a { color: var(--amber); text-decoration: none; font-size: 14px; }
        .policy-nav-sep { color: var(--ink-faint); font-size: 12px; }
        h1 { font-family: var(--font-display); font-size: 28px; font-weight: 700; margin: 0 0 6px; }
        .policy-meta { font-size: 13px; color: var(--ink-faint); margin-bottom: 36px; }
        h2 { font-size: 17px; font-weight: 600; margin: 32px 0 10px; color: var(--ink); }
        h3 { font-size: 14px; font-weight: 600; margin: 20px 0 6px; color: var(--ink-mute); }
        p, li { font-size: 14px; line-height: 1.7; color: var(--ink-mute); margin: 0 0 10px; }
        ul { padding-left: 20px; margin: 0 0 10px; }
        a { color: var(--amber); }
        .policy-section { border-top: 1px solid var(--line); padding-top: 24px; margin-top: 8px; }
        .contact-box { background: var(--bg-elev); border: 1px solid var(--line); border-radius: 6px; padding: 16px 20px; margin-top: 32px; }
    </style>
</head>
<body>
<div class="policy-wrap">
    <nav class="policy-nav">
        <a href="${pageContext.request.contextPath}/home">Gambitonline</a>
        <span class="policy-nav-sep">/</span>
        <span style="font-size:14px;color:var(--ink-faint)">Privacy Policy</span>
    </nav>

    <h1>Privacy Policy</h1>
    <div class="policy-meta">Last updated: May 24, 2026 &nbsp;&middot;&nbsp; Effective: May 24, 2026</div>

    <p>This Privacy Policy describes how Gambitonline (&ldquo;we,&rdquo; &ldquo;us,&rdquo; or &ldquo;our&rdquo;) collects, uses, and discloses information about you when you use our chess platform and related services (collectively, the &ldquo;Service&rdquo;).</p>

    <div class="policy-section">
        <h2>1. Information We Collect</h2>

        <h3>Information you provide directly</h3>
        <ul>
            <li><strong>Account information:</strong> When you register, we collect your username, email address, and password (stored as a cryptographic hash).</li>
            <li><strong>Profile information:</strong> Profile picture you optionally upload.</li>
            <li><strong>Support communications:</strong> Messages you send via our support system.</li>
            <li><strong>Google OAuth:</strong> If you sign in with Google, we receive your Google account identifier and email address.</li>
        </ul>

        <h3>Information collected automatically</h3>
        <ul>
            <li><strong>Game data:</strong> Match records, ELO ratings, army configurations, and gameplay statistics.</li>
            <li><strong>Log data:</strong> IP addresses, browser type, pages visited, and timestamps when you interact with the Service.</li>
            <li><strong>Session data:</strong> Authentication session tokens stored in your browser.</li>
        </ul>
    </div>

    <div class="policy-section">
        <h2>2. How We Use Your Information</h2>
        <p>We use the information we collect to:</p>
        <ul>
            <li>Create and manage your account;</li>
            <li>Provide, maintain, and improve the Service;</li>
            <li>Process and display game results and leaderboards;</li>
            <li>Send account-related emails (verification, password reset, security notices);</li>
            <li>Respond to your comments and questions;</li>
            <li>Monitor for and prevent abuse, cheating, or violations of our Terms of Service;</li>
            <li>Comply with legal obligations.</li>
        </ul>
    </div>

    <div class="policy-section">
        <h2>3. Information Sharing</h2>
        <p>We do not sell your personal information. We may share your information in the following circumstances:</p>
        <ul>
            <li><strong>Publicly visible data:</strong> Your username, ELO rating, and army names may be visible to other players.</li>
            <li><strong>Service providers:</strong> We may share information with third-party vendors that help us operate the Service (e.g., email delivery). These providers are bound by confidentiality obligations.</li>
            <li><strong>Legal requirements:</strong> We may disclose information if required by law or if we believe disclosure is necessary to protect rights, property, or safety.</li>
            <li><strong>Business transfers:</strong> In connection with a merger, acquisition, or sale of assets, your information may be transferred as a business asset.</li>
        </ul>
    </div>

    <div class="policy-section">
        <h2>4. Children&rsquo;s Privacy</h2>
        <p>The Service is not directed to children under 13 years of age. We do not knowingly collect personal information from children under 13. If we learn that we have collected personal information from a child under 13, we will take steps to delete that information promptly. By registering, you represent that you are at least 13 years old.</p>
    </div>

    <div class="policy-section">
        <h2>5. Data Retention</h2>
        <p>We retain your account information for as long as your account is active. You may request deletion of your account at any time from your Profile page. Upon deletion, your account, armies, and personal data will be permanently removed. Anonymised game statistics and ban logs may be retained for operational integrity.</p>
    </div>

    <div class="policy-section">
        <h2>6. Security</h2>
        <p>We implement reasonable technical and organisational measures to protect your information, including password hashing and HTTPS transport. No security measure is perfect; we cannot guarantee absolute security.</p>
    </div>

    <div class="policy-section">
        <h2>7. Third-Party Services</h2>
        <p>The Service may contain links to third-party websites or use third-party services (such as Google OAuth). This Privacy Policy does not apply to those services, and we encourage you to review their privacy policies.</p>
    </div>

    <div class="policy-section">
        <h2>8. Your Rights</h2>
        <p>Depending on your location, you may have rights regarding your personal information, including the right to access, correct, or delete your data. You may delete your account directly from your profile page. For other requests, contact us using the information below.</p>
    </div>

    <div class="policy-section">
        <h2>9. Changes to This Policy</h2>
        <p>We may update this Privacy Policy from time to time. When we make material changes, we will notify registered users by email and update the &ldquo;Last updated&rdquo; date above. Your continued use of the Service after changes take effect constitutes acceptance of the revised policy.</p>
    </div>

    <div class="policy-section">
        <h2>10. Contact Us</h2>
        <div class="contact-box">
            <p style="margin:0;font-size:13px">If you have questions or concerns about this Privacy Policy, please contact us through the <a href="${pageContext.request.contextPath}/support">Support page</a>.</p>
        </div>
    </div>

    <div style="margin-top:40px;padding-top:20px;border-top:1px solid var(--line);display:flex;gap:20px;font-size:13px">
        <a href="${pageContext.request.contextPath}/terms" style="color:var(--amber)">Terms of Service</a>
        <a href="${pageContext.request.contextPath}/home" style="color:var(--ink-faint)">Back to Gambitonline</a>
    </div>
</div>
</body>
</html>
