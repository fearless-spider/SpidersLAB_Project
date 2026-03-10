#!/bin/sh
# Network traffic: returns human-readable rate (KB/s or MB/s)
direction="$1"
iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')

if [ -z "$iface" ]; then
    echo "0 B/s"
    exit 0
fi

if [ "$direction" = "down" ]; then
    field="/sys/class/net/${iface}/statistics/rx_bytes"
else
    field="/sys/class/net/${iface}/statistics/tx_bytes"
fi

[ ! -f "$field" ] && echo "0 B/s" && exit 0

b1=$(cat "$field")
sleep 1
b2=$(cat "$field")

rate=$(( (b2 - b1) ))

if [ "$rate" -gt 1048576 ]; then
    printf "%.1f MB/s" "$(echo "scale=1; $rate / 1048576" | bc)"
elif [ "$rate" -gt 1024 ]; then
    printf "%.0f KB/s" "$(echo "scale=0; $rate / 1024" | bc)"
else
    printf "%d B/s" "$rate"
fi
