### Docker Integration

- Enable WSL 2 backend in Docker Desktop
- Share WSL distros under Docker settings → Resources → WSL Integration

To run Docker inside WSL:

    sudo apt update
    sudo apt install docker.io
    sudo usermod -aG docker $USER

<img width="1238" height="442" alt="image" src="https://github.com/user-attachments/assets/5c1962f0-254a-447a-a7d2-fb850c4dc80c" />

## Step-by-Step Installation in WSL 2

### Update your system

    sudo apt update && sudo apt upgrade -y

### Install dependencies

    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

### Add Docker’s GPG key

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

### Add Docker repository

    echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

### Install Docker Engine

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

### Add your user to the Docker group

    sudo usermod -aG docker $USER

### Start Docker service

    sudo service docker start

### Verify installation

    docker --version

Fix: Use service Instead of systemctl

    sudo service docker start

If that fails too, it likely means the Docker daemon isn’t properly installed or configured. You can verify with:

    which dockerd

<img width="768" height="802" alt="image" src="https://github.com/user-attachments/assets/7dc359f2-a905-4d99-a50a-bcc274a89ba5" />



## Docker Commands

### Remove a specific container
    
    docker rm <container_name_or_id>
    
### Stop and remove a running container

    docker stop <container_name_or_id>
    docker rm <container_name_or_id>

### Remove all containers (stopped or running)

    docker rm -f $(docker ps -aq)

### Remove a specific image

    docker rmi <image_name_or_id>

### Remove all unused images

    docker image prune -a

### Remove all images (forcefully)

    docker rmi -f $(docker images -aq)

### Full Cleanup (containers, images, volumes, networks)

    docker system prune -a --volumes

## Docker Compose

    sudo apt-get update
    sudo apt-get install docker-compose-plugin
    docker compose version

<img width="907" height="733" alt="image" src="https://github.com/user-attachments/assets/1ead16e2-d49b-4f33-a619-b0ab451caa42" />


