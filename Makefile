# Makefile for TicOS
# Convenience commands for building and managing the TicOS image

.PHONY: help setup init build clean check

help:
	@echo "TicOS Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  setup  - Install build dependencies (Packer, QEMU)"
	@echo "  init   - Initialize Packer plugins"
	@echo "  build  - Build the TicOS image"
	@echo "  check  - Validate Packer configuration"
	@echo "  clean  - Remove build artifacts"
	@echo "  all    - Run setup, init, and build"

setup:
	@echo "Setting up build environment..."
	chmod +x setup.sh
	./setup.sh

init:
	@echo "Initializing Packer plugins..."
	packer init .

build:
	@echo "Building TicOS image..."
	packer build packer.pkr.hcl

check:
	@echo "Validating Packer configuration..."
	packer validate packer.pkr.hcl
	packer fmt -check packer.pkr.hcl

clean:
	@echo "Cleaning build artifacts..."
	rm -f ticos-rpi5.img
	rm -f ticos-rpi5.img.xz
	rm -rf packer_cache/
	rm -rf output-*/
	rm -f crash.log

all: setup init build
	@echo "Build complete! Image: ticos-rpi5.img"
