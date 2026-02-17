# Example Remmina Connection Files

This directory contains example Remmina connection files that you can customize for your environment.

## Using These Examples

1. Copy the example file you want to use
2. Edit the server IP address and credentials
3. Add to the Packer build by modifying `packer.pkr.hcl`:

```hcl
provisioner "file" {
  source      = "examples/example-rdp.remmina"
  destination = "/home/pi/.local/share/remmina/myserver.remmina"
}
```

## Connection File Format

### RDP Connections (example-rdp.remmina)

- `server`: IP address or hostname with port (default: 3389)
- `username`: Username for authentication
- `password`: Password (use `.` for prompt at runtime)
- `domain`: Windows domain (if applicable)
- `resolution_mode`: 
  - 0: Use initial window size
  - 1: Use custom resolution
  - 2: Use fullscreen
- `color_depth`: 8, 16, or 32 bits

### VNC Connections (example-vnc.remmina)

- `server`: IP address or hostname with port (default: 5900)
- `password`: VNC password (use `.` for prompt at runtime)
- `quality`: 0 (poor) to 9 (best)
- `colordepth`: Color depth in bits

## Password Security

For security reasons, connection files can use:
- `.` - Prompts for password at connection time
- Empty password field - No authentication
- Encrypted password - Remmina will encrypt the password when you save through the GUI

**Note**: Never commit files with plain-text passwords to version control!

## Pre-configuring Connections

To have connections available immediately on first boot:

1. Create your `.remmina` files in the `examples` directory
2. Update `packer.pkr.hcl` to copy them during build
3. Rebuild the image with `make build`

The connections will then appear in Remmina when it starts.
