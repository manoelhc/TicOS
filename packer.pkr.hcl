packer {
  required_plugins {
    arm-image = {
      version = ">= 0.2.7"
      source  = "github.com/solo-io/arm-image"
    }
  }
}

variable "raspberry_pi_os_url" {
  type    = string
  default = "https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-03-15/2024-03-15-raspios-bookworm-arm64-lite.img.xz"
}

variable "image_checksum" {
  type    = string
  default = "sha256:9266ed3c272c8f0f18984120ca0cb0e58c77fd9e69c3fbd4fb1e3c8e4a1cfcfc"
}

source "arm-image" "raspberry_pi_5" {
  iso_url              = var.raspberry_pi_os_url
  iso_checksum         = var.image_checksum
  output_filename      = "ticos-rpi5.img"
  target_image_size    = 4294967296 # 4GB
  qemu_binary          = "qemu-aarch64-static"
}

build {
  sources = ["source.arm-image.raspberry_pi_5"]

  # Update package lists and install required packages
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y xorg xinit openbox remmina remmina-plugin-rdp remmina-plugin-vnc xterm net-tools unclutter",
      "sudo apt-get clean",
      "sudo apt-get autoremove -y"
    ]
  }

  # Copy configuration files
  provisioner "file" {
    source      = "scripts/ticos-startup.sh"
    destination = "/tmp/ticos-startup.sh"
  }

  provisioner "file" {
    source      = "scripts/xinitrc"
    destination = "/tmp/xinitrc"
  }

  provisioner "file" {
    source      = "scripts/ticos.service"
    destination = "/tmp/ticos.service"
  }

  provisioner "file" {
    source      = "scripts/network-check.sh"
    destination = "/tmp/network-check.sh"
  }

  provisioner "file" {
    source      = "scripts/remmina.pref"
    destination = "/tmp/remmina.pref"
  }

  # Install configuration files
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/ticos-startup.sh /usr/local/bin/ticos-startup.sh",
      "sudo chmod +x /usr/local/bin/ticos-startup.sh",
      "sudo mv /tmp/network-check.sh /usr/local/bin/network-check.sh",
      "sudo chmod +x /usr/local/bin/network-check.sh",
      "sudo mv /tmp/xinitrc /home/pi/.xinitrc",
      "sudo chown pi:pi /home/pi/.xinitrc",
      "sudo chmod +x /home/pi/.xinitrc",
      "sudo mkdir -p /home/pi/.config/remmina",
      "sudo mv /tmp/remmina.pref /home/pi/.config/remmina/remmina.pref",
      "sudo chown -R pi:pi /home/pi/.config",
      "sudo mv /tmp/ticos.service /etc/systemd/system/ticos.service",
      "sudo systemctl enable ticos.service"
    ]
  }

  # Configure auto-login for pi user
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /etc/systemd/system/getty@tty1.service.d",
      "echo '[Service]' | sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf",
      "echo 'ExecStart=' | sudo tee -a /etc/systemd/system/getty@tty1.service.d/autologin.conf",
      "echo 'ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM' | sudo tee -a /etc/systemd/system/getty@tty1.service.d/autologin.conf"
    ]
  }

  # Disable unnecessary services to speed up boot
  provisioner "shell" {
    inline = [
      "sudo systemctl disable bluetooth.service || true",
      "sudo systemctl disable hciuart.service || true",
      "sudo systemctl disable avahi-daemon.service || true",
      "sudo systemctl disable triggerhappy.service || true"
    ]
  }
}
