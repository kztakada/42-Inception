FROM debian:bullseye

RUN apt-get update && apt-get install -y \
	mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld

COPY ./tools/init_db.sh /init_db.sh
COPY ./tools/my-custom-settings.cnf /etc/mysql/mariadb.conf.d/zz-my-custom-settings.cnf
COPY ./tools/init.sql /etc/mysql/init.sql

RUN chmod +x /init_db.sh

ENTRYPOINT [ "/init_db.sh" ]

CMD ["mariadbd", "--init-file=/dev/shm/init.sql", "--user=mysql"]