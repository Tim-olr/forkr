<%@ page contentType="text/html;charset=UTF-8" %>
<%
    pageContext.setAttribute("pageTitle", "Terms of Service");
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
        <span style="font-size:14px;color:var(--ink-faint)">Terms of Service</span>
    </nav>

    <h1>Terms of Service</h1>
    <div class="policy-meta">Last updated: May 24, 2026 &nbsp;&middot;&nbsp; Effective: May 24, 2026</div>

    <p>Please read these Terms of Service (&ldquo;Terms&rdquo;) carefully before using Gambitonline. By creating an account or using the Service, you agree to be bound by these Terms.</p>

    <div class="policy-section">
        <h2>1. Acceptance of Terms</h2>
        <p>By accessing or using Gambitonline (the &ldquo;Service&rdquo;), you confirm that you are at least 13 years of age, have read and understood these Terms, and agree to be bound by them. If you do not agree, do not use the Service.</p>
    </div>

    <div class="policy-section">
        <h2>2. Eligibility</h2>
        <ul>
            <li>You must be at least <strong>13 years old</strong> to create an account.</li>
            <li>Accounts discovered to belong to users under 13 will be permanently deleted without notice.</li>
            <li>You may not create an account on behalf of someone else without their authorisation.</li>
        </ul>
    </div>

    <div class="policy-section">
        <h2>3. Your Account</h2>
        <ul>
            <li>You are responsible for maintaining the confidentiality of your password.</li>
            <li>You are responsible for all activity that occurs under your account.</li>
            <li>You must notify us immediately of any unauthorised use of your account.</li>
            <li>You may not share your account with others or transfer it to another person.</li>
            <li>You may delete your account at any time from your Profile page.</li>
        </ul>
    </div>

    <div class="policy-section">
        <h2>4. Acceptable Use</h2>
        <p>You agree not to:</p>
        <ul>
            <li>Use automated tools, bots, or scripts to gain an unfair advantage in games;</li>
            <li>Harass, threaten, or harm other users;</li>
            <li>Post or transmit offensive, obscene, or unlawful content;</li>
            <li>Attempt to gain unauthorised access to any part of the Service or its infrastructure;</li>
            <li>Interfere with or disrupt the Service or servers connected to the Service;</li>
            <li>Use the Service for any commercial purpose without our prior written consent;</li>
            <li>Impersonate any person or entity or misrepresent your affiliation with any person or entity;</li>
            <li>Upload content that infringes any third-party intellectual property rights.</li>
        </ul>
    </div>

    <div class="policy-section">
        <h2>5. User Content</h2>
        <p>You retain ownership of content you submit (such as profile pictures). By submitting content, you grant Gambitonline a non-exclusive, royalty-free, worldwide licence to use, display, and distribute that content in connection with operating the Service. You represent that you have all rights necessary to grant this licence.</p>
    </div>

    <div class="policy-section">
        <h2>6. Enforcement and Account Termination</h2>
        <p>We reserve the right to suspend or permanently ban any account that violates these Terms, at our sole discretion. Reasons for enforcement action include, but are not limited to:</p>
        <ul>
            <li>Cheating or exploiting bugs;</li>
            <li>Harassment of other users;</li>
            <li>Violation of any applicable law;</li>
            <li>Creation of an account by a person under 13.</li>
        </ul>
        <p>You may appeal enforcement actions by contacting us via the Support page.</p>
    </div>

    <div class="policy-section">
        <h2>7. Intellectual Property</h2>
        <p>All content on the Service (excluding user-submitted content) &mdash; including chess piece artwork, interface design, code, and game logic &mdash; is owned by or licensed to Gambitonline. You may not copy, modify, distribute, or create derivative works without our express written permission.</p>
    </div>

    <div class="policy-section">
        <h2>8. Disclaimer of Warranties</h2>
        <p>The Service is provided &ldquo;as is&rdquo; and &ldquo;as available&rdquo; without warranties of any kind, express or implied, including merchantability, fitness for a particular purpose, or non-infringement. We do not warrant that the Service will be uninterrupted, error-free, or free of viruses.</p>
    </div>

    <div class="policy-section">
        <h2>9. Limitation of Liability</h2>
        <p>To the fullest extent permitted by law, Gambitonline shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising out of your use of or inability to use the Service, even if advised of the possibility of such damages.</p>
    </div>

    <div class="policy-section">
        <h2>10. Changes to Terms</h2>
        <p>We may modify these Terms at any time. We will notify registered users by email when material changes are made. Your continued use of the Service after changes take effect constitutes your acceptance of the revised Terms. If you do not agree with the updated Terms, you should delete your account.</p>
    </div>

    <div class="policy-section">
        <h2>11. Governing Law</h2>
        <p>These Terms are governed by and construed in accordance with applicable law. Any disputes arising from these Terms or the Service shall be resolved in accordance with applicable legal proceedings.</p>
    </div>

    <div class="policy-section">
        <h2>12. Contact Us</h2>
        <div class="contact-box">
            <p style="margin:0;font-size:13px">If you have questions about these Terms, please contact us through the <a href="${pageContext.request.contextPath}/support">Support page</a>.</p>
        </div>
    </div>

    <div style="margin-top:40px;padding-top:20px;border-top:1px solid var(--line);display:flex;gap:20px;font-size:13px">
        <a href="${pageContext.request.contextPath}/privacy-policy" style="color:var(--amber)">Privacy Policy</a>
        <a href="${pageContext.request.contextPath}/home" style="color:var(--ink-faint)">Back to Gambitonline</a>
    </div>
</div>
</body>
</html>
