#!/bin/bash

# ==============================================
# Run Sequence
# Step 1: Create Service file
# sudo nano /etc/systemd/system/jvm-auto.service

#===============file content started==================

## [Unit]
##Description=JVM Auto Diagnostic Collector
## [Service]
## Type=oneshot
## ExecStart=/home/app/collect_jvm_auto.sh local auto

#===================ended==============

# Step 2 : Create Timer File
# sudo nano /etc/systemd/system/jvm-auto.timer

#===============file content started==================

## [Unit]
## Description=Run JVM Auto Diagnostic every hour

## [Timer]
## OnCalendar=hourly
## Persistent=true

## [Install]
## WantedBy=timers.target
#===============file content ended ==================

# Step 3: Enable & Start

## sudo systemctl daemon-reload
## sudo systemctl enable jvm-auto.timer
## sudo systemctl start jvm-auto.timer

# ==============================================

# Step 4: Check Status

## systemctl list-timers

# ============================

MODE=$1
TARGET=$2
NAMESPACE=$3
ALERTMANAGER_URL=$4

# OUTPUT DIRECTORY
BASE_DIR="/c/jvm_diagnostics"

mkdir -p $BASE_DIR

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "Starting JVM Auto Diagnostic..."
echo "Output Directory: $BASE_DIR"

# ==============================================
# AUTO-DETECT JAVA PID (LOCAL)
# ==============================================
if [ "$MODE" == "local" ]; then
  PID=$(jps | grep -v Jps | awk '{print $1}' | head -1)
  echo "Detected Java PID: $PID"
fi

if [ "$MODE" == "k8s" ]; then
  PID=1
  echo "Using PID 1 inside container"
fi

# ==============================================
# FUNCTION: Get Old Gen Usage %
# ==============================================
get_old_gen_usage() {
  OLD=$(jstat -gc $PID | awk 'NR==2 {print $4+$6}')
  MAX=$(jstat -gccapacity $PID | awk 'NR==2 {print $4+$6}')
  USAGE=$(echo "scale=2; ($OLD/$MAX)*100" | bc)
  echo $USAGE
}

OLD_USAGE=$(get_old_gen_usage)
echo "Old Gen Usage: $OLD_USAGE %"

THRESHOLD=80

if (( $(echo "$OLD_USAGE < $THRESHOLD" | bc -l) )); then
  echo "Old Gen below threshold. Exiting."
  exit 0
fi

echo "Old Gen above 80%! Collecting diagnostics..."

# ==============================================
# THREAD DUMPS (5 dumps)
# ==============================================
for i in {1..5}; do
  jstack -l $PID > $BASE_DIR/thread_dump_${TIMESTAMP}_$i.txt

  # Windows CPU snapshot using WMIC
  wmic process where processid=$PID get ProcessId,KernelModeTime,UserModeTime > \
  $BASE_DIR/cpu_snapshot_${TIMESTAMP}_$i.txt

  sleep 10
done

# ==============================================
# HEAP DUMP
# ==============================================
HEAP_FILE="$BASE_DIR/heap_dump_${TIMESTAMP}.hprof"

jmap -dump:live,format=b,file="$HEAP_FILE" $PID

# Compress (if gzip exists)
if command -v gzip &> /dev/null
then
    gzip "$HEAP_FILE"
fi

# ==============================================
# GC LOG COPY (If Exists)
# ==============================================
GC_LOG_PATH="C:/logs/gc.log"

if [ -f "$GC_LOG_PATH" ]; then
  cp "$GC_LOG_PATH" "$BASE_DIR/gc_${TIMESTAMP}.log"
fi

# ==============================================
# ALERTMANAGER INTEGRATION
# ==============================================
if [ ! -z "$ALERTMANAGER_URL" ]; then
  curl -X POST $ALERTMANAGER_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"alerts\": [{
      \"status\": \"firing\",
      \"labels\": {
        \"alertname\": \"JVMOldGenHigh\",
        \"severity\": \"critical\"
      },
      \"annotations\": {
        \"description\": \"Old Gen > 80%. Diagnostics collected.\",
        \"summary\": \"JVM Auto Diagnostic Triggered\"
      }
    }]
  }"
fi

echo "Diagnostics completed."
echo "All files stored in: $BASE_DIR"

------------

