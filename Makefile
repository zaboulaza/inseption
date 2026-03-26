# Chemin vers le fichier docker-compose.yml
COMPOSE_FILE	= srcs/docker-compose.yml

# Dossiers où Docker va stocker les données des volumes sur la machine hôte
# Le sujet impose que ce soit dans /home/login/data/
DATA_DIR		= /home/nsmail/data
MARIADB_DIR		= $(DATA_DIR)/mariadb
WORDPRESS_DIR	= $(DATA_DIR)/wordpress

# Cible par défaut : lancée quand on tape juste "make"
all: $(MARIADB_DIR) $(WORDPRESS_DIR)
	docker compose -f $(COMPOSE_FILE) up -d --build

# Crée les dossiers de données si ils n'existent pas encore
# Le "-p" permet de créer les dossiers parents si nécessaire sans erreur
$(MARIADB_DIR):
	mkdir -p $(MARIADB_DIR)

$(WORDPRESS_DIR):
	mkdir -p $(WORDPRESS_DIR)

# Arrête les containers sans les supprimer
# Utile pour faire une pause sans perdre les images buildées
down:
	docker compose -f $(COMPOSE_FILE) down

# Arrête et supprime les containers + les images buildées
# Les volumes et données sur le disque sont conservés
clean: down
	docker compose -f $(COMPOSE_FILE) down --rmi all

# Nettoyage complet :
# - Supprime containers + images
# - Supprime les volumes Docker nommés
# - Supprime les données sur le disque (/home/zaboulaza/data/)
fclean: clean
	docker volume prune -f
	sudo rm -rf $(DATA_DIR)

# Repart de zéro : fclean puis rebuild tout
re: fclean all

# Indique à make que ces cibles ne sont pas des fichiers
# Sans ça, make pourrait croire que "all", "clean" etc. sont des fichiers à créer
.PHONY: all down clean fclean re
