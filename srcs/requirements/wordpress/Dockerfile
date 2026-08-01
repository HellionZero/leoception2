FROM alpine:3.23

RUN apk update && apk add --no-cache \
	php-fpm \
	php-iconv \
	php-mbstring \
	php-tokenizer \
	php-mysqli \
	php-json \
	php-curl \
	php-opcache \
	php-xml \
	php-phar \
	php-zip \
	php-session \
	mariadb-client \
	wget 
RUN mkdir -p /run/php

RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x /usr/local/bin/wp

COPY ./tools/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_wp.sh

WORKDIR /var/www/html

EXPOSE 5050

ENTRYPOINT ["/usr/local/bin/init_wp.sh"]