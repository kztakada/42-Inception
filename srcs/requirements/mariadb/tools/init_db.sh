#!/bin/bash

set -e

INIT_SQL_FILE="/etc/mysql/init.sql"

DB_PASSWORD=$(cat /run/secrets/db_password)
export DB_PASSWORD

DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
export DB_ROOT_PASSWORD

echo "INFO: Starting MariaDB initialization script"

if [ -f "$INIT_SQL_FILE" ]; then
        sed \
          -e "s/__PLACEHOLDER_DB__/${DB_DATABASE}/g" \
          -e "s/__PLACEHOLDER_USER__/${DB_USER}/g" \
          -e "s/__PLACEHOLDER_PASSWORD__/${DB_PASSWORD}/g" \
          -e "s/__PLACEHOLDER_ROOT_PASSWORD__/${DB_ROOT_PASSWORD}/g" \
          "$INIT_SQL_FILE" > temp && mv temp "$INIT_SQL_FILE"

        echo "INFO: Successfully executed initialization script"
    else
        echo "WARNING: $INIT_SQL_FILE not found. Skipping custom initialization."
    fi

exec mariadbd --init-file=/etc/mysql/init.sql