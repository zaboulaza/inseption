FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    php7.4 \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-curl \
    php7.4-gd \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Téléchargement de wp-cli pour gérer WordPress en ligne de commande
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Dossier de travail
WORKDIR /var/www

# Téléchargement et extraction de WordPress
RUN wget https://fr.wordpress.org/wordpress-6.1-fr_FR.tar.gz \
    && tar -xzf wordpress-6.1-fr_FR.tar.gz \
    && rm wordpress-6.1-fr_FR.tar.gz \
    && chown -R www-data:www-data /var/www/wordpress

# Dossier nécessaire pour php-fpm
RUN mkdir -p /run/php

# Copie de la config php-fpm pour écouter sur le port 9000
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Copie du script de démarrage
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]