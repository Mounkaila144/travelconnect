#!/bin/bash
# TravelConnect API - Server Setup Script
# Run on a fresh Ubuntu 22.04 LTS VPS
# Usage: sudo bash deployment/server-setup.sh
#
# Prerequisites:
#   - Fresh Ubuntu 22.04 LTS installation
#   - Root or sudo access
#   - Domain DNS A record pointing to server IP

set -e

echo "========================================="
echo "  TravelConnect API - Server Setup"
echo "  Ubuntu 22.04 LTS"
echo "========================================="

# 1. System update
echo "[1/10] Updating system packages..."
apt update && apt upgrade -y

# 2. Install required packages
echo "[2/10] Installing system packages..."
apt install -y \
    nginx \
    git \
    curl \
    unzip \
    ufw \
    fail2ban \
    htop \
    logrotate

# 3. Install PHP 8.2
echo "[3/10] Installing PHP 8.2..."
apt install -y software-properties-common
add-apt-repository -y ppa:ondrej/php
apt update
apt install -y \
    php8.2-fpm \
    php8.2-cli \
    php8.2-mysql \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-curl \
    php8.2-zip \
    php8.2-gd \
    php8.2-intl \
    php8.2-bcmath

# 4. Install MySQL 8.0
echo "[4/10] Installing MySQL 8.0..."
apt install -y mysql-server

# 5. Install Composer
echo "[5/10] Installing Composer..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# 6. Install Certbot
echo "[6/10] Installing Certbot..."
apt install -y certbot python3-certbot-nginx

# 7. Configure PHP-FPM
echo "[7/10] Configuring PHP-FPM..."
cat > /etc/php/8.2/fpm/conf.d/99-travelconnect.ini <<'EOF'
memory_limit = 256M
upload_max_filesize = 10M
post_max_size = 10M
date.timezone = UTC
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.revalidate_freq=2
EOF

systemctl restart php8.2-fpm

# 8. Configure firewall
echo "[8/10] Configuring UFW firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# 9. Configure fail2ban
echo "[9/10] Configuring fail2ban..."
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl start fail2ban

# 10. Create application directory
echo "[10/10] Preparing application directory..."
mkdir -p /var/www/travelconnect-api
mkdir -p /var/backups/mysql

echo ""
echo "========================================="
echo "  Server setup completed!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Clone your repository to /var/www/travelconnect-api"
echo "  2. Copy deployment/nginx/travelconnect.conf to /etc/nginx/sites-available/"
echo "  3. Create symlink: ln -s /etc/nginx/sites-available/travelconnect /etc/nginx/sites-enabled/"
echo "  4. Add rate limit zone to /etc/nginx/nginx.conf http block:"
echo "     limit_req_zone \$binary_remote_addr zone=api:10m rate=60r/m;"
echo "  5. Run: mysql_secure_installation"
echo "  6. Create database and user (see story docs)"
echo "  7. Configure .env file"
echo "  8. Run: composer install --no-dev --optimize-autoloader"
echo "  9. Run: php artisan migrate --force"
echo " 10. Run: php artisan db:seed --class=AdminSeeder --force"
echo " 11. Run: certbot --nginx -d api.travelconnect.app"
echo " 12. Copy deployment/logrotate/travelconnect to /etc/logrotate.d/"
echo " 13. Add backup cron: 0 2 * * * /var/www/travelconnect-api/deployment/backup-db.sh"
echo " 14. Run: deployment/test-production.sh to verify"
