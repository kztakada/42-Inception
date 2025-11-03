#!/bin/bash

set -e

# 設定
BACKUP_ROOT="/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${BACKUP_ROOT}/logs/backup_${TIMESTAMP}.log"

# ログ関数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# バックアップ保持期間（日数）
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-7}

log "========== Backup Started =========="

# 1. MariaDB のバックアップ
if [ -d "/source/db" ]; then
    log "Backing up MariaDB data..."
    DB_BACKUP_DIR="${BACKUP_ROOT}/db"
    mkdir -p "$DB_BACKUP_DIR"
    
    tar -czf "${DB_BACKUP_DIR}/db_${TIMESTAMP}.tar.gz" \
        -C /source db/ 2>> "$LOG_FILE"
    
    log "MariaDB backup completed: db_${TIMESTAMP}.tar.gz"
fi

# 2. WordPress のバックアップ
if [ -d "/source/wordpress" ]; then
    log "Backing up WordPress files..."
    WP_BACKUP_DIR="${BACKUP_ROOT}/wordpress"
    mkdir -p "$WP_BACKUP_DIR"
    
    tar -czf "${WP_BACKUP_DIR}/wordpress_${TIMESTAMP}.tar.gz" \
        -C /source wordpress/ 2>> "$LOG_FILE"
    
    log "WordPress backup completed: wordpress_${TIMESTAMP}.tar.gz"
fi


# 3. 古いバックアップの削除
log "Cleaning up old backups (older than ${RETENTION_DAYS} days)..."
find "$BACKUP_ROOT" -name "*.tar.gz" -type f -mtime +${RETENTION_DAYS} -delete 2>> "$LOG_FILE"
find "$BACKUP_ROOT/logs" -name "*.log" -type f -mtime +${RETENTION_DAYS} -delete 2>> "$LOG_FILE"

# バックアップサイズの計算
TOTAL_SIZE=$(du -sh "$BACKUP_ROOT" | cut -f1)
log "Total backup size: $TOTAL_SIZE"

log "========== Backup Completed =========="

# バックアップ結果のサマリー
log "Backup files created:"
find "$BACKUP_ROOT" -name "*_${TIMESTAMP}.tar.gz" -type f -exec ls -lh {} \; | tee -a "$LOG_FILE"