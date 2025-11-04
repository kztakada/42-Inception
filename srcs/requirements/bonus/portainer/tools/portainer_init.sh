#!/bin/bash

set -e

echo "[+] Starting Portainer initialization..."

# Portainerデータディレクトリの作成
mkdir -p /data

# 初期化完了フラグ
INIT_FLAG="/data/.initialized"

# 初回セットアップ（管理者アカウントが未作成の場合のみ）
if [ ! -f "$INIT_FLAG" ]; then
    echo "[+] Running initial setup..."
    
    # Portainerをバックグラウンドで起動（HTTPを無効化してHTTPSのみ）
    echo "[+] Starting Portainer in background for initialization..."
    /usr/local/bin/portainer/portainer \
        --bind=:9443 \
        --tunnel-port=8000 \
        --data=/data &
    PORTAINER_PID=$!

    # Portainerの起動を待つ（少し長めに待つ）
    echo "[+] Waiting for Portainer to start..."
    sleep 5
    
    for i in {1..30}; do
        if curl -k -s https://localhost:9443/api/status > /dev/null 2>&1; then
            echo "[+] Portainer is ready!"
            break
        fi
        if [ $i -eq 30 ]; then
            echo "[!] Portainer failed to start"
            kill $PORTAINER_PID 2>/dev/null || true
            exit 1
        fi
        echo "[+] Waiting... ($i/30)"
        sleep 2
    done
    
    # パスワードファイルから読み込み
    if [ -f /run/secrets/portainer_password ]; then
        PORTAINER_PASSWORD=$(cat /run/secrets/portainer_password)
    else
        echo "[!] Error: No portainer password found."
        kill $PORTAINER_PID 2>/dev/null || true
        exit 1
    fi

    # 管理者アカウントの作成
    echo "[+] Creating admin account..."
    sleep 2  # APIが完全に起動するまで待つ
    RESPONSE=$(curl -k -s -X POST https://localhost:9443/api/users/admin/init \
        -H "Content-Type: application/json" \
        -d "{\"Username\":\"${PORTAINER_ADMIN_USER:-admin}\",\"Password\":\"${PORTAINER_PASSWORD}\"}")
    
    if echo "$RESPONSE" | grep -q "Id"; then
        echo "[+] Admin account created successfully!"
    elif echo "$RESPONSE" | grep -q "Admin"; then
        echo "[+] Admin account already exists, skipping..."
    else
        echo "[!] Failed to create admin account. Response: $RESPONSE"
    fi
    
    unset PORTAINER_PASSWORD
    
    # バックグラウンドプロセスを停止
    echo "[+] Stopping background Portainer process..."
    kill $PORTAINER_PID
    wait $PORTAINER_PID 2>/dev/null || true
    
    # データベースのロックが解除されるまで待つ
    sleep 3
    
    # 初期化完了フラグを作成
    touch "$INIT_FLAG"
    echo "[+] Initial setup completed."
else
    echo "[+] Portainer already initialized, skipping setup..."
fi

echo "[+] Starting Portainer in foreground mode..."

# 本番モードでPortainerを起動（フォアグラウンド、HTTPSのみ）
exec /usr/local/bin/portainer/portainer \
    --bind=:9443 \
    --tunnel-port=8000 \
    --data=/data