#!/bin/bash

# je démarre mariadb en arrière-plan sans réseau pour pouvoir le configurer
mysqld_safe --skip-networking &

# j'attends que mariadb soit prêt avant de lancer les requêtes
until mysqladmin ping --silent 2>/dev/null; do sleep 1; done

# je crée la base de données pour wordpress
mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"

# je crée l'utilisateur wordpress
mysql -u root -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

# je lui donne tous les droits sur la base wordpress
mysql -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"

# je mets un mot de passe sur root
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

# j'applique les changements
mysql -u root -e "FLUSH PRIVILEGES;"

# j'arrête mariadb proprement
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# je relance mariadb en foreground pour que le container reste actif
exec mysqld --user=mysql
