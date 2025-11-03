#!/bin/bash

set -e

echo "[+] Starting Redis initialization..."


    
# Redis認証パスワードを読み込み（rootユーザーで実行）
if [ -f /run/secrets/redis_password ]; then
    REDIS_PASSWORD=$(cat /run/secrets/redis_password)
    echo "[+] Setting up Redis authentication..."
        
    # 設定ファイルにパスワードを設定
    sed -i "s/# requirepass PLACEHOLDER_PASSWORD/requirepass $REDIS_PASSWORD/" /etc/redis/redis.conf
        
    unset REDIS_PASSWORD
else
    echo "[!] Warning: No Redis password found. Running without authentication."
    sed -i "s/protected-mode yes/protected-mode no/" /etc/redis/redis.conf
fi
    
echo "[+] Setting up permissions..."
chown -R redis:redis /var/lib/redis /var/log/redis /etc/redis

echo "[+] Redis initialization complete."    
echo "[+] Switching to redis user and starting Redis..."

exec "$@"