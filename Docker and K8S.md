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


### Why You Specify a Base Image in Docker

Even though AKS nodes run a base OS (typically Ubuntu or Debian), 
your container image must still include its own user-space environment. That’s because:

Containers don’t share the host OS user space, only the kernel.

Your image needs to include the JVM, libraries, and tools your app depends on.

The base image defines the runtime environment for your app—not the AKS node.

So yes, AKS has a base OS, but your container runs in isolation with its own filesystem, libraries, and binaries.

### 

when choosing base images for JVM workloads in containers.
Here's a breakdown of how musl libc (used in Alpine) differs from glibc (used in Debian/Ubuntu), 
and why it can impact JIT performance and native memory behavior in Java:

# Musl vs. Glibc(short for the GNU C Library): JVM Runtime Implications

| **Aspect**               | **glibc**                                                                 | **musl**                                                                 |
|--------------------------|---------------------------------------------------------------------------|-------------------------------------------------------------------------|
| **JIT Optimization**     | Highly tuned for performance; supports advanced memory mapping and signal handling used by HotSpot | Limited support for some low-level optimizations; may degrade JIT throughput |
| **Native Memory Allocation** | Efficient with large heaps and off-heap memory (e.g., `DirectByteBuffer`, Netty) | Can struggle with large allocations; fragmentation and slower `malloc` behavior observed |
| **Threading & Signals**  | Full POSIX compliance; better support for `perf`, `async-profiler`, and JVM signal handling | Minimalist implementation; some tools (e.g., `jcmd`, `jmap`) may misbehave or fail silently |
| **Compatibility**        | Broad support for JVM internals, profiling tools, and native libraries | Some native libraries (e.g., JNI, Panama) may require patching or fail to load |
| **Performance Benchmarks** | Faster in real-world JVM workloads (GC, JIT, I/O) | Lightweight but slower in high-throughput JVM scenarios |

### musl

musl is a lightweight, fast, and standards-compliant implementation of the C standard library (libc) designed specifically for Linux-based systems. 
It’s the default libc used in Alpine Linux, which is why it’s so common in containerized environments like Docker and Kubernetes.

### Core Purpose

musl provides the essential building blocks for C programs to interact with the operating system, including:

    Memory allocation (malloc, free)
    
    File I/O (fopen, read, write)
    
    Threading (pthread_create, mutex)
    
    String manipulation (strcpy, strlen)
    
    System calls and POSIX interfaces

### Key Features

    Minimalist design: Extremely small footprint (~500KB), ideal for static linking and embedded systems.
    
    Static linking friendly: Enables fully self-contained binaries without external dependencies.
    
    MIT licensed: Permissive and open-source.
    
    Realtime robustness: Designed to avoid race conditions and resource exhaustion failures.
    
    Single shared library: All functionality is packed into one .so file, unlike glibc which splits across libm, libpthread, etc.

## Impact on JVM and Java Performance

While musl is great for small containers, it introduces trade-offs for JVM workloads.

### Performance & Compatibility Concerns

- **JIT compilation**: musl lacks some low-level optimizations glibc provides, which can slow down HotSpot’s tiered compilation.
- **Native memory allocation**: musl’s `malloc` behavior can lead to fragmentation or slower off-heap memory access (e.g., Netty, `DirectByteBuffer`).
- **Signal handling**: JVM tools like `jcmd`, `jmap`, and `async-profiler` may misbehave or fail silently due to musl’s limited signal support.
- **Regex and I/O quirks**: musl’s `stdio` and regex implementations differ from glibc, which can affect edge-case behavior in Java apps.

## When to Use musl (Alpine)

### Use musl if:
- You need ultra-small containers  
- Your app is simple, stateless, and doesn’t rely on native interop  
- You’re optimizing for cold start and image pull speed  

### Avoid musl if:
- You’re doing GC benchmarking, JIT profiling, or native interop (JNI, Panama)  
- You rely on advanced JVM tooling or observability  
- You need consistent performance under high load  

### Real-World Impact in AKS

    GC behavior: G1GC and ZGC may show longer pause times or reduced throughput on musl due to allocator behavior.
    
    JIT compilation: HotSpot’s tiered compilation may be less aggressive or slower.
    
    Profiling tools: async-profiler, perf, and JFR may have reduced fidelity or require glibc-based containers for full support.
    
    Native interop: Panama and JNI-based telemetry ingestion may fail or require glibc compatibility layers.

### Recommendation for JVM-heavy AKS Workloads

# Recommendation for JVM-heavy AKS Workloads

If you're doing:

- GC benchmarking  
- JIT profiling  
- Native interop (Panama, JNI)  
- Async-profiler or JFR tracing  

Then consider switching to a **glibc-based image** like:

```dockerfile
    FROM eclipse-temurin:17-jre
```

or

```dockerfile
    FROM debian:bullseye-slim
```
Both are glibc-based, container-aware, and fully compatible with JVM tooling.

Temurin is simpler and prebuilt; 
Debian gives you more control if you want to layer in custom tools or switch to Java 21 later.

### Dockerfile

Debian-based glibc image (debian:bullseye-slim) instead of Alpine. 
This version is optimized for JVM-heavy workloads in AKS, with full glibc compatibility for better JIT performance, 
native memory handling, and profiling support:

```
# Base image: Debian slim with glibc
FROM debian:bullseye-slim

# Avoid interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive

# Install OpenJDK 21 and essential debugging tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-21-jre-headless \
    curl \
    wget \
    net-tools \
    iputils-ping \
    dnsutils \
    telnet \
    bash \
    traceroute \
    openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy prebuilt JAR from Jenkins artifact
COPY sample-service.jar app.jar

# Expose application port
EXPOSE 8080

# JVM tuning for AKS containers
ENTRYPOINT [
  "java",
  "-Djava.security.egd=file:/dev/./urandom",
  "-Dvertx.disableDnsResolver=true",
  "-Djava.net.preferIPv4Stack=true",
  "-XX:+UseG1GC",
  "-XX:MaxGCPauseMillis=200",
  "-XX:+UnlockExperimentalVMOptions",
  "-XX:+UseContainerSupport",
  "-XX:MaxRAMPercentage=75.0",
  "-XX:+HeapDumpOnOutOfMemoryError",
  "-jar",
  "app.jar"
]
```
### Why This Setup Is Ideal for AKS

    glibc-based: Full compatibility with JVM internals and native libraries.
    Java 21 LTS: Supports modern language features and improved GC behavior.
    Debug tools included: telnet, dig, traceroute, openssl, etc.
    Container-aware JVM flags: Ensures predictable memory usage and GC tuning.

## my aks host os ubuntu, shall i use debian:bullseye-slim or eclipse-temurin:17-jre or anyother?

# Base Image Recommendation for JVM-heavy AKS Workloads

Although AKS nodes typically run Ubuntu, container base images operate in isolated user space 
and do not need to match the host OS. 
Your choice of base image should be driven by runtime compatibility, performance, and observability—not host alignment.

## Base Image Comparison

| Base Image                          | OS Base     | libc   | Size     | JVM Compatibility       | Observability            | Best For                          |
|------------------------------------|-------------|--------|----------|--------------------------|---------------------------|-----------------------------------|
| `eclipse-temurin:17-jre`           | Ubuntu 22.04| glibc  | ~175MB   | ✅ Full HotSpot support   | ✅ JFR, async-profiler, jcmd | General-purpose JVM apps          |
| `debian:bullseye-slim` + `openjdk-17-jre-headless` | Debian 11   | glibc  | ~200MB   | ✅ Full HotSpot support   | ✅ Native interop, GC tuning | Custom runtime layering           |
| `gcr.io/distroless/java17-debian12`| Debian 12   | glibc  | ~110MB   | ✅ Secure, minimal        | ❌ No shell/debug tools     | Hardened production               |
| `alpine:3.19` + `openjdk17-jre`    | Alpine      | musl   | ~120MB   | ⚠️ Limited JIT/native support | ⚠️ Profiling tools may fail | Lightweight sidecars              |

## Recommended Base Image

If you're doing:

- GC benchmarking  
- JIT profiling  
- Native interop (Panama, JNI)  
- Async-profiler or JFR tracing  

Then use a **glibc-based image** such as:

```dockerfile
FROM eclipse-temurin:17-jre
```

----
Alpine is still useful for ultra-lightweight services or sidecars, 
but for JVM internals and observability, glibc-based images offer superior compatibility and performance.
---

### Dockerfile: Java 17 + Eclipse Temurin + Profiling-Ready
```
# Base image: Eclipse Temurin JDK 17 with glibc
FROM eclipse-temurin:17-jre

# Install debugging and observability tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    net-tools \
    iputils-ping \
    dnsutils \
    telnet \
    bash \
    traceroute \
    openssl \
    procps \
    async-profiler && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy prebuilt JAR from Jenkins artifact
COPY mexcellence-service.jar app.jar

# Expose application port
EXPOSE 8080

# JVM tuning for AKS containers
ENTRYPOINT [
  "java",
  "-Djava.security.egd=file:/dev/./urandom",
  "-Dvertx.disableDnsResolver=true",
  "-Djava.net.preferIPv4Stack=true",
  "-XX:+UseG1GC",
  "-XX:MaxGCPauseMillis=200",
  "-XX:+UnlockExperimentalVMOptions",
  "-XX:+UseContainerSupport",
  "-XX:MaxRAMPercentage=75.0",
  "-XX:+HeapDumpOnOutOfMemoryError",
  "-XX:+PreserveFramePointer",
  "-XX:+UnlockDiagnosticVMOptions",
  "-XX:+DebugNonSafepoints",
  "-jar",
  "app.jar"
]
```

### Runtime Considerations for JVM Containers in AKS

### Base Image Selection

Use `eclipse-temurin:17-jre` for:

- Full glibc compatibility
- Reliable JIT and GC behavior
- Support for profiling tools like `async-profiler`, `jcmd`, `jmap`, and JFR

### JVM Tuning Flags

| Flag | Purpose |
|------|---------|
| `-XX:+UseContainerSupport` | Enables container-aware memory limits |
| `-XX:MaxRAMPercentage=75.0` | Caps heap usage relative to container memory |
| `-XX:+PreserveFramePointer` | Required for `async-profiler` stack traces |
| `-XX:+UnlockDiagnosticVMOptions` | Enables advanced diagnostics |
| `-XX:+DebugNonSafepoints` | Improves profiling accuracy |

### Debug Tools Included

- `async-profiler`: Flame graphs and CPU sampling
- `procps`: `top`, `ps`, memory inspection
- `telnet`, `dig`, `traceroute`: Network diagnostics
- `openssl`, `curl`, `wget`: TLS and HTTP inspection

### Deployment Notes

- Use `readinessProbe` and `livenessProbe` in Helm charts
- Mount `/tmp` or `/app/profiler` for flamegraph output
- Enable `JFR` via `-XX:StartFlightRecording=...` if needed

## Inspect OS from Inside the Pod

Run this command to open a shell inside the pod:

        kubectl exec -it <pod-name> -- /bin/sh

Then inside the shell, run:

    cat /etc/os-release

This will output something like:

    NAME="Debian GNU/Linux"
    VERSION="11 (bullseye)"
    ID=debian

If /bin/sh doesn't work, try /bin/bash depending on the image.

### If you want the OS of the host node (not the container), run:

```
kubectl get node $(kubectl get pod <pod-name> -o jsonpath='{.spec.nodeName}') -o jsonpath='{.status.nodeInfo.osImage}'
```

