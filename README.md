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
    
# install Java, Node.js and Python

## Steps to Install OpenJDK (Default Java)

## Open Source & Cost-Free
- Licensed under **GNU GPL + Classpath Exception**, meaning:
  - No licensing fees or subscriptions
  - Full freedom to modify, redistribute, and audit the source
  - Ideal for CI/CD pipelines, containerized deployments, and hybrid cloud setups without legal overhead

## LTS Stability with Modern Features
- Java 21 is a **Long-Term Support (LTS)** release, ensuring:
  - 8+ years of community updates and security patches
  - Enterprise-grade reliability for production systems

### Key Enhancements:
- **Virtual Threads (Project Loom)** for scalable concurrency
- **Record Patterns** and **Pattern Matching for switch** for cleaner, expressive code
- **Sequenced Collections** for predictable iteration order

## Modularity & Performance
- Improved **JVM performance** and **GC tuning** (G1, ZGC) for low-latency workloads
- Enhanced **JEPs (Java Enhancement Proposals)** that support:
  - Streamlined observability
  - Better memory footprint for microservices
  - Faster startup and reduced warm-up time—critical for serverless and edge deployments

## Security & Compliance
- Regular community-driven updates ensure:
  - Timely patching of CVEs
  - Transparent changelogs and reproducibility
- No vendor lock-in—ideal for **multi-cloud governance** and **auditability**

## Broad Ecosystem Support
- Supported by major platforms:
  - AWS Corretto
  - Eclipse Temurin
  - Azul Zulu

### Seamless Integration With:
- Spring Boot 3.x  
- Jakarta EE 10+  
- GraalVM (for native image builds)

### Update package index

    sudo apt update

### Install default JDK (includes JRE)

    sudo apt install -y openjdk-21-jdk

### Verify installation

    java -version
    javac -version

This installs the latest LTS version available in Ubuntu’s repositories—typically OpenJDK 17 or 21 depending on your distro version2.

### Download latest Maven binary

    wget https://downloads.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz

### Extract and move to /opt

    tar -xvzf apache-maven-3.9.11-bin.tar.gz
    sudo mv apache-maven-3.9.11 /opt/maven

### Set environment variables

    echo "export M2_HOME=/opt/maven" >> ~/.bashrc
    echo "export PATH=\$M2_HOME/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

### Verify

    mvn -version

### Gradle Manual Install (Latest Version)

### Download latest Gradle binary

    wget https://services.gradle.org/distributions/gradle-9.0.0-bin.zip -P /tmp

### Extract and move to /opt

    sudo unzip -d /opt/gradle /tmp/gradle-9.0.0-bin.zip

### Set environment variables

    echo "export GRADLE_HOME=/opt/gradle/gradle-9.0.0" >> ~/.bashrc
    echo "export PATH=\$GRADLE_HOME/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

#### Verify
    gradle -v

<img width="958" height="582" alt="image" src="https://github.com/user-attachments/assets/b7be91b9-e21c-4ae5-ab99-98737dc784fe" />

## Install node.js via APT (Quick & Simple)

    sudo apt update
    sudo apt install -y nodejs npm
    node -v
    npm -v
    
### Install Default Python (Usually Python 3.x)

    sudo apt update
    sudo apt install -y python3 python3-pip
    python3 --version
    pip3 --version

<img width="1017" height="258" alt="image" src="https://github.com/user-attachments/assets/f34b7500-64d6-4e26-9774-5c4319739e08" />
