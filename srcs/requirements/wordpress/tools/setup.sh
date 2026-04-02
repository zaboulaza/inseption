#!/bin/sh
set -e

WP_PATH="/var/www/wordpress"

# je copie les fichiers wordpress dans le volume s'ils n'y sont pas encore
if [ ! -f "$WP_PATH/wp-settings.php" ]; then
    echo "Copying WordPress files to volume..."
    cp -r /usr/src/wordpress/. "$WP_PATH/"
    chown -R www-data:www-data "$WP_PATH"
fi

# j'attends que mariadb soit prêt avant de continuer
echo "Waiting for MariaDB..."
until mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h mariadb -e "SELECT 1" > /dev/null 2>&1; do
    sleep 2
done
echo "MariaDB is ready!"

# je configure wordpress seulement si ce n'est pas déjà fait
if [ ! -f "$WP_PATH/wp-config.php" ]; then

    # je génère le wp-config.php avec les infos de connexion à la base
    wp config create \
        --path=$WP_PATH \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb:3306 \
        --allow-root

    # j'installe wordpress avec le compte admin
    wp core install \
        --path=$WP_PATH \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root \
        --skip-email

    # je crée un deuxième utilisateur avec le rôle éditeur
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=editor \
        --path=$WP_PATH \
        --allow-root

fi

# je lance php-fpm en foreground pour que le container reste actif
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F
