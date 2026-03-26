#!/bin/bash
# TravelConnect API - Deployment Script
# Usage: ./deployment/deploy.sh [branch]
# Default branch: main

set -e

BRANCH=${1:-main}
APP_DIR="/var/www/travelconnect-api"
COMPOSER="/usr/local/bin/composer"

echo "========================================="
echo "  TravelConnect API - Deployment"
echo "  Branch: $BRANCH"
echo "  Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================="

cd "$APP_DIR"

# 1. Enable maintenance mode
echo "[1/8] Enabling maintenance mode..."
php artisan down --retry=60

# 2. Pull latest code
echo "[2/8] Pulling latest code from $BRANCH..."
git pull origin "$BRANCH"

# 3. Install dependencies
echo "[3/8] Installing Composer dependencies..."
$COMPOSER install --no-dev --optimize-autoloader --no-interaction

# 4. Run database migrations
echo "[4/8] Running database migrations..."
php artisan migrate --force

# 5. Clear and rebuild caches
echo "[5/8] Rebuilding caches..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# 6. Restart PHP-FPM
echo "[6/8] Restarting PHP-FPM..."
sudo systemctl restart php8.2-fpm

# 7. Restart queue workers (if using queues)
echo "[7/8] Restarting queue workers..."
php artisan queue:restart 2>/dev/null || true

# 8. Disable maintenance mode
echo "[8/8] Disabling maintenance mode..."
php artisan up

echo ""
echo "========================================="
echo "  Deployment completed successfully!"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================="

# Quick health check
echo ""
echo "Running health check..."
HEALTH=$(curl -s http://localhost/api/health 2>/dev/null || echo '{"status":"unreachable"}')
echo "Health: $HEALTH"
