#!/bin/bash

#!/bin/sh
set -eu

: "${MDB_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD is required}"
: "${MDB_DATABASE:?MDB_DATABASE is required}"
: "${MDB_USER:?MDB_USER is required}"
: "${MDB_PASSWORD:?MDB_PASSWORD is required}"

if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null
else
    echo "MariaDB data directory already exists, skipping initialization"
fi

chown -R mysql:mysql /run/mysqld /var/lib/mysql 

mariadbd --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock --bind-address=127.0.0.1 --skip-networking --pid-file=/run/mysqld/mysqld.pid &

until mariadb-admin --protocol=socket --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    sleep 1
done

envsubst < /tools/database.sql > /tmp/database.sql

if mariadb --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot -p"$MDB_ROOT_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; then
    mariadb --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot -p"$MDB_ROOT_PASSWORD" < /tmp/database.sql
else
    mariadb --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot < /tmp/database.sql
fi

mariadb-admin --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot -p"$MDB_ROOT_PASSWORD" shutdown

echo "MariaDB data directory initialized"

exec mariadbd --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock --bind-address=0.0.0.

