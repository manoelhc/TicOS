# TicOS

**TicOS** (Thin Client Operating System) is a minimal Linux distribution built specifically for Raspberry Pi 5 that boots directly into Remmina, a remote desktop client. It's designed as a dedicated thin client solution with automatic network detection and minimal resource usage.

## 📚 Documentation

- **[Quick Start Guide](QUICKSTART.md)** - Get up and running in 5 steps
- **[Troubleshooting](TROUBLESHOOTING.md)** - Solutions to common problems
- **[Security Guide](SECURITY.md)** - Security best practices and hardening
- **[Examples](examples/)** - Sample Remmina connection files

## Features

- **Minimal Footprint**: Based on Raspberry Pi OS Lite with only essential packages
- **Auto-start Remmina**: Boots directly into Remmina in full-screen kiosk mode
- **Network Detection**: Automatically detects Ethernet connectivity
- **Fallback Configuration**: Opens xterm for manual network configuration if no connection is detected
- **Auto Shutdown**: System halts when Remmina exits
- **No Desktop Environment**: Uses minimal X11 setup without a full window manager
- **Optimized Boot**: Disabled unnecessary services for faster boot times

## Requirements

### Build System Requirements

- Linux-based system (x86_64 or aarch64)
- Packer (HashiCorp Packer)
- QEMU with ARM support
- At least 8GB of free disk space
- Internet connection for downloading base image and packages

### Target Hardware

- Raspberry Pi 5
- Ethernet connection
- Monitor with HDMI connection
- Keyboard (for network configuration if needed)

## Quick Start

### 1. Setup Build Environment

```bash
# Clone the repository
git clone https://github.com/manoelhc/TicOS.git
cd TicOS

# Run the setup script to install dependencies
chmod +x setup.sh
./setup.sh
```

### 2. Build the Image

```bash
# Initialize Packer plugins
packer init .

# Build the TicOS image
packer build packer.pkr.hcl
```

This will download the Raspberry Pi OS base image and create a customized `ticos-rpi5.img` file (approximately 4GB).

### 3. Flash to SD Card

```bash
# Use dd, Raspberry Pi Imager, or balenaEtcher
# Example with dd:
sudo dd if=ticos-rpi5.img of=/dev/sdX bs=4M status=progress
sync
```

Replace `/dev/sdX` with your SD card device.

### 4. Boot Your Raspberry Pi 5

1. Insert the SD card into your Raspberry Pi 5
2. Connect Ethernet cable
3. Connect monitor via HDMI
4. Power on the device

## How It Works

### Boot Sequence

1. **System Boot**: Raspberry Pi boots from the SD card
2. **Auto-login**: System automatically logs in as the `pi` user
3. **X11 Start**: Systemd service starts X11 with minimal configuration
4. **Network Check**: Script checks for Ethernet connectivity
5. **Application Launch**:
   - **If network is available**: Remmina launches in full-screen kiosk mode
   - **If network is unavailable**: xterm opens for manual network configuration
6. **Shutdown**: When Remmina exits, the system automatically shuts down

### Network Configuration

If the network is not detected at boot:

1. xterm will open with helpful commands displayed
2. Common commands for network configuration:
   ```bash
   sudo dhclient eth0                    # Get IP via DHCP
   sudo ip addr                          # Show network interfaces
   sudo systemctl restart networking     # Restart network service
   ```
3. After configuring the network, type `exit` to restart the detection process

### Remmina Configuration

Remmina is pre-configured with:
- Full-screen kiosk mode
- Hidden toolbar and statusbar
- Keyboard grab enabled
- All shortcuts forwarded to remote OS
- Optimized for thin client usage

To add remote connections:
1. Save `.remmina` connection files to `/home/pi/.local/share/remmina/`
2. Or configure them through Remmina's GUI before finalizing the build

## File Structure

```
TicOS/
├── packer.pkr.hcl              # Main Packer configuration
├── setup.sh                     # Build environment setup script
├── scripts/
│   ├── ticos-startup.sh        # Main startup script (network detection & app launch)
│   ├── network-check.sh        # Network connectivity checker
│   ├── xinitrc                 # X11 initialization script
│   ├── ticos.service           # Systemd service for auto-start
│   └── remmina.pref            # Remmina preferences configuration
└── README.md                    # This file
```

## Customization

### Changing the Base Image

Edit `packer.pkr.hcl` and update the `raspberry_pi_os_url` and `image_checksum` variables to use a different Raspberry Pi OS version.

### Adding Additional Packages

Add package names to the `apt-get install` command in the `packer.pkr.hcl` file:

```hcl
provisioner "shell" {
  inline = [
    "sudo apt-get install -y your-package-here",
  ]
}
```

### Pre-configuring Remote Connections

You can add Remmina connection files during the build by:

1. Create `.remmina` connection files
2. Add a file provisioner in `packer.pkr.hcl`:
   ```hcl
   provisioner "file" {
     source      = "connections/myserver.remmina"
     destination = "/home/pi/.local/share/remmina/myserver.remmina"
   }
   ```

### Changing Screen Resolution

Edit the `xinitrc` script and add:
```bash
xrandr --output HDMI-1 --mode 1920x1080
```

## Troubleshooting

For detailed troubleshooting information, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

Common issues:

### Build Issues

**Problem**: Packer fails to download the base image
- **Solution**: Check your internet connection or update the URL in `packer.pkr.hcl`

**Problem**: QEMU errors during build
- **Solution**: Ensure `qemu-user-static` and `qemu-system-arm` are installed

### Runtime Issues

**Problem**: Black screen after boot
- **Solution**: Check logs at `/var/log/ticos-startup.log` on the Pi

**Problem**: Network not detected but Ethernet is connected
- **Solution**: Wait 10 seconds for network initialization, or manually configure in xterm

**Problem**: Remmina doesn't start
- **Solution**: Check X11 is running with `ps aux | grep X` and review system logs

## Security Considerations

⚠️ **Important**: Review the [SECURITY.md](SECURITY.md) document before deploying to production.

Key security points:
- Default username/password is `pi`/`raspberry` - **change this for production use**
- SSH is enabled by default in Raspberry Pi OS Lite
- No firewall is enabled by default
- Consider disabling SSH if not needed: `sudo systemctl disable ssh`

For detailed security recommendations, see [SECURITY.md](SECURITY.md).

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is provided as-is without warranty. Use at your own risk.

## Credits

Built with:
- [Raspberry Pi OS](https://www.raspberrypi.org/software/)
- [Packer](https://www.packer.io/)
- [Remmina](https://remmina.org/)
- [solo-io ARM Image Plugin](https://github.com/solo-io/packer-plugin-arm-image)
