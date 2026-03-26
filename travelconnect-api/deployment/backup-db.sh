#!/bin/bash
# TravelConnect API - Database Backup Script
# Usage: ./deployment/backup-db.sh
# Cron: 0 2 * * * /var/www/travelconnect-api/deployment/backup-db.sh
#
# Required environment variables (set in crontab or source from .env):
#   DB_USERNAME, DB_PASSWORD, DB_DATABASE

set -e

# Configuration
BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Load database credentials from Laravel .env if not set
if [ -z "$DB_DATABASE" ]; then
    APP_DIR="/var/www/travelconnect-api"
    DB_DATABASE=$(grep ^DB_DATABASE "$APP_DIR/.env" | cut -d '=' -f2)
    DB_USERNAME=$(grep ^DB_USERNAME "$APP_DIR/.env" | cut -d '=' -f2)
    DB_PASSWORD=$(grep ^DB_PASSWORD "$APP_DIR/.env" | cut -d '=' -f2)
    DB_HOST=$(grep ^DB_HOST "$APP_DIR/.env" | cut -d '=' -f2)
fi

DB_HOST=${DB_HOST:-127.0.0.1}

echo "Starting database backup..."
echo "Database: $DB_DATABASE"
echo "Date: $DATE"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create backup
BACKUP_FILE="$BACKUP_DIR/backup_${DB_DATABASE}_${DATE}.sql.gz"
mysqldump -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" \
    --single-transaction \
    --routines \
    --triggers \
    "$DB_DATABASE" | gzip > "$BACKUP_FILE"

# Verify backup
if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "Backup created: $BACKUP_FILE ($SIZE)"
else
    echo "ERROR: Backup failed or empty!"
    exit 1
fi

# Remove old backups
echo "Removing backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete

# List current backups
echo ""
echo "Current backups:"
ls -lh "$BACKUP_DIR"/backup_*.sql.gz 2>/dev/null || echo "No backups found"

echo ""
echo "Backup completed successfully."
