# syntax=docker/dockerfile:1

# HMI development / build / flash image.
#
# Base: the official Zephyr developer image ("zephyr-build"), which bundles
# the Zephyr SDK (1.0.x), the `west` tool, and every host dependency Zephyr
# needs. This tag ships SDK 1.0.1, matching what Zephyr v4.4.x requires
# (zephyr/SDK_VERSION = 1.0.1).
#
# On top of that we bake in the STM32CubeProgrammer CLI so `west flash`
# works in-container: the default flash runner for the nucleo_g474re is
# `stm32cubeprogrammer` (see build/zephyr/runners.yaml), and the official
# zephyr-build image does not ship it.
#
# The CLI is packaged as a pre-built, pruned install tree
# (docker/stm32cubeprog-tree.tar.gz, git-ignored) produced ONCE on a Linux
# machine by running ST's IzPack installer silently with
# docker/auto-install.xml (docker/fetch-stm32cubeprog.ps1 documents this).
# We deliberately do NOT run the installer inside the image build: its
# post-unpack step ("File execution failed") needs a desktop session that a
# headless container cannot reliably provide. Only bin/ (minus the GUI's
# bundled jre), lib/ and the data/driver folders that the CLI needs are
# shipped; the runner looks the binary up via PATH and fixes up
# LD_LIBRARY_PATH itself.
#
# Build (build context = this repo root):
#   docker build -f docker/Dockerfile -t ghcr.io/human234/hmi-build:0.1.1 .
FROM ghcr.io/zephyrproject-rtos/zephyr-build:v0.29.3

ARG CUBEPROG_TAR=docker/stm32cubeprog-tree.tar.gz

COPY ${CUBEPROG_TAR} /tmp/stm32cubeprog-tree.tar.gz

# The base image's default user cannot write /usr/local; install as root,
# then drop back to the default dev user (uid/gid 1000).
USER root

RUN set -eux; \
    mkdir -p /usr/local/STMicroelectronics/STM32Cube; \
    tar -xzf /tmp/stm32cubeprog-tree.tar.gz -C /usr/local/STMicroelectronics/STM32Cube; \
    rm -f /tmp/stm32cubeprog-tree.tar.gz; \
    ln -sf /usr/local/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer_CLI /usr/local/bin/STM32_Programmer_CLI; \
    LD_LIBRARY_PATH=/usr/local/STMicroelectronics/STM32Cube/STM32CubeProgrammer/lib \
        STM32_Programmer_CLI --version

USER 1000:1000
WORKDIR /workdir