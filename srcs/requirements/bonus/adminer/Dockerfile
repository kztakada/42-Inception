FROM debian:bookworm

# PHP 8.4のリポジトリを追加
RUN apt-get update && apt-get install -y \
    wget gnupg2 lsb-release ca-certificates apt-transport-https \
    && wget -qO /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ bookworm main" > /etc/apt/sources.list.d/php.list \
    && apt-get update

# PHP-FPMとMySQL拡張、gosuをインストール
RUN apt-get install -y \
    php8.4-fpm php8.4-cli php8.4-mysql php8.4-mbstring php8.4-xml gosu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Adminerのダウンロード
RUN mkdir -p /var/www/adminer \
    && wget -O /var/www/adminer/index.php \
    https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php \
    && chown -R www-data:www-data /var/www/adminer

# PHP-FPMの設定
COPY ./conf/adminer.conf /etc/php/8.4/fpm/pool.d/adminer.conf
RUN mkdir -p /run/php

COPY ./tools/init_adminer.sh /init_adminer.sh
RUN chmod +x /init_adminer.sh

EXPOSE 9001

ENTRYPOINT ["/init_adminer.sh"]

CMD ["gosu", "www-data", "php-fpm8.4", "-F"]