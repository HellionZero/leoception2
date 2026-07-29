FROM alpine:3.23

RUN apk add update && apk add --no-cache mariadb mariadb-client gettext

RUN mkdir -p /run/mysqld /var/lib/mysql\
	&& chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/mdb.cnf /etc/my.cnf
RUN chmod 644 /etc/my.cnf \
	&& chown mysql:mysql /etc/my.cnf

COPY tools/database.sql /database.sql
RUN chmod 644 /database.sql \
	&& chown mysql:mysql /database.sql

COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

EXPOSE 3306

ENTRYPOINT ["/init_db.sh"]