FROM alpine:3.23

RUN apk update && apk add --no-cache mariadb mariadb-client gettext

RUN mkdir -p /run/mysqld /var/lib/mysql 
RUN chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/my.cnf /etc/mysql/my.cnf
RUN chmod 644 /etc/mysql/my.cnf \
	&& chown mysql:mysql /etc/mysql/my.cnf

COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

EXPOSE 3306

ENTRYPOINT ["/init_db.sh"]