#!/bin/bash

# Network detection script for TicOS
# Checks if network is available via Ethernet

MAX_ATTEMPTS=10
ATTEMPT=0

# Try to detect default gateway first, fall back to Google DNS
DEFAULT_GW=$(ip route | grep default | awk '{print $3}' | head -n1)
TEST_HOST="${DEFAULT_GW:-8.8.8.8}"

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    # Check if any network interface (except lo) has an IP address
    if ip addr show | grep -E "inet .* scope global" | grep -v "127.0.0.1" > /dev/null; then
        # Try to ping the test host to verify connectivity
        if ping -c 1 -W 2 "$TEST_HOST" > /dev/null 2>&1; then
            echo "Network is available"
            exit 0
        fi
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
    sleep 1
done

echo "Network is not available"
exit 1
