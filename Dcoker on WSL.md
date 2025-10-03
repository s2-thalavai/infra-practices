## Step-by-Step: Start Docker

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
