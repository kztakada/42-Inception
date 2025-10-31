#!/bin/bash

set -e

echo "[+] Starting Redis initialization..."

# rootユーザーでのみ初期化処理を実行
if [ "$(id -u)" = "0" ]; then
    echo "[+] Running initialization as root..."
    
    # Redis認証パスワードを読み込み（rootユーザーで実行）
    if [ -f /run/secrets/redis_password ]; then
        REDIS_PASSWORD=$(cat /run/secrets/redis_password)
        echo "[+] Setting up Redis authentication..."
        
        # 設定ファイルにパスワードを設定
        sed -i "s/# requirepass PLACEHOLDER_PASSWORD/requirepass $REDIS_PASSWORD/" /etc/redis/redis.conf
        
         # セキュリティ設定を正しい形式で追記
        cat >> /etc/redis/redis.conf << EOF

# Security configurations
rename-command DEBUG ""
rename-command SHUTDOWN SHUTDOWN_REDIS
rename-command FLUSHALL ""
EOF
        
        unset REDIS_PASSWORD
    else
        echo "[!] Warning: No Redis password found. Running without authentication."
        sed -i "s/protected-mode yes/protected-mode no/" /etc/redis/redis.conf
    fi
    
    echo "[+] Setting up permissions..."
    chown -R redis:redis /var/lib/redis /var/log/redis /etc/redis
    
    echo "[+] Switching to redis user and starting Redis..."
    # redisユーザーとしてRedisサーバーを直接実行
    exec gosu redis redis-server /etc/redis/redis.conf
fi

# この部分は実行されない（上記でexecしているため）
echo "[+] Redis initialization complete."
exec "$@"