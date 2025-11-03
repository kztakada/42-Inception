FROM debian:bookworm

# Node.jsのインストール
RUN apt-get update && apt-get install -y \
    curl ca-certificates gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリの作成
WORKDIR /app

# TypeScriptプロジェクトのセットアップ
COPY ./tools/static_website /app

# TypeScriptと必要な型定義のインストール
RUN npm install typescript @types/node

# 出力ディレクトリの作成
RUN mkdir -p /app/dist

# ビルドスクリプトのコピーと実行権限付与
COPY ./tools/init_node.sh /init_node.sh
RUN chmod +x /init_node.sh

ENTRYPOINT ["/init_node.sh"]