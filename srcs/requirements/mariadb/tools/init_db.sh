#!/bin/sh

MDB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MDB_PASSWORD=$(cat /run/secrets/wp_db_password) 
MDB_USER=$(cat /run/secrets/wp_db_user) 
MDB_DATABASE=$(cat /run/secrets/wp_db_name)

mariadbd-safe --skip-networking & pid="$!"

echo "preparing mariadb..."

until mariadb-admin ping --silent; do
    sleep 1
done

mariadb -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MDB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

mariadb -u root -p "${MDB_ROOT_PASSWORD}" /etc/mysql/database.sql

mariadb -u root -p "${MDB_ROOT_PASSWORD}" shutdown

wait "$pid"

exec mariadbd-safe

