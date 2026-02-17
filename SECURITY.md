# Security Considerations for TicOS

This document outlines security considerations and best practices for deploying TicOS.

## Default Credentials

⚠️ **WARNING**: The default Raspberry Pi OS credentials are used:
- **Username**: `pi`
- **Password**: `raspberry`

**You MUST change these credentials before deploying to production!**

### Changing Default Credentials

After first boot, change the password:
```bash
passwd
```

Or configure during build by adding to `packer.pkr.hcl`:
```hcl
provisioner "shell" {
  inline = [
    "echo 'pi:YOUR_NEW_PASSWORD' | sudo chpasswd"
  ]
}
```

## Network Security

### SSH Access
- SSH is **enabled by default** in Raspberry Pi OS Lite
- Consider disabling SSH if not needed:
  ```bash
  sudo systemctl disable ssh
  sudo systemctl stop ssh
  ```
- If SSH is required, use key-based authentication instead of passwords
- Consider changing the default SSH port

### Firewall
- No firewall is configured by default
- Consider installing and configuring UFW (Uncomplicated Firewall):
  ```bash
  sudo apt-get install ufw
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow from 192.168.1.0/24 to any port 22  # Adjust to your network
  sudo ufw enable
  ```

### Network Connectivity
- The system tests network connectivity by pinging either:
  - The default gateway (preferred)
  - Google's DNS (8.8.8.8) as fallback
- No outbound connections are blocked by default

## Remmina Security

### Connection Credentials
- Example connection files use `.` for password field
- This prompts for password at connection time (recommended)
- **Never** commit connection files with plain-text passwords
- Remmina encrypts passwords when saved through the GUI

### RDP Security
- Disable clipboard sharing if not needed
- Use Network Level Authentication (NLA) when possible
- Consider using SSH tunnels for RDP connections
- Ensure target systems have strong authentication

### VNC Security
- VNC traffic is unencrypted by default
- Consider using SSH tunneling for VNC connections
- Use strong VNC passwords (minimum 8 characters)

## System Security

### Minimal Attack Surface
- TicOS installs only essential packages
- No unnecessary services are running
- Desktop environment is minimal (X11 only)
- Disabled services:
  - Bluetooth
  - Avahi daemon
  - Triggerhappy

### Auto-login
- Auto-login is configured for the `pi` user
- This is necessary for kiosk mode operation
- Consider physical security measures to protect the device

### Updates
- The system is updated during build
- Consider enabling automatic security updates:
  ```bash
  sudo apt-get install unattended-upgrades
  sudo dpkg-reconfigure -plow unattended-upgrades
  ```

### Logs
- Startup logs are written to `/var/log/ticos-startup.log`
- Review logs periodically for anomalies
- Consider log rotation configuration

## Physical Security

Since TicOS is designed as a kiosk system:
- Secure the physical device to prevent tampering
- Consider disabling USB ports in BIOS/firmware if not needed
- Lock down the device case to prevent SD card removal
- Place device in a secure location

## Remote Desktop Security

### Target System Security
All keyboard shortcuts are forwarded to the remote OS, so:
- Ensure remote systems have proper security controls
- Use strong authentication on remote systems
- Implement session timeouts on remote systems
- Monitor remote system access logs
- Keep remote systems patched and updated

### Connection Security
- Use encrypted protocols (RDP with TLS, VNC with SSH tunnel)
- Avoid using remote desktop over untrusted networks
- Consider VPN for remote access over internet
- Implement connection logging on remote systems

## Hardening Recommendations

### Additional Hardening Steps

1. **Disable unused hardware**:
   ```bash
   # Disable WiFi and Bluetooth
   echo "dtoverlay=disable-wifi" | sudo tee -a /boot/config.txt
   echo "dtoverlay=disable-bt" | sudo tee -a /boot/config.txt
   ```

2. **Restrict sudo access**:
   - Review and restrict sudo permissions for `pi` user
   - Consider requiring password for sudo commands

3. **Filesystem security**:
   ```bash
   # Mount /tmp with noexec
   # Add to /etc/fstab:
   tmpfs /tmp tmpfs defaults,noexec,nosuid 0 0
   ```

4. **Kernel hardening**:
   Add to `/etc/sysctl.conf`:
   ```
   net.ipv4.conf.all.send_redirects = 0
   net.ipv4.conf.default.send_redirects = 0
   net.ipv4.icmp_echo_ignore_broadcasts = 1
   net.ipv4.conf.all.accept_source_route = 0
   ```

5. **Limit failed login attempts**:
   ```bash
   sudo apt-get install fail2ban
   sudo systemctl enable fail2ban
   ```

## Compliance Considerations

Depending on your environment, consider:
- Data protection regulations (GDPR, HIPAA, etc.)
- Industry-specific security standards
- Organizational security policies
- Audit logging requirements
- Data retention policies

## Security Updates

Stay informed about security updates:
- Subscribe to Raspberry Pi security announcements
- Monitor Remmina security advisories
- Keep base OS packages updated
- Review X.org security bulletins

## Incident Response

Prepare for security incidents:
- Document the baseline system configuration
- Have a process for quickly rebuilding compromised systems
- Maintain offline backups of critical configurations
- Test recovery procedures

## Security Assessment

Before deployment, perform:
- Vulnerability scanning
- Penetration testing
- Security configuration review
- Access control verification
- Network security assessment

## Reporting Security Issues

If you discover a security vulnerability in TicOS:
1. Do not disclose publicly
2. Contact the maintainers privately
3. Provide detailed information about the vulnerability
4. Allow reasonable time for fixes before disclosure

## Disclaimer

This security guide provides general recommendations. Security requirements vary by environment. Consult with security professionals to ensure your deployment meets your specific security needs.

**Use TicOS at your own risk. The authors are not responsible for security breaches or data loss.**
