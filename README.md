*This project has been created as part of the 42 curriculum by nsmail.*

# Inception

## Description

Inception is a system administration project that consists of setting up a small infrastructure using **Docker** and **Docker Compose**. The goal is to virtualize a working environment composed of multiple services, each running in its own container, all orchestrated together.

The infrastructure includes three services:
- **Nginx** — the only entry point, handles HTTPS with TLS 1.2/1.3, forwards PHP requests to WordPress via FastCGI
- **WordPress** — runs via php-fpm (no built-in web server), connects to the database
- **MariaDB** — stores all WordPress data

The three containers communicate over an isolated Docker bridge network. Only port 443 is exposed to the outside world.

### Architecture overview

```
Internet
   │
   ▼ (HTTPS :443)
┌──────────┐
│  Nginx   │  ← only entry point, TLS 1.2/1.3
└──────────┘
      │ FastCGI (port 9000)
      ▼
┌──────────────┐       ┌──────────────┐
│  WordPress   │──────▶│   MariaDB    │
│  (php-fpm)   │       │  (port 3306) │
└──────────────┘       └──────────────┘
```

### Design choices

Each service is built from its own `Dockerfile` based on `debian:bullseye`. No pre-built images from Docker Hub are used (except the base OS), as required by the project.

Data is persisted using named Docker volumes bound to `/home/nsmail/data/` on the host machine. WordPress files and the MariaDB database both survive container restarts or rebuilds.

Sensitive credentials (passwords) are stored in the `secrets/` directory and loaded via a `.env` file, keeping them out of the Docker images and version control.

---

### Virtual Machines vs Docker

| | Virtual Machines | Docker |
|---|---|---|
| Isolation | Full OS per VM | Shared kernel, isolated processes |
| Resource usage | Heavy (GBs of RAM per VM) | Lightweight (MBs per container) |
| Boot time | Minutes | Seconds |
| Portability | Less portable (full OS image) | Highly portable (Dockerfile) |
| Use case | Strong isolation, different OS | Microservices, reproducible environments |

Docker containers share the host kernel, making them faster and lighter than VMs. However, VMs offer stronger isolation since each one runs its own kernel. For this project, Docker is the right tool: we need reproducible, lightweight, isolated services — not full machines.

---

### Secrets vs Environment Variables

| | Secrets | Environment Variables |
|---|---|---|
| Storage | Files on disk (not in image) | Passed at runtime or baked into image |
| Visibility | Not exposed in `docker inspect` | Visible in `docker inspect` |
| Security | More secure for sensitive data | Convenient but less secure |
| Use case | Passwords, tokens, keys | Non-sensitive config (domain name, etc.) |

In this project, passwords are stored in the `secrets/` directory and referenced via `.env`. This avoids hardcoding credentials in Dockerfiles or committing them to version control.

---

### Docker Network vs Host Network

| | Docker Network (bridge) | Host Network |
|---|---|---|
| Isolation | Each container has its own IP | Container shares the host's network stack |
| Port exposure | Only published ports are accessible | All ports directly accessible on the host |
| Security | Better — inter-container traffic is isolated | Weaker — no network isolation |
| DNS | Containers resolve each other by name | No automatic DNS between containers |

This project uses a custom bridge network (`inception`). Containers communicate using their service names (`mariadb`, `wordpress`, `nginx`) as hostnames. Only Nginx exposes a port to the outside (`443:443`). Host network mode is explicitly forbidden by the project rules.

---

### Docker Volumes vs Bind Mounts

| | Docker Volumes | Bind Mounts |
|---|---|---|
| Managed by | Docker | User (host path) |
| Portability | Portable across environments | Depends on host path existing |
| Performance | Optimized by Docker | Direct filesystem access |
| Use case | Production data persistence | Development (live code reload) |

This project uses **named volumes with bind mount options** (`type: none`, `o: bind`, `device: /home/nsmail/data/...`). This respects the project requirement of using named volumes while still controlling exactly where data is stored on the host machine.

---

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- `make` available
- Add the domain to your `/etc/hosts`:

```bash
echo "127.0.0.1   nsmail.42.fr" | sudo tee -a /etc/hosts
```

### Setup

Create the `srcs/.env` file with the following variables:

```env
DOMAIN_NAME=nsmail.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=your_password
MYSQL_ROOT_PASSWORD=your_root_password

WP_TITLE=Inception
WP_ADMIN=nsmail
WP_ADMIN_PASSWORD=your_admin_password
WP_ADMIN_EMAIL=nsmail@42.fr
WP_USER=visitor
WP_USER_PASSWORD=your_user_password
WP_USER_EMAIL=visitor@42.fr
```

> The admin username must not contain `admin` or `administrator`.

### Commands

```bash
make          # Build and start all containers
make down     # Stop containers (keep images and data)
make clean    # Stop and remove containers + images
make fclean   # Full cleanup (containers, images, volumes, data on disk)
make re       # Full rebuild from scratch
```

### Access

Open your browser at: `https://nsmail.42.fr`

The SSL certificate is self-signed (generated during the Nginx image build). Your browser will show a security warning — this is expected.

---

## Resources

### Documentation & tutorials

- [Inception subject guide — tuto.grademe.fr](https://tuto.grademe.fr/inception/#sujet) — step-by-step walkthrough of the project
- [Writing Dockerfiles — blog.stephane-robert.info](https://blog.stephane-robert.info/docs/conteneurs/images-conteneurs/ecrire-dockerfile/) — reference for writing clean and correct Dockerfiles
- [Inception full walkthrough (YouTube)](https://www.youtube.com/watch?v=aN4PCILrbBg) — video tutorial covering the whole project
- [Docker official documentation](https://docs.docker.com/)
- [WordPress CLI (wp-cli) documentation](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)

### Use of AI

AI (Claude by Anthropic) was used throughout this project for:
- **Code explanations** — understanding how each script and configuration file works
- **Writing comments** — adding clear inline comments to Dockerfiles, shell scripts, and the docker-compose file
- **Debugging help** — identifying issues in configuration and startup scripts
- **Writing this README** — structuring and writing the documentation

AI was not used to generate the core implementation (Dockerfiles, scripts, configurations) — those were written and understood by the author.
