# Docker and Docker Compose Setup

**production-safe Docker + Docker Compose installation guide** for **Ubuntu (22.04 / 24.04 / noble)**.

----------

## Install Docker & Docker Compose (Official Method)

## 1. Remove Old Versions (if any)

```bash
sudo apt remove docker docker-engine docker.io containerd runc -y
``` 

----------

## 2. Install Required Packages

```bash
sudo apt update sudo apt install ca-certificates curl gnupg -y
``` 

----------

## 3. Add Docker’s Official GPG Key

```bash
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \ sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg sudo  chmod a+r /etc/apt/keyrings/docker.gpg
``` 

----------

## 4. Add Docker Repository

```bash
echo \ "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \ $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \ sudo  tee /etc/apt/sources.list.d/docker.list > /dev/null
``` 

----------

## 5. Install Docker Engine + Compose Plugin

```bash
sudo apt update sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
``` 

----------

# Verify Installation

### Check Docker version

```bash
docker --version
``` 

### Check Compose version

```bash
docker compose version
``` 

>  Note: Modern Docker uses `docker compose` (NOT `docker-compose`)

----------

# Test Docker

```bash
sudo docker run hello-world
``` 

You should see:

`Hello from Docker!` 

----------

# Optional: Run Docker Without sudo (Recommended)

```bash
sudo usermod -aG docker $USER newgrp docker
``` 

Now test:

```bash
docker run hello-world
```

----------


<img width="1246" height="1020" alt="image" src="https://github.com/user-attachments/assets/f8ee1e89-ee7e-45b1-ad4d-84e149cef974" />

<img width="1212" height="1021" alt="image" src="https://github.com/user-attachments/assets/130b12c7-8820-4dc6-b176-40b88a5ad08e" />

----------
