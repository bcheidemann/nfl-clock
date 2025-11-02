#!/bin/bash
set -e

MAX_ATTEMPTS=25
DELAY=1

for ((i=1; i<=MAX_ATTEMPTS; i++)); do
    echo "[$i/$MAX_ATTEMPTS] Checking network connection..."

    status=$(sudo nmcli networking connectivity check 2>/dev/null || echo "none")

    echo "[$i/$MAX_ATTEMPTS] connectivity = $status"

    if [ "$status" = "full" ]; then
        echo "✅ Internet connection detected. Launching nfl-clock..."
        sleep 3
        ../src-tauri/target/release/bundle/appimage/nfl-clock_0.1.0_aarch64.AppImage
        exit 0
    fi

    if [ "$i" -lt "$MAX_ATTEMPTS" ]; then
        sleep "$DELAY"
    fi
done

echo "❌ No network connection after $MAX_ATTEMPTS attempts."

read -p "Please configure a network connection. Once the network connection is configured, press enter to continue."

for ((i=1; i<=MAX_ATTEMPTS; i++)); do
    echo "[$i/$MAX_ATTEMPTS] Waiting for connection..."

    status=$(sudo nmcli networking connectivity check 2>/dev/null || echo "none")

    echo "[$i/$MAX_ATTEMPTS] connectivity = $status"

    if [ "$status" = "full" ]; then
        echo "✅ Internet connection detected. Launching nfl-clock..."
        sleep 3;
        ../src-tauri/target/release/bundle/appimage/nfl-clock_0.1.0_aarch64.AppImage
        exit 0
    fi

    if [ "$i" -lt "$MAX_ATTEMPTS" ]; then
        sleep "$DELAY"
    fi
done

echo "❌ No network connection after $MAX_ATTEMPTS attempts. Exiting..."

sleep 3

exit 1
