#!/bin/bash

# ==============================================
# Self-Triggering JVM Diagnostic Collector
# ==============================================

MODE=$1                # local | k8s
TARGET=$2              # pod name (k8s) or auto (local)
NAMESPACE=$3           # optional (k8s)
ALERTMANAGER_URL=$4    # optional

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="jvm_auto_diag_${TIMESTAMP}"
mkdir -p $OUTPUT_DIR

echo "Starting JVM Auto Diagnostic..."

# ==============================================
# AUTO-DETECT JAVA PID (LOCAL)
# ==============================================
if [ "$MODE" == "local" ]; then
  PID=$(jps | grep -v Jps | awk '{print $1}' | head -1)
  echo "Detected Java PID: $PID"
fi

# ==============================================
# AUTO-DETECT JAVA PID (K8S)
# ==============================================
if [ "$MODE" == "k8s" ]; then
  echo "Namespace: $NAMESPACE"
  PID=1
  echo "Using PID 1 inside container"
fi

# ==============================================
# FUNCTION: Get Old Gen Usage %
# ==============================================
get_old_gen_usage() {
  if [ "$MODE" == "local" ]; then
    OLD=$(jstat -gc $PID | awk 'NR==2 {print $4+$6}')
    MAX=$(jstat -gccapacity $PID | awk 'NR==2 {print $4+$6}')
  else
    OLD=$(kubectl exec -n $NAMESPACE $TARGET -- jstat -gc 1 | awk 'NR==2 {print $4+$6}')
    MAX=$(kubectl exec -n $NAMESPACE $TARGET -- jstat -gccapacity 1 | awk 'NR==2 {print $4+$6}')
  fi

  USAGE=$(echo "scale=2; ($OLD/$MAX)*100" | bc)
  echo $USAGE
}

# ==============================================
# CHECK OLD GEN THRESHOLD
# ==============================================
OLD_USAGE=$(get_old_gen_usage)
echo "Old Gen Usage: $OLD_USAGE %"

THRESHOLD=80

if (( $(echo "$OLD_USAGE < $THRESHOLD" | bc -l) )); then
  echo "Old Gen below threshold. Exiting."
  exit 0
fi

echo "Old Gen above 80%! Triggering diagnostics..."

# ==============================================
# THREAD DUMPS WITH CPU SNAPSHOT
# ==============================================
for i in {1..5}; do
  if [ "$MODE" == "local" ]; then
    jstack -l $PID > $OUTPUT_DIR/thread_dump_$i.txt
    top -b -n 1 -p $PID > $OUTPUT_DIR/cpu_snapshot_$i.txt
  else
    kubectl exec -n $NAMESPACE $TARGET -- jstack -l 1 > $OUTPUT_DIR/thread_dump_$i.txt
    kubectl exec -n $NAMESPACE $TARGET -- top -b -n 1 > $OUTPUT_DIR/cpu_snapshot_$i.txt
  fi
  sleep 10
done

# ==============================================
# HEAP DUMP + COMPRESS
# ==============================================
if [ "$MODE" == "local" ]; then
  jmap -dump:live,format=b,file=$OUTPUT_DIR/heap_dump.hprof $PID
else
  kubectl exec -n $NAMESPACE $TARGET -- jmap -dump:live,format=b,file=/tmp/heap_dump.hprof 1
  kubectl cp -n $NAMESPACE $TARGET:/tmp/heap_dump.hprof $OUTPUT_DIR/heap_dump.hprof
fi

gzip $OUTPUT_DIR/heap_dump.hprof

# ==============================================
# COLLECT GC LOG (if exists)
# ==============================================
GC_LOG_PATH="/var/log/app/gc.log"

if [ "$MODE" == "local" ]; then
  if [ -f "$GC_LOG_PATH" ]; then
    cp $GC_LOG_PATH $OUTPUT_DIR/
  fi
else
  kubectl cp -n $NAMESPACE $TARGET:$GC_LOG_PATH $OUTPUT_DIR/gc.log 2>/dev/null
fi

# ==============================================
# NODE MEMORY PRESSURE CHECK
# ==============================================
if [ "$MODE" == "k8s" ]; then
  NODE=$(kubectl get pod -n $NAMESPACE $TARGET -o jsonpath='{.spec.nodeName}')
  MEM_PRESSURE=$(kubectl describe node $NODE | grep MemoryPressure)

  echo "Node Memory Status: $MEM_PRESSURE" > $OUTPUT_DIR/node_memory_status.txt
fi

# ==============================================
# CREATE ARCHIVE
# ==============================================
tar -czf ${OUTPUT_DIR}.tar.gz $OUTPUT_DIR

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
echo "Archive: ${OUTPUT_DIR}.tar.gz"
