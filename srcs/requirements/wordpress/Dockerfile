FROM debian:bullseye

# j'installe php-fpm et les extensions dont wordpress a besoin
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

# j'installe wp-cli pour configurer wordpress en ligne de commande
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www

# je télécharge wordpress dans /usr/src/ car /var/www/wordpress sera un volume vide au démarrage
RUN wget https://fr.wordpress.org/wordpress-6.1-fr_FR.tar.gz \
    && tar -xzf wordpress-6.1-fr_FR.tar.gz -C /usr/src/ \
    && rm wordpress-6.1-fr_FR.tar.gz \
    && chown -R www-data:www-data /usr/src/wordpress

RUN mkdir -p /var/www/wordpress \
    && chown -R www-data:www-data /var/www/wordpress

# dossier requis par php-fpm
RUN mkdir -p /run/php

# ma config php-fpm pour écouter sur le port 9000
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# mon script qui installe et démarre wordpress
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
