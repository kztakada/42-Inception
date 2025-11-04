#!/bin/bash

set -e

if [ "$1" = 'gosu' ]; then

  INIT_SQL_BASE_FILE="/etc/mysql/init.sql"
  INIT_SQL_FILE="/dev/shm/init.sql"

  echo "INFO: Starting MariaDB initialization script"

  # データディレクトリの権限を確実に設定
  echo "INFO: Setting permissions for /var/lib/mysql"
  chown -R mysql:mysql /var/lib/mysql
  chmod -R 755 /var/lib/mysql

  # /var/run/mysqldの権限も確認
  chown -R mysql:mysql /var/run/mysqld
  chmod -R 755 /var/run/mysqld

  # rootユーザーとしてsecretsを読み取る
  DB_USER_PASSWORD=$(cat /run/secrets/db_user_password)
  DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

  if [ -f "$INIT_SQL_BASE_FILE" ]; then
          # rootユーザーとしてファイルを作成
          sed \
            -e "s|__PLACEHOLDER_DB__|${DB_DATABASE}|g" \
            -e "s|__PLACEHOLDER_USER__|${DB_USER}|g" \
            -e "s|__PLACEHOLDER_PASSWORD__|${DB_USER_PASSWORD}|g" \
            -e "s|__PLACEHOLDER_ROOT_PASSWORD__|${DB_ROOT_PASSWORD}|g" \
            "$INIT_SQL_BASE_FILE" > "$INIT_SQL_FILE"

          # mysqlユーザーが読み取れるように権限設定
          chmod 644 "$INIT_SQL_FILE"
          chown mysql:mysql "$INIT_SQL_FILE"
          echo "INFO: Successfully created initialization SQL file"
  else
          echo "WARNING: $INIT_SQL_BASE_FILE not found. Skipping custom initialization."
  fi
  
  # パスワードを環境変数から削除
  unset DB_USER_PASSWORD
  unset DB_ROOT_PASSWORD
  
  echo "INFO: Initialization complete. Starting MariaDB as mysql user..."
fi

exec "$@"