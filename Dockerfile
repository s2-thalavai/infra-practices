# ---------- Stage 1: Build ----------
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /build

# Copy source code and build
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# ---------- Stage 2: Runtime ----------
FROM alpine:3.19

# Install OpenJDK 21 and debugging tools
RUN apk add --no-cache \
    openjdk21-jre \
    bash \
    busybox-extras \
    iputils \
    net-tools \
    curl \
    bind-tools \
    openssl \
    traceroute \
    wget

# Set working directory
WORKDIR /app

# Copy built JAR from builder stage
COPY --from=builder /build/target/mexcellence-service.jar app.jar

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
