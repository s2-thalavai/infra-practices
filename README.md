# linux-practices

    Linux is a widely used operating system and is quite important for developers.    
    
    Luckily, Windows provides a convenient utility for using Linux along side Windows. 
    This utility is called WSL (Windows Subsystem for Linux).
    
    Its recent version is WSL2 and in this guide we'll discuss it in detail.

## What is WSL2?

    https://learn.microsoft.com/en-us/windows/wsl/install-manual

    Windows Subsystem for Linux provides a compatibility layer that lets you run Linux binary executables natively on Windows.
    
    WSL2 (Windows Subsystem for Linux version 2) is the latest version of WSL. 
    WSL2 architecture replaces WSL's architecture by using a lightweight virtual machine. 
    In the new version, you can run an actual Linux kernel which improves overall performance.

Search for "Turn Windows features on or off."
Check the option Windows Subsystem for Linux.

<img width="891" height="550" alt="image" src="https://github.com/user-attachments/assets/328747b6-0175-40e6-8b36-d1b84b01a6ec" />

    PS C:\Windows\system32> cmd.exe /c ver
    
    Microsoft Windows [Version 10.0.26100.4946]

### System Requirements and Preparation

<img width="1918" height="1017" alt="image" src="https://github.com/user-attachments/assets/4ef540b0-6634-462e-addc-5690dddfd159" />


### List the online available Linux distros

  To install a specific distro, use the command below:
  
    wsl --install -d DISTRO-NAME

  For example, to install Debian, the command would be modified as follows:

     wsl --install -d Ubuntu-24.04

Follow the prompts and the specific distribution will be installed.

    wsl --update

### Set default WSL version

    wsl --set-default-version 2

Check the status by launching Windows PowerShell.

<img width="1207" height="892" alt="image" src="https://github.com/user-attachments/assets/c7871f32-f835-44cb-a00e-057c0763da18" />

### List installed Linux distributions

    wsl --list --verbose

### Set default Linux distribution

    wsl --set-default <Distribution Name>

To set the default Linux distribution that WSL commands will use to run, replace <Distribution Name> with the name of your preferred Linux distribution.

### Start WSL in user's home

    wsl ~

The ~ can be used with wsl to start in the user's home directory. 
To jump from any directory back to home from within a WSL command prompt, you can use the command: cd ~.

File System Integration
One of WSL2’s strongest features is its file system integration. Here’s how to make the most of it: 

### Accessing Windows Files from Linux

Your Windows drives are automatically mounted under `/mnt/`: 

Access C drive 

    cd /mnt/c

Inside your WSL terminal (e.g., Ubuntu), your Windows drives are mounted under /mnt. 

    cd /mnt/c/Users/<YourWindowsUsername>/Documents

    cd /mnt/c/Users/s2tha/Documents

This gives you access to your Windows Documents folder.

You can list files with:

    ls /mnt/c/

### Check the status by launching Windows PowerShell.

<img width="1918" height="662" alt="image" src="https://github.com/user-attachments/assets/04933c8b-ecb9-4f3e-9e1d-ce51adc26643" />

    wsl --unregister <DistroName>
    
    wsl --list --verbose
    
    wsl --unregister Ubuntu

## Architecture Overview: Hybrid Messaging Benchmarks

##  Objective

Benchmark RabbitMQ and Kafka across Windows and WSL 2 environments to evaluate latency, throughput, and cross-platform interoperability.


## System Roles

| Component         | Windows Host Role                  | WSL 2 Role                            |
|------------------|------------------------------------|---------------------------------------|
| Docker Engine     | Native or Docker Desktop           | Optional (via Docker in WSL)          |
| RabbitMQ          | Benchmark target or control node   | Peer node or isolated test instance   |
| Kafka             | Zookeeper + Broker on either side  | Linux-native performance comparison   |
| Messaging Clients | Java/Python/Node.js CLI tools      | Cross-platform latency comparison     |

---

## Setup Strategy

### 1. Networking Bridge
- Use `ip route` in WSL to identify Windows host IP
- Access Windows services from WSL via default gateway

Ensure WSL 2 can reach Windows services:

    ip route | grep default

### 2. Docker Integration
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


### 3. RabbitMQ Setup

Use Docker image:

    docker run -d --hostname rabbit --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:management

Access via:

    Windows: localhost:15672

WSL: Use host IP from ip route

the default username and password for the RabbitMQ Management UI (on port 15672) are:

    Username: guest
    
    Password: guest


<img width="1918" height="967" alt="image" src="https://github.com/user-attachments/assets/e74f51ae-52dd-4d27-b894-39b46ab11e2e" />


However, there's a catch: 🔒 The guest user is only allowed to connect from localhost. 
If you're accessing RabbitMQ from a browser outside the container (e.g., from Windows or WSL), authentication will fail.

### Set Custom Credentials
To allow remote access, define your own user with environment variables:

    docker run -d --hostname rabbit --name rabbitmq \
      -p 5672:5672 -p 15672:15672 \
      -e RABBITMQ_DEFAULT_USER=admin \
      -e RABBITMQ_DEFAULT_PASS=admin \
      rabbitmq:management
      
Then log in at http://localhost:15672 using:

    Username: admin
    
    Password: admin

<img width="892" height="542" alt="image" src="https://github.com/user-attachments/assets/96aeeb7c-1bca-45c5-88f7-94de999238bb" />

<img width="1918" height="401" alt="image" src="https://github.com/user-attachments/assets/b8aebf2f-9c49-4d02-88c7-ab0406c98d46" />

<img width="1918" height="1016" alt="image" src="https://github.com/user-attachments/assets/42819bda-7900-4fc6-89b6-5df7897a1f6b" />


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

