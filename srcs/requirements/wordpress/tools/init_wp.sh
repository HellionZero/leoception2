#!/bin/sh

set -eu

WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_ADMIN_EMAIL=$(cat /run/secrets/wp_admin_email)
WP_DB_PASSWORD=$(cat /run/secrets/wp_db_password)
WP_DB_USER=$(cat /run/secrets/wp_db_user)
WP_USER=$(cat /run/secrets/wp_user)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
WP_USER_EMAIL=$(cat /run/secrets/wp_user_email)
WP_DB_NAME=$(cat /run/secrets/wp_db_name)

until mariadb --protocol=TCP -h mariadb -u"${WP_DB_USER}" -p"${WP_DB_PASSWORD}" -e "SELECT 1"; do
    echo "Waiting for database connection..."
    sleep 3
done

echo "Preparing the database for WordPress..."

if  [ ! wp core is-installed --allow-root --path="/var/www/html" ]; then
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
        --url="http://localhost:9000" \
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

wp config set WP_CACHE true --add --type=constant --allow-root --path="/var/www/html"

chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

exec php-fpm8.1 -F

