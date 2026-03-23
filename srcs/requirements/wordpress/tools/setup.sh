FROM debian:bullseye

# Installation de PHP, php-fpm, et les extensions nécessaires pour WordPress
RUN apt-get update && apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    php-curl \
    php-dom \
    php-exif \
    php-mbstring \
    php-zip \
    wget \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Création du dossier WordPress
RUN mkdir -p /var/www/html

# Téléchargement et installation de wp-cli
# wp-cli c'est un outil en ligne de commande pour gérer WordPress
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copie du script de configuration
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Port sur lequel php-fpm écoute
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]