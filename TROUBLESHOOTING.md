# TicOS Troubleshooting Guide

This guide helps you diagnose and fix common issues with TicOS.

## Build Issues

### Problem: Packer plugin not found
**Error**: `Missing plugins: github.com/solo-io/arm-image`

**Solution**:
```bash
packer init .
```

### Problem: Base image download fails
**Error**: Download timeout or checksum mismatch

**Solutions**:
1. Check your internet connection
2. Update the URL in `packer.pkr.hcl` to a working mirror
3. Update the checksum if using a different image version

### Problem: QEMU not available
**Error**: `qemu-aarch64-static: command not found`

**Solution**:
```bash
# Debian/Ubuntu
sudo apt-get install qemu-user-static qemu-system-arm

# RHEL/CentOS/Fedora
sudo yum install qemu-user-static
```

### Problem: Out of disk space during build
**Error**: `No space left on device`

**Solution**:
- Ensure at least 10GB of free space
- Clean up old builds: `make clean`
- Remove Docker images/containers if not needed

## Runtime Issues

### Problem: Black screen after boot
**Symptoms**: Monitor is black, no activity

**Diagnosis**:
1. Wait 30 seconds - system may still be booting
2. Check if you can SSH into the device
3. Check the TTY by pressing Ctrl+Alt+F2

**Solutions**:
```bash
# SSH into the device and check logs
sudo journalctl -u ticos.service
cat /var/log/ticos-startup.log
```

### Problem: X11 fails to start
**Error in logs**: `Fatal server error: no screens found`

**Solutions**:
1. Check HDMI connection
2. Try a different HDMI port
3. Boot into console (add `nomodeset` to `/boot/cmdline.txt`)
4. Check X11 logs: `/var/log/Xorg.0.log`

### Problem: Network not detected
**Symptoms**: xterm opens instead of Remmina

**Diagnosis**:
```bash
# Check network interfaces
ip addr show

# Check network connectivity
ping -c 3 8.8.8.8

# Check DHCP client
sudo systemctl status dhcpcd
```

**Solutions**:
1. Verify Ethernet cable is connected
2. Try manually getting DHCP:
   ```bash
   sudo dhclient eth0
   ```
3. Check router DHCP settings
4. Try static IP configuration:
   ```bash
   sudo ip addr add 192.168.1.100/24 dev eth0
   sudo ip route add default via 192.168.1.1
   ```

### Problem: Network detected but no internet
**Symptoms**: Network check passes but can't connect to remote desktop

**Solutions**:
1. Check DNS:
   ```bash
   cat /etc/resolv.conf
   echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
   ```
2. Check default gateway:
   ```bash
   ip route show
   ```
3. Test connectivity to remote host:
   ```bash
   ping <remote_desktop_ip>
   ```

### Problem: Remmina doesn't start
**Error in logs**: `remmina: command not found`

**Solutions**:
```bash
# Reinstall Remmina
sudo apt-get update
sudo apt-get install --reinstall remmina remmina-plugin-rdp remmina-plugin-vnc
```

### Problem: Remmina crashes immediately
**Symptoms**: Remmina starts then closes, system shuts down

**Diagnosis**:
```bash
# Run Remmina manually to see errors
DISPLAY=:0 remmina --kiosk
```

**Solutions**:
1. Check Remmina config: `~/.config/remmina/remmina.pref`
2. Remove corrupted config and restart:
   ```bash
   mv ~/.config/remmina ~/.config/remmina.bak
   ```

### Problem: No connection profiles available
**Symptoms**: Remmina starts but shows no connections

**Solutions**:
1. Create a connection file in `~/.local/share/remmina/`
2. Use Remmina GUI to create connections (before enabling kiosk mode)
3. Copy example files from the repository

### Problem: Can't connect to remote desktop
**Symptoms**: Remmina shows connection error

**Diagnosis**:
1. Test network connectivity to remote host:
   ```bash
   ping <remote_host>
   telnet <remote_host> 3389  # For RDP
   telnet <remote_host> 5900  # For VNC
   ```

**Solutions**:
1. Verify remote desktop server is running
2. Check firewall rules on remote host
3. Verify credentials in connection file
4. Try connection from another computer

### Problem: Keyboard not working in Remmina
**Symptoms**: Can't type in remote session

**Solutions**:
1. Check keyboard is properly connected
2. Test keyboard in xterm (network config screen)
3. Check Remmina keyboard settings in connection file
4. Verify `grab_keyboard=true` in `remmina.pref`

### Problem: Display resolution incorrect
**Symptoms**: Screen is too large/small or distorted

**Solutions**:
1. Edit `scripts/xinitrc` and add:
   ```bash
   xrandr --output HDMI-1 --mode 1920x1080
   ```
2. Check available resolutions:
   ```bash
   DISPLAY=:0 xrandr
   ```
3. Update connection file resolution settings

### Problem: System doesn't shutdown after Remmina exits
**Symptoms**: System stays on after closing Remmina

**Diagnosis**:
```bash
# Check if poweroff command works
sudo /sbin/poweroff
```

**Solutions**:
1. Check logs: `cat /var/log/ticos-startup.log`
2. Verify pi user has sudo permissions for poweroff
3. Check systemd shutdown logs:
   ```bash
   sudo journalctl -b -u systemd-poweroff
   ```

## SD Card Issues

### Problem: SD card corruption
**Symptoms**: Boot fails, filesystem errors

**Prevention**:
- Always use clean shutdown (don't unplug power)
- Use high-quality SD cards (Class 10 or better)
- Consider read-only root filesystem for production

**Recovery**:
1. Flash a fresh image to SD card
2. Use fsck to repair filesystem (from another Linux system)

### Problem: SD card is read-only
**Symptoms**: Can't write to filesystem

**Solutions**:
```bash
# Remount as read-write
sudo mount -o remount,rw /

# Check SD card for errors (from another system)
sudo fsck /dev/sdX1
```

## Performance Issues

### Problem: Slow boot time
**Symptoms**: Takes >60 seconds to boot

**Solutions**:
1. Check which services are slow:
   ```bash
   systemd-analyze blame
   ```
2. Disable additional services:
   ```bash
   sudo systemctl disable <service_name>
   ```
3. Use faster SD card

### Problem: Remote desktop is laggy
**Symptoms**: Slow screen updates, input lag

**Solutions**:
1. Reduce color depth in connection settings
2. Disable wallpaper/themes on remote desktop
3. Check network bandwidth
4. Reduce screen resolution

## Hardware Issues

### Problem: Pi doesn't boot at all
**Symptoms**: No LEDs, no HDMI output

**Solutions**:
1. Check power supply (needs 5V 3A for Pi 5)
2. Try different SD card
3. Check for firmware updates
4. Test with different power cable

### Problem: Ethernet not working
**Symptoms**: No link lights on Ethernet port

**Solutions**:
1. Try different Ethernet cable
2. Try different port on switch/router
3. Check if Ethernet is disabled in firmware
4. Test with a known-good network connection

## Getting Help

### Collecting Debug Information

When asking for help, include:

```bash
# System information
uname -a
cat /etc/os-release

# Service status
sudo systemctl status ticos.service

# Logs
cat /var/log/ticos-startup.log
sudo journalctl -u ticos.service -n 50

# Network status
ip addr show
ip route show
cat /etc/resolv.conf

# Remmina status
remmina --version
ls -la ~/.local/share/remmina/
```

### Where to Get Help

1. Check this troubleshooting guide
2. Review the main README.md
3. Check GitHub issues for similar problems
4. Create a new GitHub issue with debug information
5. Consult Raspberry Pi forums
6. Check Remmina documentation

## Advanced Diagnostics

### Enabling Debug Mode

Edit `/usr/local/bin/ticos-startup.sh` and add:
```bash
set -x  # Enable debug output
```

### Manual Testing

Boot into console mode and test components individually:
```bash
# Start X11 manually
startx

# In another terminal (SSH or Ctrl+Alt+F2)
DISPLAY=:0 remmina --kiosk

# Test network
ping -c 5 8.8.8.8
```

### Checking for Common Misconfigurations

```bash
# Verify files exist and have correct permissions
ls -la /usr/local/bin/ticos-startup.sh
ls -la /usr/local/bin/network-check.sh
ls -la /home/pi/.xinitrc
ls -la /etc/systemd/system/ticos.service

# Verify service is enabled
sudo systemctl is-enabled ticos.service

# Check for syntax errors in scripts
bash -n /usr/local/bin/ticos-startup.sh
bash -n /usr/local/bin/network-check.sh
```

## Known Issues

### Issue: First boot may be slow
- **Cause**: Raspberry Pi OS expands filesystem on first boot
- **Impact**: First boot takes 2-3 minutes
- **Workaround**: Wait patiently, subsequent boots are faster

### Issue: HDMI hot-plug not working
- **Cause**: X11 started before HDMI connection detected
- **Impact**: No display if HDMI connected after boot
- **Workaround**: Always connect HDMI before powering on

## Additional Resources

- [Raspberry Pi Documentation](https://www.raspberrypi.org/documentation/)
- [Remmina Wiki](https://gitlab.com/Remmina/Remmina/-/wikis/home)
- [Packer Documentation](https://www.packer.io/docs)
- [Systemd Documentation](https://systemd.io/)

---

If you've found a bug or have a solution not listed here, please contribute by opening a pull request!
