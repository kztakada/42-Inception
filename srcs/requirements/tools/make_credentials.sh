#!/bin/bash

set -e

# SCRIPT_DIR_RELATIVE=$(dirname "$0")
SECRETS_DIR=./secrets

if [ ! -d "$SECRETS_DIR" ]; then
    mkdir -p "$SECRETS_DIR"
    chmod 700 "$SECRETS_DIR"
fi

if [ ! -f "$SECRETS_DIR/inception.key" ] || [ ! -f "$SECRETS_DIR/inception.crt" ]; then
    openssl genrsa -out "$SECRETS_DIR/inception.key" 2048
    openssl req -new -key "$SECRETS_DIR/inception.key" -out "$SECRETS_DIR/inception.csr" -subj "/C=JP/ST=Tokyo/L=Shinjuku/O=42Tokyo/CN=katakada.42.fr"
    openssl x509 -req -days 365 -in "$SECRETS_DIR/inception.csr" -signkey "$SECRETS_DIR/inception.key" -out "$SECRETS_DIR/inception.crt"
    chmod 600 "$SECRETS_DIR/inception.key" "$SECRETS_DIR/inception.crt"
fi

generate_password_file() {
    local file_path="$1"
    
    if [ ! -f "$file_path" ]; then
        local password=$(openssl rand -base64 12)
        echo "$password" > "$file_path"
        chmod 600 "$file_path"
        unset password
        echo "Generated: $(basename "$file_path")"
    else
        echo "Already exists: $(basename "$file_path")"
    fi
}

generate_password_file "$SECRETS_DIR/db_root_password.txt"
generate_password_file "$SECRETS_DIR/db_user_password.txt"
generate_password_file "$SECRETS_DIR/wp_admin_password.txt"
generate_password_file "$SECRETS_DIR/wp_editor_password.txt"
generate_password_file "$SECRETS_DIR/redis_password.txt"
