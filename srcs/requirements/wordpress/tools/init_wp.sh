#!/bin/bash

set -e

chown -R www-data:www-data /var/www/html

# Redis接続テスト関数
test_redis_connection() {
    local redis_password=""
    if [ -f /run/secrets/redis_password ]; then
        redis_password=$(cat /run/secrets/redis_password)
    fi
    
    echo "[+] Testing Redis connection..."
    for i in {1..10}; do
        if [ -n "$redis_password" ]; then
            if redis-cli -h redis -p 6379 -a "$redis_password" ping >/dev/null 2>&1; then
                echo "[+] Redis connection successful!"
                return 0
            fi
        else
            if redis-cli -h redis -p 6379 ping >/dev/null 2>&1; then
                echo "[+] Redis connection successful!"
                return 0
            fi
        fi
        echo "[+] Redis connection attempt $i/10 failed, retrying in 2 seconds..."
        sleep 2
    done
    echo "[!] Redis connection failed after 10 attempts"
    return 1
}

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

    # サイト情報と管理者ユーザーを自動設定する（データベーステーブル作成）
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

    # Redis接続テスト
    if test_redis_connection; then
        # Redis キャッシュ設定を wp-config.php に追加（wp-settings.phpの前に挿入）
        echo "[+] Configuring Redis cache..."
        REDIS_PASSWORD=$(cat /run/secrets/redis_password)
        
        # wp-settings.phpをrequireする行の前に Redis設定を挿入
        sed -i "/require_once.*wp-settings.php/i\\
\\
/* Redis Cache Configuration */\\
define('WP_REDIS_HOST', 'redis');\\
define('WP_REDIS_PORT', 6379);\\
define('WP_REDIS_PASSWORD', '$REDIS_PASSWORD');\\
define('WP_REDIS_TIMEOUT', 5);\\
define('WP_REDIS_READ_TIMEOUT', 5);\\
define('WP_REDIS_DATABASE', 0);\\
define('WP_REDIS_DISABLE_BANNERS', true);\\
" /var/www/html/wp-config.php
        unset REDIS_PASSWORD

        # WordPressインストール後にRedis Object Cache プラグインをインストール
        echo "[+] Installing Redis Object Cache plugin..."
        if wp plugin install redis-cache --activate --allow-root; then
            echo "[+] Redis plugin installed successfully"
            
            # Redis オブジェクトキャッシュを有効化
            echo "[+] Enabling Redis object cache..."
            wp redis enable --allow-root || echo "[!] Redis cache enable failed, but continuing..."
        else
            echo "[!] Redis plugin installation failed, but continuing..."
        fi
    else
        echo "[!] Redis connection failed, skipping Redis configuration"
    fi

    # 編集者ロールの一般ユーザーを追加する
    echo "[+] Creating editor user..."
    WP_EDITOR_PASSWORD=$(cat /run/secrets/wp_editor_password)
    wp user create \
        "${WP_EDITOR_USER}" \
        "${WP_EDITOR_EMAIL}" \
        --user_pass="${WP_EDITOR_PASSWORD}" \
        --role=editor \
        --allow-root || { echo "[!] Editor user creation failed"; exit 1; }

    # テーマのインストールと有効化（環境変数で制御）
    if [ -n "$WP_THEME" ]; then
        echo "[+] Installing and activating theme: $WP_THEME"
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

    # ここで一応所有権をwww-dataに再設定しておく
    echo "[+] Setup complete. Fixing permissions..."
    chown -R www-data:www-data /var/www/html

    echo "[+] WordPress installation completed successfully!"
else
    echo "[+] WordPress already configured, skipping setup."
fi

exec "$@"