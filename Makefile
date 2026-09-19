# HMI Docker build wrappers.
#
# Runs west commands inside the official Zephyr developer image. Use these
# from anywhere inside your west workspace: the workspace root (the
# directory containing zephyr/) is located automatically and mounted at
# /workdir, so builds work identically on Linux, macOS, and Windows.

IMAGE   ?= ghcr.io/zephyrproject-rtos/zephyr-build:v0.29.3
BOARD   ?= nucleo_g474re
APP     ?= modules/hmi/samples/gauge_demo

# Ascend from the current directory until we find one containing zephyr/.
WORKSPACE := $(shell D=$$(pwd); while [ ! -d "$$D/zephyr" ] && [ "$$D" != "/" ]; do D=$$(dirname "$$D"); done; printf "%s" "$$D")

.PHONY: build flash shell help

help:
	@echo "make build   - build the HMI gauge demo (nucleo_g474re) in Docker"
	@echo "make flash   - flash the last build to the board (needs USB passthrough)"
	@echo "make shell   - open an interactive shell in the Zephyr Docker image"

build:
	@if [ ! -d "$(WORKSPACE)/zephyr" ]; then \
		echo "error: no Zephyr workspace found (no 'zephyr' directory in this or any parent)"; exit 1; fi
	docker run --rm -it --workdir /workdir \
		-v "$(WORKSPACE):/workdir" \
		$(IMAGE) west build -b $(BOARD) -p always $(APP)

# Flashing from a container needs access to the debug probe USB device.
# On Windows/WSL2 first bind the probe into WSL2 (usbipd-win) or use
# Docker Desktop's USB passthrough; --privileged is used so the ST-Link
# is reachable regardless of how it was attached.
flash:
	@if [ ! -d "$(WORKSPACE)/zephyr" ]; then \
		echo "error: no Zephyr workspace found (no 'zephyr' directory in this or any parent)"; exit 1; fi
	docker run --rm -it --privileged --workdir /workdir \
		-v "$(WORKSPACE):/workdir" \
		$(IMAGE) west flash

shell:
	@if [ ! -d "$(WORKSPACE)/zephyr" ]; then \
		echo "error: no Zephyr workspace found (no 'zephyr' directory in this or any parent)"; exit 1; fi
	docker run --rm -it --workdir /workdir \
		-v "$(WORKSPACE):/workdir" \
		$(IMAGE) bash