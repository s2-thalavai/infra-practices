#!/bin/bash

# ==============================
# Advanced JVM Diagnostic Script
# Supports: VM, Docker, Kubernetes
# ==============================

MODE=$1        # local | docker | k8s
TARGET=$2      # PID or container/pod name
S3_BUCKET=$3   # optional
WEBHOOK_URL=$4 # optional

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="jvm_diag_${TARGET}_${TIMESTAMP}"
mkdir -p $OUTPUT_DIR

echo "Mode: $MODE"
echo "Target: $TARGET"
echo "Output Dir: $OUTPUT_DIR"

# ==============================
# Function: Thread Dumps (3x)
# ==============================
collect_thread_dumps() {
  echo "Collecting 3 thread dumps (10 sec apart)..."
  for i in 1 2 3; do
    jstack -l $TARGET > $OUTPUT_DIR/thread_dump_$i.txt
    sleep 10
  done
}

# ==============================
# Function: Heap Dump (Compressed)
# ==============================
collect_heap_dump() {
  echo "Collecting Heap Dump..."
  jmap -dump:live,format=b,file=$OUTPUT_DIR/heap_dump.hprof $TARGET

  echo "Compressing Heap Dump..."
  gzip $OUTPUT_DIR/heap_dump.hprof
}

# ==============================
# Function: JVM Stats
# ==============================
collect_jvm_stats() {
  jcmd $TARGET VM.flags > $OUTPUT_DIR/jvm_flags.txt
  jcmd $TARGET VM.system_properties > $OUTPUT_DIR/system_properties.txt
  jmap -heap $TARGET > $OUTPUT_DIR/heap_info.txt
  jmap -histo:live $TARGET > $OUTPUT_DIR/class_histogram.txt
  jstat -gc $TARGET > $OUTPUT_DIR/gc_stats.txt
}

# ==============================
# LOCAL MODE
# ==============================
if [ "$MODE" == "local" ]; then
  collect_thread_dumps
  collect_jvm_stats
  collect_heap_dump
fi

# ==============================
# DOCKER MODE
# ==============================
if [ "$MODE" == "docker" ]; then
  echo "Running inside Docker container..."
  docker exec $TARGET jstack -l 1 > $OUTPUT_DIR/thread_dump_1.txt
  sleep 10
  docker exec $TARGET jstack -l 1 > $OUTPUT_DIR/thread_dump_2.txt
  sleep 10
  docker exec $TARGET jstack -l 1 > $OUTPUT_DIR/thread_dump_3.txt

  docker exec $TARGET jmap -dump:live,format=b,file=/tmp/heap_dump.hprof 1
  docker cp $TARGET:/tmp/heap_dump.hprof $OUTPUT_DIR/
  gzip $OUTPUT_DIR/heap_dump.hprof
fi

# ==============================
# KUBERNETES MODE
# ==============================
if [ "$MODE" == "k8s" ]; then
  echo "Running inside Kubernetes pod..."

  kubectl exec $TARGET -- jstack -l 1 > $OUTPUT_DIR/thread_dump_1.txt
  sleep 10
  kubectl exec $TARGET -- jstack -l 1 > $OUTPUT_DIR/thread_dump_2.txt
  sleep 10
  kubectl exec $TARGET -- jstack -l 1 > $OUTPUT_DIR/thread_dump_3.txt

  kubectl exec $TARGET -- jmap -dump:live,format=b,file=/tmp/heap_dump.hprof 1
  kubectl cp $TARGET:/tmp/heap_dump.hprof $OUTPUT_DIR/heap_dump.hprof
  gzip $OUTPUT_DIR/heap_dump.hprof
fi

# ==============================
# TAR ARCHIVE
# ==============================
echo "Creating archive..."
tar -czf ${OUTPUT_DIR}.tar.gz $OUTPUT_DIR

# ==============================
# Upload to S3 (Optional)
# ==============================
if [ ! -z "$S3_BUCKET" ]; then
  echo "Uploading to S3..."
  aws s3 cp ${OUTPUT_DIR}.tar.gz s3://$S3_BUCKET/
fi

# ==============================
# Alert Integration (Optional)
# ==============================
if [ ! -z "$WEBHOOK_URL" ]; then
  echo "Sending Alert..."
  curl -X POST -H 'Content-type: application/json' \
  --data "{\"text\":\"JVM Diagnostics collected for $TARGET at $TIMESTAMP\"}" \
  $WEBHOOK_URL
fi

echo "Diagnostics Complete."
echo "Archive: ${OUTPUT_DIR}.tar.gz"
