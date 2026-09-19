<#
.SYNOPSIS
    Build (or flash) the HMI gauge demo inside the official Zephyr Docker
    image, from any directory inside your west workspace.

.DESCRIPTION
    Locates the west workspace root (the first directory walking up that
    contains zephyr/), mounts it into the zephyr-build image at /workdir,
    and runs `west build`. Pass -Flash to run `west flash` instead
    (requires the ST-Link probe to be visible in the container, see
    README-WINDOWS.md).

    Requires: Docker Desktop (WSL2 backend). No Zephyr toolchain needed.

.EXAMPLE
    PS> .\build.ps1
    PS> .\build.ps1 -Board stm32g474_dk
    PS> .\build.ps1 -Flash
#>
param(
    [string]$Board = "nucleo_g474re",
    [string]$App = "modules/hmi/samples/gauge_demo",
    [switch]$Flash
)

$ErrorActionPreference = "Stop"

$Image = "ghcr.io/zephyrproject-rtos/zephyr-build:v0.29.3"

function Find-WorkspaceRoot {
    $dir = [System.IO.DirectoryInfo](Get-Location).Path
    while ($null -ne $dir) {
        if (Test-Path (Join-Path $dir.FullName "zephyr")) {
            return $dir.FullName
        }
        $dir = $dir.Parent
    }
    throw "No Zephyr workspace found (no 'zephyr' directory in this or any parent directory)."
}

$workspace = Find-WorkspaceRoot

if ($Flash) {
    docker run --rm -it --privileged --workdir /workdir `
        -v "${workspace}:/workdir" $Image west flash
} else {
    docker run --rm -it --workdir /workdir `
        -v "${workspace}:/workdir" $Image west build -b $Board -p always $App
}