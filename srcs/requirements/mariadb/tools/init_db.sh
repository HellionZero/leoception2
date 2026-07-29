#!/bin/sh

set -eu

MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MDB_PASSWORD=$(cat /run/secrets/wp_db_password)
MDB_USER=$(cat /run/secrets/wp_db_user)
MDB_DATABASE=$(cat /run/secrets/wp_db_name)
SOCKET=/run/mysqld/mysqld.sock

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

mariadbd-safe \
    --user=mysql \
    --datadir=/var/lib/mysql \
    --socket=/run/mysqld/mysqld.sock \
    --pid-file=/run/mysqld/mysqld.pid \
    --skip-networking &
pid="$!"

until mariadb-admin --socket=/run/mysqld/mysqld.sock ping --silent; do
    sleep 1
done

mariadb --protocol=socket --socket=/run/mysqld/mysqld.sock -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" --socket=/run/mysqld/mysqld.sock << EOF
CREATE DATABASE IF NOT EXISTS \`${MDB_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MDB_USER}'@'%' IDENTIFIED BY '${MDB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MDB_DATABASE}\`.* TO '${MDB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" --socket=/run/mysqld/mysqld.sock shutdown
wait "$pid"

exec mariadbd-safe --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock

