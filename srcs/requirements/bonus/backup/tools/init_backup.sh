#!/bin/bash

set -e

echo "[+] Starting backup service initialization..."

# Cronジョブの設定（デフォルト: 毎日午前3時）
BACKUP_SCHEDULE=${BACKUP_SCHEDULE:-"0 3 * * *"}

echo "[+] Setting up cron job with schedule: $BACKUP_SCHEDULE"

# バックアップディレクトリの作成と権限設定（rootユーザーで実行）
mkdir -p /backup/{db,wordpress,logs}
chown -R backupuser:backupuser /backup
chmod -R 755 /backup

# cronファイルを作成（rootユーザーで実行）
echo "$BACKUP_SCHEDULE gosu backupuser /usr/local/bin/backup.sh" > /etc/cron.d/backup-cron
chmod 0644 /etc/cron.d/backup-cron

# rootのcrontabに登録
crontab /etc/cron.d/backup-cron

echo "[+] Backup service initialized successfully"
echo "[+] Schedule: $BACKUP_SCHEDULE"
echo "[+] Retention: ${BACKUP_RETENTION_DAYS:-7} days"

# 初回バックアップを実行（オプション）
if [ "${RUN_INITIAL_BACKUP}" = "true" ]; then
    echo "[+] Running initial backup as backupuser..."
    gosu backupuser /usr/local/bin/backup.sh &
    BACKUP_PID=$!
    echo "[+] Initial backup started in background (PID: $BACKUP_PID)"
fi

echo "[+] Starting cron daemon as root..."
echo "[+] Backup scripts will run as: backupuser (UID: $(id -u backupuser))"

# cronデーモンをrootユーザーで起動（CMDは使用しない）
exec cron -f