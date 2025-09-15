# Base image: Eclipse Temurin JDK 21 with glibc
FROM eclipse-temurin:21-jre

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
    procps && \
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
