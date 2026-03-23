#!/bin/bash

# Démarre MariaDB temporairement en arrière-plan pour pouvoir le configurer
service mariadb start
sleep 5

# Crée la base de données pour WordPress si elle n'existe pas déjà
mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"

# Crée l'utilisateur WordPress si il n'existe pas déjà
mysql -u root -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

# Donne tous les droits sur la base WordPress à cet utilisateur
mysql -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"

# Sécurise le compte root avec un mot de passe
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

# Applique tous les changements
mysql -u root -e "FLUSH PRIVILEGES;"

# Arrête MariaDB proprement
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# Relance MariaDB en foreground - obligatoire pour que le conteneur reste actif
exec mysqld_safe