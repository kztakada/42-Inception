FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    cron \
    gzip \
    tar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# バックアップスクリプトのコピー
COPY tools/backup.sh /usr/local/bin/backup.sh
COPY tools/init_backup.sh /init_backup.sh

RUN chmod +x /usr/local/bin/backup.sh /init_backup.sh

# バックアップディレクトリの作成
RUN mkdir -p /backup/logs

ENTRYPOINT ["/init_backup.sh"]

CMD ["cron", "-f"]