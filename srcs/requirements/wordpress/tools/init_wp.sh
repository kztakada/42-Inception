#!/bin/bash

set -e

chown -R www-data:www-data /var/www/html

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "[+] Starting WordPress setup..."
    # WordPress作業ディレクトリに移動
    cd /var/www/html
    
    # 最新のWordPressをダウンロード
    echo "[+] Downloading latest WordPress..."
    wp core download --path=/var/www/html --locale=ja --version=latest --allow-root
    
    # wp-config.phpを環境変数に基づいて自動生成する
    echo "[+] Creating wp-config.php..."
	DB_USER_PASSWORD=$(cat /run/secrets/db_user_password)
    wp config create \
        --dbname="$DB_DATABASE" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_USER_PASSWORD" \
        --dbhost="$WP_DB_HOST" \
        --allow-root \
        --skip-check || { echo "[!] Config creation failed"; exit 1; }

    # サイト情報と管理者ユーザーを自動設定する
    echo "[+] Installing WordPress core..."
	WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WP_SITE_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root || { echo "[!] Core install failed"; exit 1; }

    # 編集者ロールの一般ユーザーを追加する
    echo "[+] Creating editor user..."
	WP_EDITOR_PASSWORD=$(cat /run/secrets/wp_editor_password)
    wp user create \
        "${WP_EDITOR_USER}" \
        "${WP_EDITOR_EMAIL}" \
        --user_pass="${WP_EDITOR_PASSWORD}" \
        --role=editor \
        --allow-root || { echo "[!] Editor user creation failed"; exit 1; }

    # カスタムテーマがある場合はコピー
    if [ -d "/tmp/themes" ]; then
        echo "[+] Copying custom themes..."
        mkdir -p /var/www/html/wp-content/themes
        cp -r /tmp/themes/* /var/www/html/wp-content/themes/
        chown -R www-data:www-data /var/www/html/wp-content/themes
    fi

    # テーマのインストールと有効化（環境変数で制御）
    if [ -n "$WP_THEME" ]; then
        echo "[+] Installing and activating theme: $WP_THEME"
        # まずカスタムテーマがあるかチェック
        if [ -d "/var/www/html/wp-content/themes/$WP_THEME" ]; then
            echo "[+] Activating custom theme: $WP_THEME"
            wp theme activate "$WP_THEME" --allow-root || { echo "[!] Theme activation failed"; exit 1; }
        else
            echo "[+] Installing theme from repository: $WP_THEME"
            wp theme install "$WP_THEME" --activate --allow-root || { echo "[!] Theme installation failed"; exit 1; }
        fi
    else
        echo "[+] Using default theme"
    fi

    # ここで一応所有権をwww-dataに再設定しておく(NginxやPHP-FPMの実行ユーザーのため)
    echo "[+] Setup complete. Fixing permissions..."
    chown -R www-data:www-data /var/www/html
fi

exec "$@"