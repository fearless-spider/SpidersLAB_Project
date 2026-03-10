#!/bin/sh
# Disk I/O: returns human-readable read/write rate for NVMe
direction="$1"
dev="nvme0n1"
stat_file="/sys/block/${dev}/stat"

if [ ! -f "$stat_file" ]; then
    echo "0 B/s"
    exit 0
fi

# stat fields: 1=reads 2=merged 3=sectors_read ... 5=writes 6=merged 7=sectors_written
if [ "$direction" = "read" ]; then
    idx=3
else
    idx=7
fi

s1=$(awk -v i="$idx" '{print $i}' "$stat_file")
sleep 1
s2=$(awk -v i="$idx" '{print $i}' "$stat_file")

# Each sector = 512 bytes
rate=$(( (s2 - s1) * 512 ))

if [ "$rate" -gt 1048576 ]; then
    whole=$(( rate / 1048576 ))
    frac=$(( (rate % 1048576) * 10 / 1048576 ))
    printf "%d.%d MB/s" "$whole" "$frac"
elif [ "$rate" -gt 1024 ]; then
    printf "%d KB/s" "$(( rate / 1024 ))"
else
    printf "%d B/s" "$rate"
fi
