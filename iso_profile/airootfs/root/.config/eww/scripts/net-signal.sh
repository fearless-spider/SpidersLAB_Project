#!/bin/sh
# Signal strength: Wi-Fi quality or wired = 100
iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')

if [ -z "$iface" ]; then
    echo "0"
    exit 0
fi

# Wireless
if iw dev "$iface" info >/dev/null 2>&1; then
    qual=$(iw dev "$iface" station dump 2>/dev/null | awk '/signal:/{print $2; exit}')
    if [ -n "$qual" ]; then
        # Convert dBm to percentage (-30=100%, -90=0%)
        dbm=${qual%% *}
        pct=$(( (dbm + 90) * 100 / 60 ))
        [ "$pct" -gt 100 ] && pct=100
        [ "$pct" -lt 0 ] && pct=0
        echo "$pct"
    else
        echo "0"
    fi
else
    # Wired = full signal
    echo "100"
fi
