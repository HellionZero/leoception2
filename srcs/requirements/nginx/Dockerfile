FROM alpine:3.23

RUN apk update && apk add --no-cache nginx openssl

RUN mkdir -p /run/nginx

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_nginx.sh

EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/init_nginx.sh"]



