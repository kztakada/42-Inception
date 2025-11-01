FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    wget ca-certificates dbus \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/local/bin/cadvisor \
    https://github.com/google/cadvisor/releases/download/v0.47.2/cadvisor-v0.47.2-linux-amd64 \
    && chmod +x /usr/local/bin/cadvisor

# machine-idを生成してエラーを回避
RUN dbus-uuidgen > /etc/machine-id

EXPOSE 8080

CMD ["/usr/local/bin/cadvisor", "-logtostderr", "-port=8080"]