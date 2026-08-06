#!/bin/sh

set -eu

### set up the WordPress application based on the secrets provided by docker swarm.

WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_ADMIN_EMAIL=$(cat /run/secrets/wp_admin_email)
WP_DB_PASSWORD=$(cat /run/secrets/wp_db_password)
WP_DB_USER=$(cat /run/secrets/wp_db_user)
WP_USER=$(cat /run/secrets/wp_user)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
WP_USER_EMAIL=$(cat /run/secrets/wp_user_email)
WP_DB_NAME=$(cat /run/secrets/wp_db_name)
DOMAIN_NAME="${DOMAIN_NAME:-localhost}"
SITE_URL="${DOMAIN_NAME#http://}"
SITE_URL="${SITE_URL#https://}"
SITE_URL="https://${SITE_URL%/}"

### security measure to prevent the WordPress installation from crashing due to insufficient memory allocation for PHP. 
### This is a simple but effective way to ensure that the application has enough memory to function properly.
### We will set the memory limit to 512M to ensure that WordPress has enough resources to run smoothly.
wp() {
    php -d memory_limit=512M /usr/local/bin/wp "$@"
}

### wait for the database to be ready before proceeding with the WordPress installation.

until mariadb --protocol=TCP -h mariadb -P 3306 -u"${WP_DB_USER}" -p"${WP_DB_PASSWORD}" -e "SELECT 1"; do
    echo "Waiting for database connection..."
    sleep 3
done

echo "Preparing the database for WordPress..."

### check if the WordPress installation has already been completed. 
### If it has, we will skip the installation process to avoid overwriting any existing data.
### In this phase of the setup, we will use the port 3306 to connect to the database, 
### and we will use the TCP protocol to ensure that the connection is established correctly.
### we will use the port 5050 to access the WordPress application, which is the default port for the built-in PHP server.
### later we will change the port to 9000 to use the Nginx server as a reverse proxy 
### to handle incoming requests and forward them to the PHP server.

if ! wp core is-installed --allow-root --path="/var/www/html"; then
    wp core download \
        --allow-root \
        --path="/var/www/html"

    wp config create \
        --allow-root \
        --path="/var/www/html" \
        --dbname="${WP_DB_NAME}" \
        --dbuser="${WP_DB_USER}" \
        --dbpass="${WP_DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --skip-check \
        --path="/var/www/html" 
        
    wp core install \
        --allow-root \
        --url="$SITE_URL" \
        --title="Inception" \
        --admin_user="admin" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --path="/var/www/html" 

    echo "WordPress installation completed successfully."
else
    echo "WordPress is already installed. Skipping installation."
fi

if ! wp user get "${WP_USER}" --allow-root --path="/var/www/html" >/dev/null 2>&1; then
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root \
        --path="/var/www/html"
fi

### we need to set up the WordPress cache to improve the performance of the application.
### This will help to reduce the load on the server and improve the user experience.


### set the correct ownership and permissions for the WordPress files.
### This ensures that the web server can read and write to the files, 
### and that the directories have the correct permissions to prevent unauthorized access.

chown -R nobody:nobody /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

### start php-fpm so nginx can serve WordPress through FastCGI.
mkdir -p /run/php
if grep -q '^listen = 127.0.0.1:9000' /etc/php84/php-fpm.d/www.conf; then
    sed -i "s/^listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/" /etc/php84/php-fpm.d/www.conf
fi
exec php-fpm84 --nodaemonize -c /etc/php84/php-fpm.conf

