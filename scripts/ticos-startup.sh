#!/bin/bash

# TicOS startup script
# Main entry point that checks network and launches appropriate application

LOG_FILE="/var/log/ticos-startup.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_message "TicOS startup script initiated"

# Wait a bit for network interfaces to initialize
sleep 3

# Check network connectivity
if /usr/local/bin/network-check.sh; then
    log_message "Network detected, launching Remmina in full-screen mode"
    
    # Launch Remmina in full-screen kiosk mode
    # The -k flag enables kiosk mode (full screen, no decorations)
    remmina --kiosk
    
    EXIT_CODE=$?
    log_message "Remmina exited with code: $EXIT_CODE"
else
    log_message "Network not detected, launching xterm for configuration"
    
    # Launch xterm for manual network configuration
    xterm -maximized -title "TicOS Network Configuration" -e bash -c '
        echo "==================================="
        echo "    TicOS Network Configuration"
        echo "==================================="
        echo ""
        echo "Network not detected. Please configure your network connection."
        echo ""
        echo "Available commands:"
        echo "  - sudo dhclient eth0    : Get IP via DHCP"
        echo "  - sudo ip addr          : Show network interfaces"
        echo "  - sudo systemctl restart networking : Restart network service"
        echo "  - nmtui                 : Network Manager TUI (if available)"
        echo ""
        echo "After configuring network, type 'exit' to restart TicOS."
        echo ""
        /bin/bash
    '
    
    log_message "xterm closed, restarting TicOS startup"
    # Restart the startup script to check network again
    exec /usr/local/bin/ticos-startup.sh
fi

# System halts when the application exits
log_message "Application closed, shutting down system"
sudo /sbin/poweroff
