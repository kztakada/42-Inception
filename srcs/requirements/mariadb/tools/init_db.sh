#!/bin/bash

set -e

if [ "$1" = 'mariadbd' ]; then

  INIT_SQL_BASE_FILE="/etc/mysql/init.sql"
  INIT_SQL_FILE="/dev/shm/init.sql"

  DB_USER_PASSWORD=$(cat /run/secrets/db_user_password)

  DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

  echo "INFO: Starting MariaDB initialization script"

  if [ -f "$INIT_SQL_BASE_FILE" ]; then
          sed \
            -e "s|__PLACEHOLDER_DB__|${DB_DATABASE}|g" \
            -e "s|__PLACEHOLDER_USER__|${DB_USER}|g" \
            -e "s|__PLACEHOLDER_PASSWORD__|${DB_USER_PASSWORD}|g" \
            -e "s|__PLACEHOLDER_ROOT_PASSWORD__|${DB_ROOT_PASSWORD}|g" \
            "$INIT_SQL_BASE_FILE" > temp && mv temp "$INIT_SQL_FILE"

          chmod 600 "$INIT_SQL_FILE"
          chown mysql:mysql "$INIT_SQL_FILE"
          echo "INFO: Successfully executed initialization script"
      else
          echo "WARNING: $INIT_SQL_FILE not found. Skipping custom initialization."
  fi
fi

exec "$@"