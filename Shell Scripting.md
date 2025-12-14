## 1. Find and kill all zombie processes

Zombies can’t be killed directly; you kill their parent.

``` bash
#!/bin/bash

find_zombies() {
  ps -eo pid,ppid,state,cmd | awk '$3=="Z" {print $1, $2, $4}'
}

kill_zombie_parents() {
  ps -eo ppid,state | awk '$2=="Z" {print $1}' | sort -u | while read ppid; do
    echo "Killing parent PID: $ppid"
    kill -9 "$ppid"
  done
}

find_zombies
kill_zombie_parents

```

--------

## 2. Find top 10 biggest files and write to a file

``` bash

#!/bin/bash

OUTPUT="largest_files.txt"

find / -type f -exec du -h {} + 2>/dev/null \
  | sort -hr | head -10 > "$OUTPUT"

echo "Top 10 files written to $OUTPUT"


```

--------

## 3. Gracefully unmount a disk

``` bash
#!/bin/bash

MOUNT_POINT=$1

if mountpoint -q "$MOUNT_POINT"; then
  fuser -km "$MOUNT_POINT"
  umount "$MOUNT_POINT" && echo "Unmounted successfully"
else
  echo "Not a mount point"
fi

```


--------

## 4. Shell script to send email

``` bash 
#!/bin/bash

TO="admin@example.com"
SUBJECT="Server Alert"
BODY="Disk usage exceeded threshold"

echo "$BODY" | mail -s "$SUBJECT" "$TO"

```

> Requires mailx / sendmail.


--------

## 5. Monitor CPU, Memory, Disk + alert

``` bash
#!/bin/bash

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
MEM=$(free | awk '/Mem/ {printf "%.0f", $3/$2 * 100}')
DISK=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

OUTPUT="system_usage.txt"

printf "CPU%%\tMEM%%\tDISK%%\n%s\t%s\t%s\n" "$CPU" "$MEM" "$DISK" > "$OUTPUT"

if (( CPU > 80 || MEM > 80 || DISK > 80 )); then
  mail -s "System Alert" admin@example.com < "$OUTPUT"
fi
```

--------

## 6. Find files created in last N days (with size)

``` bash
#!/bin/bash

DAYS=$1

find . -type f -mtime -"$DAYS" -exec ls -lh {} \;


Date range version

find . -type f -newermt "2025-01-01" ! -newermt "2025-01-10"
```

--------

## 7. Automate Linux user creation + SSH access

``` bash

#!/bin/bash

USER=$1
SSH_KEY=$2

useradd -m "$USER"
mkdir -p /home/$USER/.ssh
echo "$SSH_KEY" > /home/$USER/.ssh/authorized_keys

chown -R $USER:$USER /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys

echo "User $USER created with SSH access"

```

--------

## 8. List logged-in users by date

``` bash

#!/bin/bash

OUTPUT="logged_users.txt"

last | awk '{print $1, $4, $5, $6}' > "$OUTPUT"

```

--------

## 9. Copy files recursively to remote hosts

``` bash
#!/bin/bash

SRC_DIR="/data"
DEST="user@remote:/backup"

rsync -avz "$SRC_DIR" "$DEST"
```

--------

## 10. Failed login attempts by IP + location

``` bash
#!/bin/bash

grep "Failed password" /var/log/auth.log \
| awk '{print $(NF-3)}' \
| sort | uniq -c | sort -nr > failed_ips.txt

while read count ip; do
  geoiplookup "$ip"
done < failed_ips.txt
```

> 📌 Requires geoiplookup.

--------

## 11. Parse log & forward value with timestamp

``` bash
#!/bin/bash

grep "ERROR" app.log | awk '{print strftime("%F %T"), $0}' >> error_output.log

```

--------


## 12. Log rotation & compression

``` bash
#!/bin/bash

LOG_DIR="/var/log/myapp"

find "$LOG_DIR" -type f -name "*.log" -mtime +7 -exec gzip {} \;
find "$LOG_DIR" -type f -name "*.gz" -mtime +30 -delete

```

--------

## 13. Check URLs and alert if down

``` bash
#!/bin/bash

URLS=("https://google.com" "https://example.com")

for url in "${URLS[@]}"; do
  if ! curl -s --head "$url" | grep "200 OK" > /dev/null; then
    echo "$url is DOWN" | mail -s "URL Alert" admin@example.com
  fi
done

```

--------

## 14. Automate security patching on servers

``` bash
#!/bin/bash

SERVERS=("server1" "server2")

for server in "${SERVERS[@]}"; do
  ssh "$server" "sudo apt update && sudo apt upgrade -y"
done
```

> (RHEL version → yum update -y)

--------

