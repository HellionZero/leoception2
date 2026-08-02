#!/bin/sh

set -eu
echo "Initializing the database..."

### set up the database and users based on the secrets provided by docker swarm.
echo "Setting up the database and users..."
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MDB_HEALTH_USER=$(cat /run/secrets/db_health_user)
MDB_HEALTH_PASSWORD=$(cat /run/secrets/db_health_password)
MDB_PASSWORD=$(cat /run/secrets/wp_db_password)
MDB_USER=$(cat /run/secrets/wp_db_user)
MDB_DATABASE=$(cat /run/secrets/wp_db_name)

### set up the MariaDB service, needed for the initial database setup
SOCKET=/run/mysqld/mysqld.sock

### create the mysql user and group if they don't exist
if ! id -u mysql >/dev/null 2>&1; then
	groupadd -r mysql
	useradd -r -g mysql -s /bin/false mysql
fi

### create the necessary directories and set permissions
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

### important: if the database has not been initialized, we need to initialize it and set up the users and permissions.
### we will start the mariadb service in the background, wait for it to be ready, 
### and then execute the necessary SQL commands to set up the database and users.

echo "Checking if the database has been initialized..."

if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
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

### set up the root user password and flush privileges to ensure the changes take effect.

    mariadb --protocol=socket --socket=/run/mysqld/mysqld.sock -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

echo "Root user password has been set up successfully."

### create the database and users, and grant the necessary privileges.
### in this fase we need to create the health user and grant it privileges to the database to 
### ensure that the application can monitor the health of the database.
### we will also create the application user and grant it privileges to the 
### database to ensure that the application can access the database.

    mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" --socket=/run/mysqld/mysqld.sock << EOF
CREATE DATABASE IF NOT EXISTS \`${MDB_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MDB_USER}'@'%' IDENTIFIED BY '${MDB_PASSWORD}';
CREATE USER IF NOT EXISTS '${MDB_HEALTH_USER}'@'%' IDENTIFIED BY '${MDB_HEALTH_PASSWORD}';
    CREATE USER IF NOT EXISTS '${MDB_HEALTH_USER}'@'localhost' IDENTIFIED BY '${MDB_HEALTH_PASSWORD}';
    ALTER USER '${MDB_USER}'@'%' IDENTIFIED BY '${MDB_PASSWORD}';
    ALTER USER '${MDB_HEALTH_USER}'@'%' IDENTIFIED BY '${MDB_HEALTH_PASSWORD}';
    ALTER USER '${MDB_HEALTH_USER}'@'localhost' IDENTIFIED BY '${MDB_HEALTH_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MDB_DATABASE}\`.* TO '${MDB_USER}'@'%';
GRANT ALL PRIVILEGES ON \`${MDB_DATABASE}\`.* TO '${MDB_HEALTH_USER}'@'%';
    GRANT ALL PRIVILEGES ON \`${MDB_DATABASE}\`.* TO '${MDB_HEALTH_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "Database and users have been set up successfully."

### shut down the mariadb service and wait for it to exit before starting the mariadb service in the foreground.
    mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" --socket=/run/mysqld/mysqld.sock shutdown
    wait "$pid"
fi

echo "Starting MariaDB service in the foreground..."
echo "Ready to accept connections on port 3306."

### first execution of the mariadb service, we will start it in the foreground to ensure that it is running and ready to accept connections.

exec mariadbd \
    --user=mysql \
    --datadir=/var/lib/mysql \
    --socket=/run/mysqld/mysqld.sock \
    --bind-address=0.0.0.0 \
    --port=3306

