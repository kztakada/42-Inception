FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	redis-server gosu \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Redis設定ファイルをコピー
COPY ./tools/redis.conf /etc/redis/redis.conf

# 初期化スクリプトをコピー
COPY ./tools/init_redis.sh /init_redis.sh
RUN chmod +x /init_redis.sh

# Redisユーザーでディレクトリの所有権を設定
RUN mkdir -p /var/lib/redis /var/log/redis \
    && chown -R redis:redis /var/lib/redis /var/log/redis

EXPOSE 6379

ENTRYPOINT ["/init_redis.sh"]

CMD ["redis-server", "/etc/redis/redis.conf"]