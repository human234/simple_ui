# HMI development/build image.
#
# Pins the official Zephyr developer image ("zephyr-build"), which contains
# the Zephyr SDK (1.0.x), the `west` tool, and every host dependency Zephyr
# needs. Nothing is baked into this file beyond the pin: the user's west
# workspace is always mounted at runtime (see docker-compose.yml) so it
# stays buildable regardless of the host OS (e.g. Windows via Docker
# Desktop / WSL2).
#
# The SDK version bundled by this image tag matches Zephyr v4.4.x
# (zephyr/SDK_VERSION = 1.0.1).
FROM ghcr.io/zephyrproject-rtos/zephyr-build:v0.29.3