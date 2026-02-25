#!/bin/bash

# -------- CONFIG --------

NAMESPACE="default"
APP_LABEL="app=spring-app"
CONTAINER_NAME=""
OUTPUT_DIR="./thread_dumps_$(date +%Y%m%d_%H%M%S)"
INTERVAL=5
COUNT=3

# ------------------------

mkdir -p "$OUTPUT_DIR"

echo "Namespace: $NAMESPACE"
echo "Label: $APP_LABEL"
echo "Output: $OUTPUT_DIR"
echo ""

# Get pod list

PODS=$(kubectl get pods -n $NAMESPACE -l $APP_LABEL -o jsonpath='{.items[*].metadata.name}')

if [ -z "$PODS" ]; then
echo "No pods found!"
exit 1
fi

echo "Pods found:"
echo "$PODS"
echo ""

for pod in $PODS; do
echo "Processing pod: $pod"

for ((i=1; i<=COUNT; i++)); do
FILE="$OUTPUT_DIR/${pod}*dump*${i}.txt"

```
echo "  Collecting dump $i..."

if [ -z "$CONTAINER_NAME" ]; then
  kubectl exec -n $NAMESPACE $pod -- \
    sh -c 'PID=$(pgrep -f java | head -1); jstack $PID' > "$FILE"
else
  kubectl exec -n $NAMESPACE $pod -c $CONTAINER_NAME -- \
    sh -c 'PID=$(pgrep -f java | head -1); jstack $PID' > "$FILE"
fi

sleep $INTERVAL
```

done
done

echo ""
echo "Collection complete!"
echo ""

# -------- ANALYSIS --------

echo "Starting analysis..."
REPORT="$OUTPUT_DIR/analysis.txt"

echo "Thread Dump Analysis Report" > $REPORT
echo "===========================" >> $REPORT
echo "" >> $REPORT

for file in $OUTPUT_DIR/*dump*.txt; do
echo "Analyzing $file"

echo "File: $file" >> $REPORT
echo "----------------------" >> $REPORT

echo "Total Threads:" >> $REPORT
grep -c "nid=" "$file" >> $REPORT

echo "BLOCKED Threads:" >> $REPORT
grep -c "java.lang.Thread.State: BLOCKED" "$file" >> $REPORT

echo "WAITING Threads:" >> $REPORT
grep -c "java.lang.Thread.State: WAITING" "$file" >> $REPORT

echo "RUNNABLE Threads:" >> $REPORT
grep -c "java.lang.Thread.State: RUNNABLE" "$file" >> $REPORT

echo "Deadlock check:" >> $REPORT
grep -i "deadlock" "$file" >> $REPORT

echo "" >> $REPORT
done

echo "Analysis complete!"
echo "Report: $REPORT"
