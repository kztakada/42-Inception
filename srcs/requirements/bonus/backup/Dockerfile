FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    cron \
    rsync \
    gzip \
    tar \
    ca-certificates \
    gosu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# backupuser専用グループとユーザーの作成
RUN groupadd -r -g 990 backupuser \
    && useradd -r -u 990 -g backupuser backupuser \
    && mkdir -p /backup/logs \
    && chown -R backupuser:backupuser /backup

# バックアップスクリプトのコピー
COPY tools/backup.sh /usr/local/bin/backup.sh
COPY tools/init_backup.sh /init_backup.sh

RUN chmod +x /usr/local/bin/backup.sh /init_backup.sh

ENTRYPOINT ["/init_backup.sh"]