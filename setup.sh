#!/bin/bash

# Installation script for TicOS
# This script helps set up the build environment

set -e

echo "=================================="
echo "   TicOS Build Environment Setup"
echo "=================================="
echo ""

# Check if running on a supported platform
if [ "$(uname -m)" != "x86_64" ] && [ "$(uname -m)" != "aarch64" ]; then
    echo "Warning: This build system is designed for x86_64 or aarch64 architectures"
fi

# Install Packer if not already installed
if ! command -v packer &> /dev/null; then
    echo "Packer not found. Installing Packer..."
    
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt-get update && sudo apt-get install -y packer
    elif [ -f /etc/redhat-release ]; then
        # RHEL/CentOS/Fedora
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
        sudo yum -y install packer
    else
        echo "Please install Packer manually from https://www.packer.io/downloads"
        exit 1
    fi
else
    echo "Packer is already installed: $(packer version)"
fi

# Install QEMU if not already installed (needed for arm-image plugin)
if ! command -v qemu-aarch64-static &> /dev/null; then
    echo "Installing QEMU for ARM emulation..."
    
    if [ -f /etc/debian_version ]; then
        sudo apt-get update
        sudo apt-get install -y qemu-user-static qemu-system-arm
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y qemu-user-static
    else
        echo "Please install QEMU manually"
        exit 1
    fi
else
    echo "QEMU is already installed"
fi

echo ""
echo "=================================="
echo "   Setup Complete!"
echo "=================================="
echo ""
echo "You can now build the TicOS image with:"
echo "  packer init ."
echo "  packer build packer.pkr.hcl"
echo ""
