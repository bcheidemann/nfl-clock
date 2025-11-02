#!/bin/bash
set -e

MAX_ATTEMPTS=5
DELAY=2

for ((i=1; i<=MAX_ATTEMPTS; i++)); do
    echo "[$i/$MAX_ATTEMPTS] Checking network connection..."

    status=$(sudo nmcli networking connectivity check 2>/dev/null || echo "none")

    echo "[$i/$MAX_ATTEMPTS] connectivity = $status"

    if [ "$status" = "full" ]; then
        echo "✅ Internet connection detected."
        exit 0
    fi

    if [ "$i" -lt "$MAX_ATTEMPTS" ]; then
        sleep "$DELAY"
    fi
done

echo "❌ No network connection after $MAX_ATTEMPTS attempts. Launching raspi-config..."
sudo raspi-config

for ((i=1; i<=MAX_ATTEMPTS; i++)); do
    echo "[$i/$MAX_ATTEMPTS] Waiting for connection..."

    status=$(sudo nmcli networking connectivity check 2>/dev/null || echo "none")

    echo "[$i/$MAX_ATTEMPTS] connectivity = $status"

    if [ "$status" = "full" ]; then
        echo "✅ Internet connection detected."
        sleep 2;
        exit 0
    fi

    if [ "$i" -lt "$MAX_ATTEMPTS" ]; then
        sleep "$DELAY"
    fi
done

echo "❌ No network connection after $MAX_ATTEMPTS attempts. Exiting..."

sleep 5
exit 1
