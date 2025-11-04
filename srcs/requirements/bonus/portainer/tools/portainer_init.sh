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
    
    # Portainerをバックグラウンドで起動
    echo "[+] Starting Portainer in background for initialization..."
    /usr/local/bin/portainer/portainer \
        --bind=:9443 \
        --tunnel-port=8000 \
        --data=/data > /tmp/portainer.log 2>&1 &
    PORTAINER_PID=$!

    # Portainerの起動を待つ
    echo "[+] Waiting for Portainer to start..."
    for i in {1..30}; do
        # プロセスが生きているか確認
        if ! kill -0 $PORTAINER_PID 2>/dev/null; then
            echo "[!] Portainer process died unexpectedly"
            cat /tmp/portainer.log
            exit 1
        fi
        
        if curl -k -s https://localhost:9443/api/status > /dev/null 2>&1; then
            echo "[+] Portainer is ready!"
            break
        fi
        
        if [ $i -eq 30 ]; then
            echo "[!] Portainer failed to start"
            cat /tmp/portainer.log
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
    
    # バックグラウンドプロセスを確実に停止
    echo "[+] Stopping background Portainer process..."
    if kill -0 $PORTAINER_PID 2>/dev/null; then
        kill -TERM $PORTAINER_PID
        
        # プロセスが終了するまで待つ
        for i in {1..10}; do
            if ! kill -0 $PORTAINER_PID 2>/dev/null; then
                echo "[+] Portainer process stopped successfully"
                break
            fi
            if [ $i -eq 10 ]; then
                echo "[!] Force killing Portainer process"
                kill -KILL $PORTAINER_PID 2>/dev/null || true
            fi
            sleep 1
        done
    fi
    
    wait $PORTAINER_PID 2>/dev/null || true
    
    # データベースのロックが完全に解除されるまで待つ
    echo "[+] Waiting for database lock to be released..."
    sleep 5
    
    # 初期化完了フラグを作成
    touch "$INIT_FLAG"
    echo "[+] Initial setup completed."
else
    echo "[+] Portainer already initialized, skipping setup..."
fi

echo "[+] Starting Portainer in foreground mode..."

# 本番モードでPortainerを起動（フォアグラウンド）
exec /usr/local/bin/portainer/portainer \
    --bind=:9443 \
    --tunnel-port=8000 \
    --data=/data