package timolr.chess.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Protects sensitive endpoints from brute-force and abuse.
 *
 * Limits per client IP:
 *   /login    — 10 attempts per 10 minutes
 *   /register — 5 attempts per hour
 */
public class RateLimitFilter implements Filter {

    private static final int  LOGIN_MAX     = 10;
    private static final long LOGIN_WINDOW  = 10 * 60 * 1000L;  // 10 min

    private static final int  REG_MAX       = 5;
    private static final long REG_WINDOW    = 60 * 60 * 1000L;  // 1 hour

    private static final ConcurrentHashMap<String, long[]> BUCKETS = new ConcurrentHashMap<>();

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getServletPath();
        if (path == null) path = "";

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            if (path.equals("/login") || path.startsWith("/login")) {
                if (isRateLimited(clientIp(request) + ":login", LOGIN_MAX, LOGIN_WINDOW)) {
                    response.setStatus(429);
                    response.setContentType("text/plain;charset=UTF-8");
                    response.getWriter().write("Too many login attempts. Please wait 10 minutes before trying again.");
                    return;
                }
            } else if (path.equals("/register") || path.startsWith("/register")) {
                if (isRateLimited(clientIp(request) + ":register", REG_MAX, REG_WINDOW)) {
                    response.setStatus(429);
                    response.setContentType("text/plain;charset=UTF-8");
                    response.getWriter().write("Too many registration attempts. Please wait before trying again.");
                    return;
                }
            }
        }

        chain.doFilter(req, res);
    }

    /**
     * Returns true if the key has exceeded maxAttempts within windowMs.
     * Bucket format: [attempt count, window start timestamp]
     */
    private boolean isRateLimited(String key, int maxAttempts, long windowMs) {
        long now = System.currentTimeMillis();
        long[] bucket = BUCKETS.compute(key, (k, v) -> {
            if (v == null || now - v[1] > windowMs) {
                return new long[]{1, now};
            }
            v[0]++;
            return v;
        });
        return bucket[0] > maxAttempts;
    }

    /** Extracts the real client IP, respecting common reverse-proxy headers. */
    private String clientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        String realIp = request.getHeader("X-Real-IP");
        if (realIp != null && !realIp.isBlank()) {
            return realIp.trim();
        }
        return request.getRemoteAddr();
    }

    @Override public void init(FilterConfig config) {}
    @Override public void destroy() {}
}
