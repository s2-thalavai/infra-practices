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

# Start without recreating containers that already exist and are unchanged (fastest, default behavior anyway)
docker compose up -d --no-recreate

========

# After a full teardown (--volumes wipe): bring up just the DB layer first,
# so you can run the manual `CREATE DATABASE keycloak` step before Keycloak starts
docker compose up -d postgres

# Then once the Keycloak DB is created manually, bring up the rest
docker compose up -d

=======

# Follow logs for one service while everything else runs detached — handy for
# watching Loki/Postgres come up cleanly after a fix
docker compose up -d
docker compose logs -f loki

==========



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

======

These two commands do a full teardown:

# Stop and remove containers, delete all images used by this compose file,
# delete all volumes (Postgres/Mongo/Redis/Keycloak/Grafana data — irreversible),
# and clean up any orphaned containers from services no longer in the file
docker compose down --rmi all --volumes --remove-orphans

1.) Stops and removes all containers defined in your docker-compose.yml
2.) --rmi all — deletes every image used by the compose file (including pulled base images like postgres:17-alpine, keycloak, etc., not just custom-built ones)
3.) --volumes — deletes all named volumes (this wipes your Postgres data, MongoDB data, Keycloak realm state, Grafana dashboards, everything)
4.) --remove-orphans — removes containers for services no longer in the compose file (leftover from renamed/removed services)


# Clear build cache so the next build is fully fresh (not just this project's layers)
docker builder prune -a -f

1.) Clears the entire Docker build cache — all layers, not just dangling ones (-a), no confirmation prompt (-f)
2.) Next build of your Spring Boot image will be a full rebuild from scratch (Maven will re-pull all dependencies too)


======

# One-liner equivalent of the full wipe, same effect as the multi-line version:
docker system prune -a --volumes -f

======

