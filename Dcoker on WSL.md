## Step-by-Step: Start & Stop & cleanup Docker

### 1. Check if Docker is installed

    docker --version
    
If it’s not installed, you can install it with:

    sudo apt update
    sudo apt install docker.io

### 2. Start the Docker service

    sudo systemctl start docker
    
### 3. Enable Docker to start on boot

    sudo systemctl enable docker
    
### 4. Verify Docker is running

    sudo systemctl status docker

You should see active (running) in green.

### Optional: Run a test container

    docker run hello-world
    
This confirms Docker is working correctly.

<img width="1918" height="980" alt="image" src="https://github.com/user-attachments/assets/5696001f-148a-4541-bfe9-da5a392695aa" />

<img width="982" height="813" alt="image" src="https://github.com/user-attachments/assets/501411d5-c68a-4377-8eaa-18fe8965bf4a" />

---

## View All Running Containers with Port Mappings

    docker ps

This shows a list of running containers with their port mappings in the PORTS column.

Example output:

    CONTAINER ID   IMAGE               PORTS
    d11066722eca   bashj79/kafka-kraft 0.0.0.0:9095->9095/tcp

This means port 9095 on your host is mapped to port 9095 inside the container.

### Inspect a Specific Container

    docker inspect <container_id> | grep -i port

Or more readable:

    docker port <container_id>

Example:

    docker port d11066722eca

This will return something like:

    9095/tcp -> 0.0.0.0:9095


<img width="1567" height="631" alt="image" src="https://github.com/user-attachments/assets/f28c1cd7-6ce7-4fb1-a799-c1b8c428704b" />

### List All Containers with Port Info


    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}"
    
This gives a clean table of container IDs, names, and port mappings.

<img width="1442" height="770" alt="image" src="https://github.com/user-attachments/assets/be2be517-d0d8-4151-ad37-7b26082ed2e6" />

---

## Step-by-Step Cleanup

### 1. Stop all running containers

    docker stop $(docker ps -q)

### 2. Remove all containers

    docker rm $(docker ps -a -q)
    
### 3. Remove all images

    docker rmi $(docker images -q)

### Optional: Remove volumes and networks

If you want a deeper cleanup:

    docker volume prune -f
    docker network prune -f

Or to remove everything:

    docker system prune -a --volumes -f
