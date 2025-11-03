#!/bin/bash

set -e

echo "[+] Starting TypeScript compilation..."

cd /app

# TypeScriptのコンパイル
npx tsc generatePage.ts --target ES2020 --module commonjs --esModuleInterop --moduleResolution node

echo "[+] TypeScript compilation completed."
echo "[+] Running page generator..."

# 生成スクリプトの実行
node generatePage.js

echo "[+] Static site generation completed."
echo "[+] Contents of dist directory:"
ls -la /app/dist/

# distディレクトリの権限設定
chmod -R 755 /app/dist

echo "[+] Build process finished successfully."

exec "$@"