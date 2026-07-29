FROM alpine:3.23

RUN apk update && apk add --no-cache curl php php-mysqli

RUN mkdir -p /run/phpmyadmin

RUN curl -O https://files.phpmyadmin.net/phpMyAdmin/5.2.0/phpMyAdmin-5.2.0-all-languages.tar.gz && \
	tar -xzf phpMyAdmin-5.2.0-all-languages.tar.gz && \
	mv phpMyAdmin-5.2.0-all-languages /run/phpmyadmin && \
	chmod -R 755 /run/phpmyadmin && \
	chown -R user:group /run/phpmyadmin && \
	rm phpMyAdmin-5.2.0-all-languages.tar.gz

EXPOSE 8080

ENTRYPOINT ["/tools/init_phpmyadmin.sh"]

