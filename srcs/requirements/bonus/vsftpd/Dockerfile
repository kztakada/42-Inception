FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    vsftpd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/init_vsftpd.sh /init_vsftpd.sh
RUN chmod +x /init_vsftpd.sh

# vsftpd用ディレクトリの作成
RUN mkdir -p /var/run/vsftpd/empty /etc/vsftpd /var/log/vsftpd

EXPOSE 21 21000-21010

ENTRYPOINT ["/init_vsftpd.sh"]

CMD ["/usr/sbin/vsftpd", "/etc/vsftpd.conf"]