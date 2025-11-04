FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    wget ca-certificates curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Portainer バイナリのダウンロードと展開
ARG PORTAINER_VERSION=2.19.4
RUN wget -O portainer.tar.gz \
    "https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz" \
    && tar -xzf portainer.tar.gz -C /tmp \
    && mv /tmp/portainer /usr/local/bin/ \
    && rm portainer.tar.gz

# データディレクトリの作成
RUN mkdir -p /data

# 初期化スクリプトのコピー
COPY ./tools/portainer_init.sh /portainer_init.sh
RUN chmod +x /portainer_init.sh

EXPOSE 9443

ENTRYPOINT ["/portainer_init.sh"]