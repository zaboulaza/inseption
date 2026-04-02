# DEV_DOC — Inception

## Stack

3 containers Docker sur un réseau bridge `inception` :

- **nginx** — reverse proxy HTTPS (port hôte 445 → container 443)
- **wordpress** — php-fpm 7.4 (port interne 9000)
- **mariadb** — base de données (port interne 3306)

## Structure

```
inseption/
├── Makefile
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/       Dockerfile + nginx.conf
        ├── wordpress/   Dockerfile + setup.sh + www.conf
        └── mariadb/     Dockerfile + script.sh + 50-server.cnf
```

## Variables (.env)

| Variable | Rôle |
|---|---|
| `DOMAIN_NAME` | Domaine du site |
| `MYSQL_*` | Config base de données |
| `WP_ADMIN` | Admin WordPress (interdit : admin/administrator) |
| `WP_USER` | Utilisateur éditeur WordPress |
| `WP_TITLE` | Titre du site |

## Ce que fait chaque script de démarrage

**mariadb/script.sh** — démarre mysqld temporairement, crée la BDD + user + droits, puis relance en foreground.

**wordpress/setup.sh** — copie les fichiers WP dans le volume, attend MariaDB, installe WordPress via wp-cli si pas encore fait, lance php-fpm en foreground.

## Volumes (bind mount sur l'hôte)

| Volume | Chemin hôte |
|---|---|
| `mariadb_data` | `/home/nsmail/data/mariadb` |
| `wordpress_data` | `/home/nsmail/data/wordpress` |

## Makefile

| Cible | Action |
|---|---|
| `make` | Crée les dossiers + build + up |
| `make down` | Stop les containers |
| `make clean` | Stop + supprime les images |
| `make fclean` | Clean + supprime volumes et données disque |
| `make re` | fclean + make |
