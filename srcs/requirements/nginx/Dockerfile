FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	nginx openssl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY ./tools/init_nginx.sh /etc/nginx/init_nginx.sh

COPY ./tools/nginx.conf /etc/nginx/conf.d/default.conf

RUN chmod +x /etc/nginx/init_nginx.sh

EXPOSE 443

ENTRYPOINT [ "/etc/nginx/init_nginx.sh" ]

CMD ["nginx", "-g", "daemon off;"]