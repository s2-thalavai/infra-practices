# Docker Commands Reference — bp-onboarding-service

Quick reference for teardown, cleanup, and startup commands used while developing
`reactive-bp-multi-tenant-onboarding-service`.

---

## Teardown Commands

### Scoped teardown (this project only) — recommended
```bash
# Stop and remove containers, delete all images used by this compose file,
# delete all volumes (Postgres/Mongo/Redis/Keycloak/Grafana data — irreversible),
# and clean up any orphaned containers from services no longer in the file
docker compose down --rmi all --volumes --remove-orphans

# Clear build cache so the next build is fully fresh (not just this project's layers)
docker builder prune -a -f
```

### Clean rebuild without wiping data
```bash
# Same as above but keeps volumes (Postgres/Mongo/Keycloak/Grafana data survives)
docker compose down --rmi all --remove-orphans
docker builder prune -a -f
```

> `--volumes` wipes all persisted state, including the manually-created
> `keycloak` database and any Kafka topics. After a `--volumes` teardown you'll
> need to redo those manual setup steps on next `up`.

---

## Full Machine Wipe (all Docker projects, not just this one)

### One-liner
```bash
docker system prune -a --volumes -f
```

### Explicit/manual equivalent (same result, more visible)
```bash
# Stop every running container on this machine
docker stop $(docker ps -aq)

# Force-remove every container (running or stopped)
docker rm -f $(docker ps -aq)

# Force-remove every image, including base images pulled for any project
docker rmi -f $(docker images -aq)

# Remove every named/anonymous volume — THIS DELETES ALL PERSISTED DATA
docker volume rm $(docker volume ls -q)

# Remove all custom (non-default) networks
docker network prune -f

# Clear the entire build cache — next builds start from zero
docker builder prune -a -f
```

> This removes containers/images/volumes from **every** Docker project on
> the machine, not just this one. Use the scoped version above unless you
> genuinely want a full machine-wide reset.

---

## `docker compose up` Variants

```bash
# Standard: build images if needed, start everything in the background (detached)
docker compose up -d

# Force a rebuild of images before starting (use after Dockerfile/pom.xml changes)
docker compose up -d --build

# Start in the foreground so you see live logs from all services (Ctrl+C stops everything)
docker compose up

# Start only specific services (and their declared dependencies)
docker compose up -d postgres pgadmin

# Recreate containers even if config hasn't changed (useful when env vars/secrets changed but image didn't)
docker compose up -d --force-recreate

# Rebuild + force recreate — the "I changed code AND config" combo
docker compose up -d --build --force-recreate

# Start without recreating containers that already exist and are unchanged (default behavior anyway)
docker compose up -d --no-recreate
```

### Sequencing after a full teardown (for the Keycloak manual DB-creation step)
```bash
# 1. Bring up just the DB layer first
docker compose up -d postgres

# 2. Manually create the keycloak database (see below), then bring up the rest
docker compose up -d
```

### Watching one service's logs while the rest run detached
```bash
docker compose up -d
docker compose logs -f loki
```

---

## `docker compose up -d postgres` — Extra Params

```bash
# Basic: start only postgres, detached
docker compose up -d postgres

# Skip dependencies — start ONLY postgres itself, nothing it depends_on
docker compose up -d --no-deps postgres

# Rebuild postgres's image first (rarely needed — using postgres:17-alpine, not a custom build)
docker compose up -d --build postgres

# Force recreate the container even if nothing changed (e.g. after editing secrets/postgres_password.txt)
docker compose up -d --force-recreate postgres

# Start postgres AND pgadmin together, but nothing else
docker compose up -d postgres pgadmin

# Pull the latest postgres:17-alpine image before starting
docker compose up -d --pull always postgres

# Start in foreground to watch init-scripts run during first-time volume init
docker compose up postgres
```

### Practical first-bring-up sequence (fresh volume)
```bash
# Foreground so you see init-scripts execute and pg_isready pass
docker compose up postgres
```
Then, in a second terminal once healthy:
```bash
docker exec -it bp-postgres psql -U bp_admin -d bp_onboarding
```

---

## Known Gotchas (Reminders)

- **Postgres volume pre-init**: if the volume existed before secrets were in place, the
  password in the volume won't match config. Fix with `ALTER USER`, not volume deletion.
- **Keycloak DB**: not auto-created — run `init-scripts/01-create-keycloak-db.sql` or
  manually `CREATE DATABASE keycloak` after Postgres is healthy but before Keycloak starts.
- **Kafka topics**: `KAFKA_AUTO_CREATE_TOPICS_ENABLE=false` — three topics must be created
  manually after a `--volumes` wipe.
- **Docker phantom directories**: if a bind-mount path doesn't exist when a config file is
  missing, Docker creates an empty directory there. `rm -rf` the phantom path before placing
  the real file, or a subsequent `mv` will land *inside* it instead of replacing it.
