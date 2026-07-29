FROM alpine:3.23

RUN apk update && apk add --no-cache \
	curl \
	php-fpm \
	php-mysqli \
	php-json \
	php-curl \
	php-opcache \
	php-xml \
	php-phar \
	php-zip \
	php-session 

RUN mkdir -p /run/php

RUN curl -O https://wordpress.org/latest.tar.gz && \
	tar -xzf latest.tar.gz && \
	mv wordpress /var/www/html && \
	rm latest.tar.gz



