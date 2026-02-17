# TicOS Quick Start Guide

Get TicOS up and running in 5 steps!

## Prerequisites

- Linux computer for building (Ubuntu/Debian recommended)
- Raspberry Pi 5
- microSD card (8GB minimum, 16GB+ recommended, Class 10 or better)
- Ethernet cable and network connection
- HDMI monitor and cable
- USB keyboard (for initial network setup if needed)
- Micro-USB power supply (5V 3A)

## Step 1: Clone Repository

```bash
git clone https://github.com/manoelhc/TicOS.git
cd TicOS
```

## Step 2: Setup Build Environment

```bash
chmod +x setup.sh
./setup.sh
```

This installs Packer and QEMU if not already installed.

## Step 3: Build the Image

```bash
# Initialize Packer plugins
packer init .

# Build the image (takes 15-30 minutes)
packer build packer.pkr.hcl
```

Or use the Makefile:
```bash
make all
```

## Step 4: Flash to SD Card

### Using dd (Linux)
```bash
sudo dd if=ticos-rpi5.img of=/dev/sdX bs=4M status=progress
sync
```
Replace `/dev/sdX` with your SD card device (use `lsblk` to identify).

### Using Raspberry Pi Imager
1. Install [Raspberry Pi Imager](https://www.raspberrypi.org/software/)
2. Choose "Use custom" and select `ticos-rpi5.img`
3. Select your SD card
4. Click "Write"

### Using balenaEtcher
1. Install [balenaEtcher](https://www.balena.io/etcher/)
2. Select `ticos-rpi5.img`
3. Select your SD card
4. Click "Flash"

## Step 5: Boot and Configure

1. **Insert SD card** into Raspberry Pi 5
2. **Connect Ethernet cable** to your network
3. **Connect HDMI monitor**
4. **Power on** the Raspberry Pi

### First Boot Options

**Option A: Network is Available**
- TicOS detects network automatically
- Remmina launches in full-screen mode
- Select or create a remote desktop connection

**Option B: Network Not Available**
- xterm opens with configuration instructions
- Configure network manually:
  ```bash
  sudo dhclient eth0
  ```
- Type `exit` when done
- TicOS retries network detection and launches Remmina

## Creating Remote Desktop Connections

### Method 1: Pre-configure During Build

1. Create a connection file (e.g., `myserver.remmina`):
   ```ini
   [remmina]
   name=My Server
   protocol=RDP
   server=192.168.1.100:3389
   username=myuser
   password=.
   resolution_mode=2
   color_depth=32
   ```

2. Add to `packer.pkr.hcl`:
   ```hcl
   provisioner "file" {
     source      = "myserver.remmina"
     destination = "/home/pi/.local/share/remmina/myserver.remmina"
   }
   ```

3. Rebuild: `packer build packer.pkr.hcl`

### Method 2: Configure After First Boot

1. Press `Ctrl+Alt+F2` to switch to console
2. Login with `pi` / `raspberry`
3. Edit systemd service to disable auto-start:
   ```bash
   sudo systemctl disable ticos.service
   sudo reboot
   ```
4. Login and run:
   ```bash
   startx
   ```
5. Configure Remmina connections via GUI
6. Re-enable auto-start:
   ```bash
   sudo systemctl enable ticos.service
   sudo reboot
   ```

## Default Credentials

⚠️ **Important**: Change default credentials!

- **Username**: `pi`
- **Password**: `raspberry`

Change password:
```bash
passwd
```

## Network Configuration

### Using DHCP (Automatic)
Already configured by default. Just plug in Ethernet.

### Using Static IP
Edit `/etc/dhcpcd.conf`:
```bash
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8
```

Restart networking:
```bash
sudo systemctl restart dhcpcd
```

## Exiting Remmina

- Close all remote desktop sessions in Remmina
- Remmina exits automatically
- System shuts down

To prevent shutdown, modify `/usr/local/bin/ticos-startup.sh` and remove the `poweroff` line.

## Troubleshooting

### Black Screen
- Wait 30 seconds for boot to complete
- Check HDMI connection
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### Network Not Detected
- Verify Ethernet cable is connected
- Check router DHCP is enabled
- Try: `sudo dhclient eth0` in xterm
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### Can't Connect to Remote Desktop
- Verify remote host is accessible: `ping <remote_ip>`
- Check credentials
- Verify RDP/VNC is enabled on remote host
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## Next Steps

- **Read**: [README.md](README.md) for detailed documentation
- **Security**: Review [SECURITY.md](SECURITY.md) before production deployment
- **Customize**: Modify scripts in `scripts/` directory
- **Examples**: Check `examples/` for sample connection files

## Common Customizations

### Change Shutdown Behavior
Edit `/usr/local/bin/ticos-startup.sh`, replace:
```bash
sudo /sbin/poweroff
```
with:
```bash
sudo /sbin/reboot  # Or remove line entirely
```

### Add Custom Startup Commands
Edit `/home/pi/.xinitrc` and add commands before the final `exec` line.

### Change Screen Resolution
Edit `/home/pi/.xinitrc` and add:
```bash
xrandr --output HDMI-1 --mode 1920x1080
```

### Disable Auto-login
```bash
sudo rm -rf /etc/systemd/system/getty@tty1.service.d/
sudo systemctl daemon-reload
```

## Getting Help

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Review [GitHub Issues](https://github.com/manoelhc/TicOS/issues)
3. Create a new issue with:
   - TicOS version
   - Raspberry Pi model
   - Description of problem
   - Relevant logs

## Build Time Reference

Typical build times (depending on hardware and internet speed):
- Download base image: 5-10 minutes
- Package updates: 5-10 minutes
- Package installation: 5-10 minutes
- Configuration: 1-2 minutes
- **Total**: 15-30 minutes

## Tips

- 💡 Use a high-quality SD card for better performance
- 💡 Create backups of your customized image
- 💡 Test network configuration before deploying multiple units
- 💡 Document your remote desktop connection details
- 💡 Consider read-only root filesystem for production
- 💡 Use wired Ethernet for better reliability

---

**Happy thin-client computing with TicOS!** 🚀
