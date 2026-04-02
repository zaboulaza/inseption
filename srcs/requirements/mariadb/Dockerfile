FROM debian:bullseye

# j'installe mariadb
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# je crée les dossiers dont mariadb a besoin et je donne les droits au bon user
RUN mkdir -p /run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /run/mysqld /var/lib/mysql

RUN mkdir -p /etc/mysql/mariadb.conf.d

# je copie ma config
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# je copie mon script d'init
COPY tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/script.sh"]
