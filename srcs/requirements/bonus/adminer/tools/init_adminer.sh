#!/bin/bash

set -e

echo "[+] Starting Adminer initialization..."

chown -R www-data:www-data /var/www/adminer

echo "[+] Adminer initialization complete."
echo "[+] PHP-FPM listening on port 9001"

exec "$@"