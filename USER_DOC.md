# USER_DOC — Inception

## Prérequis

Ajouter dans `/etc/hosts` :
```
127.0.0.1   nsmail.42.fr
```

## Lancer

```bash
make
```

## Accéder au site

```
https://nsmail.42.fr:445
```

> Le certificat est auto-signé, ignorer l'avertissement du navigateur.

## Administration WordPress

```
https://nsmail.42.fr:445/wp-admin
```

Login : `nsmail` / mot de passe dans `srcs/.env`

## Commandes

| Commande | Description |
|---|---|
| `make` | Lance tout |
| `make down` | Stop (données conservées) |
| `make re` | Repart de zéro |
| `make fclean` | Supprime tout (containers, images, données) |

## Logs

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```
