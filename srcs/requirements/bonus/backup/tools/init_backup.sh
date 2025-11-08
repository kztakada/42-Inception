#!/bin/bash

set -e

echo "[+] Starting backup service initialization..."

# Cronジョブの設定（デフォルト: 毎日午前3時）
BACKUP_SCHEDULE=${BACKUP_SCHEDULE:-"0 3 * * *"}

echo "[+] Setting up cron job with schedule: $BACKUP_SCHEDULE"
echo "$BACKUP_SCHEDULE /usr/local/bin/backup.sh" > /etc/cron.d/backup-cron

# 権限設定
chmod 0644 /etc/cron.d/backup-cron
crontab /etc/cron.d/backup-cron

# バックアップディレクトリの作成と権限設定
mkdir -p /backup/{db,wordpress,logs}
chmod -R 755 /backup

echo "[+] Backup service initialized successfully"
echo "[+] Schedule: $BACKUP_SCHEDULE"
echo "[+] Retention: ${BACKUP_RETENTION_DAYS:-7} days"

# 初回バックアップを実行（オプション）
if [ "${RUN_INITIAL_BACKUP}" = "true" ]; then
    echo "[+] Running initial backup..."
    /usr/local/bin/backup.sh
fi

echo "[+] Starting cron daemon..."

exec "$@"