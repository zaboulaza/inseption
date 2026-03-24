#!/bin/sh
set -e

WP_PATH="/var/www/wordpress"

# Attente de MariaDB
echo "Waiting for MariaDB..."
until mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h mariadb -e "SELECT 1" > /dev/null 2>&1; do
    sleep 2
done
echo "MariaDB is ready!"

# Configuration de WordPress
if [ ! -f "$WP_PATH/wp-config.php" ]; then

    # Création du wp-config.php avec les infos de la base de données
    wp config create \
        --path=$WP_PATH \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb:3306 \
        --allow-root

    # Installation de WordPress avec le compte admin
    # Le nom admin ne doit pas contenir admin/administrator (obligatoire selon le sujet)
    wp core install \
        --path=$WP_PATH \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root \
        --skip-email

    # Création d'un utilisateur standard (obligatoire selon le sujet)
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=editor \
        --path=$WP_PATH \
        --allow-root

fi

# Lancement de php-fpm en foreground
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F