#!/bin/bash
# TravelConnect API - Production Deployment Test Script
# Usage: ./deployment/test-production.sh [domain]
# Default domain: api.travelconnect.app

set -e

DOMAIN=${1:-api.travelconnect.app}
PASSED=0
FAILED=0

echo "========================================="
echo "  Production Deployment Tests"
echo "  Domain: $DOMAIN"
echo "  Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================="
echo ""

pass() {
    echo "[PASS] $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo "[FAIL] $1"
    FAILED=$((FAILED + 1))
}

# 1. Health check endpoint
echo "--- API Tests ---"
HEALTH=$(curl -s "https://$DOMAIN/api/health")
if echo "$HEALTH" | grep -q '"status":"ok"'; then
    pass "Health check endpoint returns OK"
else
    fail "Health check endpoint: $HEALTH"
fi

# 2. Database connectivity (via health check)
if echo "$HEALTH" | grep -q '"database":"connected"'; then
    pass "Database connection is active"
else
    fail "Database connection check failed"
fi

# 3. Cache connectivity (via health check)
if echo "$HEALTH" | grep -q '"cache":"working"'; then
    pass "Cache system is working"
else
    fail "Cache system check failed"
fi

# 4. HTTPS redirect
echo ""
echo "--- Security Tests ---"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$DOMAIN/api/health" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    pass "HTTP to HTTPS redirect is working"
else
    fail "HTTP to HTTPS redirect (got: $HTTP_CODE)"
fi

# 5. SSL certificate
SSL_CHECK=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null || echo "failed")
if echo "$SSL_CHECK" | grep -q "notAfter"; then
    pass "SSL certificate is valid"
    echo "       $SSL_CHECK"
else
    fail "SSL certificate check"
fi

# 6. Security headers
echo ""
echo "--- Security Headers ---"
HEADERS=$(curl -s -I "https://$DOMAIN/api/health" 2>/dev/null)

if echo "$HEADERS" | grep -qi "X-Frame-Options"; then
    pass "X-Frame-Options header present"
else
    fail "X-Frame-Options header missing"
fi

if echo "$HEADERS" | grep -qi "X-Content-Type-Options"; then
    pass "X-Content-Type-Options header present"
else
    fail "X-Content-Type-Options header missing"
fi

if echo "$HEADERS" | grep -qi "Strict-Transport-Security"; then
    pass "Strict-Transport-Security header present"
else
    fail "Strict-Transport-Security header missing"
fi

# 7. Protected endpoints require auth
echo ""
echo "--- Auth Tests ---"
AUTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://$DOMAIN/api/user/profile")
if [ "$AUTH_CODE" = "401" ]; then
    pass "Protected endpoints require authentication"
else
    fail "Protected endpoint returned: $AUTH_CODE (expected 401)"
fi

# 8. Auth endpoint validation
GOOGLE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "https://$DOMAIN/api/auth/google" \
    -H "Content-Type: application/json" \
    -d '{"id_token": "invalid"}')
if [ "$GOOGLE_CODE" = "401" ] || [ "$GOOGLE_CODE" = "422" ]; then
    pass "Auth endpoint validates input (returned $GOOGLE_CODE)"
else
    fail "Auth endpoint returned: $GOOGLE_CODE (expected 401 or 422)"
fi

# 9. Admin login page
echo ""
echo "--- Admin Panel Tests ---"
ADMIN_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://$DOMAIN/admin/login")
if [ "$ADMIN_CODE" = "200" ]; then
    pass "Admin login page is accessible"
else
    fail "Admin login page returned: $ADMIN_CODE (expected 200)"
fi

# 10. Admin dashboard requires auth
ADMIN_DASH=$(curl -s -o /dev/null -w "%{http_code}" "https://$DOMAIN/admin/dashboard")
if [ "$ADMIN_DASH" = "302" ]; then
    pass "Admin dashboard requires authentication"
else
    fail "Admin dashboard returned: $ADMIN_DASH (expected 302)"
fi

# 11. App debug is off
echo ""
echo "--- Configuration Tests ---"
ERROR_RESPONSE=$(curl -s "https://$DOMAIN/api/nonexistent-route-12345")
if echo "$ERROR_RESPONSE" | grep -q "stack\|trace\|Exception\|vendor/"; then
    fail "Debug information is exposed in error responses"
else
    pass "No debug information in error responses"
fi

# Summary
echo ""
echo "========================================="
echo "  Results: $PASSED passed, $FAILED failed"
echo "========================================="

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
