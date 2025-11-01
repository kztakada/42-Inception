#!/bin/bash
set -e

echo "[+] Starting vsftpd initialization..."

# ROOT_PATHのデフォルト値設定
ROOT_PATH=${ROOT_PATH:-/var/www/html}

# 初期化完了フラグ（永続化される場所に配置）
INIT_FLAG="/etc/vsftpd/.initialized"

if [ ! -f "$INIT_FLAG" ]; then
    echo "[+] First time initialization..."
    
    if [ -f /run/secrets/vsftpd_password ]; then
        FTP_PASSWORD=$(cat /run/secrets/vsftpd_password)

        # ルートディレクトリが存在することを確認
        mkdir -p "${ROOT_PATH}"

        # FTPユーザーの作成
        if ! id -u "${FTP_USER}" > /dev/null 2>&1; then
            echo "Creating FTP user: ${FTP_USER}"
            echo "Home directory: ${ROOT_PATH}"
            adduser --home "${ROOT_PATH}" --disabled-password --gecos "" "${FTP_USER}"
            echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
        else
            echo "[+] FTP user ${FTP_USER} already exists"
            echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
        fi

        # ユーザーリストファイルに追加
        echo "${FTP_USER}" > /etc/vsftpd.userlist

        # www-dataグループに追加（WordPressとの互換性のため）
        if getent group www-data > /dev/null 2>&1; then
            usermod -aG www-data "${FTP_USER}"
            echo "[+] Added ${FTP_USER} to www-data group"
        fi

        unset FTP_PASSWORD
    else
        echo "[!] Error: No vsftpd password found."
        exit 1
    fi

    # vsftpd用ディレクトリの作成
    mkdir -p /var/run/vsftpd/empty
    mkdir -p /var/log/vsftpd
    
    # WordPressディレクトリの権限設定
    echo "[+] Setting permissions for ${ROOT_PATH} ..."
    chown -R www-data:www-data "${ROOT_PATH}"
    chmod -R 775 "${ROOT_PATH}"

    # FTPユーザーのホームディレクトリの書き込み権限を確保
    if [ -d "${ROOT_PATH}/wp-content" ]; then
        chmod -R g+w "${ROOT_PATH}/wp-content"
    fi
    
    # 初期化完了フラグを作成
    mkdir -p /etc/vsftpd
    touch "$INIT_FLAG"
    
    echo "[+] Initial setup complete."
else
    echo "[+] Already initialized, skipping initialization..."
fi

echo "[+] vsftpd initialization complete."
echo "[+] FTP user will access: ${ROOT_PATH}"
echo "[+] Starting vsftpd in foreground mode..."

# vsftpdをフォアグラウンドで実行
exec "$@"