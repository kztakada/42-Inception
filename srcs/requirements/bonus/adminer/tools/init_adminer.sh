#!/bin/bash

set -e

echo "[+] Starting Adminer initialization..."

# PHP-FPMログファイルの権限を設定
echo "[+] Setting up PHP-FPM log permissions..."
touch /var/log/php8.4-fpm.log
chown www-data:www-data /var/log/php8.4-fpm.log
chmod 644 /var/log/php8.4-fpm.log

# /run/phpディレクトリの権限設定
chown -R www-data:www-data /run/php

# Adminerディレクトリの権限設定
chown -R www-data:www-data /var/www/adminer

echo "[+] Adminer initialization complete."
echo "[+] Switching to www-data user and starting PHP-FPM on port 9001..."

exec "$@"