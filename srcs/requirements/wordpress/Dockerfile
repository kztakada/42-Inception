FROM debian:bookworm

# PHP 8.4のリポジトリを追加
RUN apt-get update && apt-get install -y \
    wget gnupg2 ca-certificates apt-transport-https \
    && wget -qO /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ bookworm main" > /etc/apt/sources.list.d/php.list \
    && apt-get update

# PHP 8.4の基本パッケージをインストール
RUN apt-get install -y \
	php8.4 php8.4-fpm php8.4-cli php8.4-mysql curl gosu \
	&& apt-get clean 

# PHP 8.4の追加拡張をインストール
RUN apt-get install -y \
	php8.4-mbstring php8.4-xml php8.4-gd php8.4-curl \
	php8.4-zip php8.4-intl php8.4-bcmath php8.4-exif \
	php8.4-redis \
	mariadb-client \
	redis-tools \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*


# 必要なディレクトリを作成し、権限を設定
RUN mkdir -p /var/www/html \
	&& chown -R www-data:www-data /var/www/html

# WP-CLIのインストールと権限設定
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /usr/local/bin/wp \
	&& chown root:root /usr/local/bin/wp

# PHP-FPMの設定ファイルをコピー	
COPY ./conf/www.conf /etc/php/8.4/fpm/pool.d/www.conf

# PHP-FPM用のランタイムディレクトリを作成
RUN mkdir -p /run/php

# カスタムテーマがある場合はここでコピー
# COPY ./themes/ /tmp/themes/

COPY ./tools/init_wp.sh /init_wp.sh
RUN chmod +x /init_wp.sh

EXPOSE 9000

ENTRYPOINT [ "/init_wp.sh" ]

CMD ["gosu", "www-data", "php-fpm8.4", "-F"]