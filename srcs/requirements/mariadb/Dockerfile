FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	mariadb-server gosu \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# 必要なディレクトリを作成し、権限を設定
RUN mkdir -p /var/run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql \
    && chmod -R 755 /var/run/mysqld /var/lib/mysql

COPY ./tools/init_db.sh /init_db.sh
COPY ./tools/my-custom-settings.cnf /etc/mysql/mariadb.conf.d/zz-my-custom-settings.cnf
COPY ./tools/init.sql /etc/mysql/init.sql

RUN chmod +x /init_db.sh

EXPOSE 3306

ENTRYPOINT [ "/init_db.sh" ]

CMD ["gosu", "mysql", "mariadbd", "--init-file=/dev/shm/init.sql", "--user=mysql"]