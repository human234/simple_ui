# Using HMI on Windows with Docker

This guide lets you build **and flash** the HMI gauge demo **without
installing any Zephyr toolchain**. Everything runs inside the prebuilt HMI
Docker image (`ghcr.io/human234/hmi-build:0.1.1`), which bundles the Zephyr
SDK (1.0.x), `west`, all build tools, and the STM32CubeProgrammer CLI — so
`west flash` also works in-container.

The only thing required on the Windows host is **Docker Desktop**.

## 1. Install prerequisites

1. [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/)
   — install with the default **WSL2** backend.
2. Start Docker Desktop and wait for the whale icon to show it's running.
3. (Recommended) [Git for Windows](https://git-scm.com/).

> First run pulls the prebuilt image (~8–9 GB with the ST tools), one time only.

## 2. Get the workspace

Open PowerShell and run:

```powershell
cd $HOME
west init -m https://github.com/human234/hmi-workspace hmi-workspace
cd hmi-workspace
west update
```

This fetches Zephyr **v4.4.2** and all of its default modules (including
LVGL), plus the HMI library itself at `modules\hmi`.

> If you don't want to install `west`/Python on Windows at all, run those
> three lines **inside the container** instead (they get mounted out to your
> `%USERPROFILE%`):
>
> ```powershell
> docker run --rm -it --workdir "$HOME" `
>   -v "$HOME:$HOME" `
>   ghcr.io/human234/hmi-build:0.1.1 bash
> ```
> then replace `$HOME` with `/home/peter996` style absolute paths in the
> `west init` / `west update` commands above.

## 3. Build

From anywhere inside `hmi-workspace`:

```powershell
modules\hmi\build.ps1
```

or from `cmd.exe`:

```bat
modules\hmi\build.cmd
```

Default target is `nucleo_g474re`; override with `-Board <name>`.
The firmware lands in `build\zephyr\zephyr.bin` inside the workspace.

Under the hood this runs:

```powershell
docker run --rm -it --workdir /workdir `
  -v "<abs-path-to-hmi-workspace>:/workdir" `
  ghcr.io/human234/hmi-build:0.1.1 `
  west build -b nucleo_g474re -p always modules/hmi/samples/gauge_demo
```

## 4. Flash

`west flash` uses the STM32CubeProgrammer CLI that is already baked into the
image; it only needs the ST-Link probe to be visible inside the container.
On Windows that means passing the USB device into the Docker/WSL2 VM:

### 4a. USB passthrough (recommended for `west flash`)

1. Install [usbipd-win](https://github.com/dorssel/usbipd-win) (in an
   **admin** PowerShell): `winget install --id dorssel.usbipd-win`
2. Plug the board in and list probes: `usbipd list` — note the BUSID of the
   *ST-Link* device.
3. `usbipd bind --busid <BUSID>` (admin).
4. Attach it into the Docker Desktop VM:
   `usbipd attach --wsl --busid <BUSID> --distribution docker-desktop`
   (If Docker Desktop is using its default Hybrid/WSL2 mode this is the
   right target; otherwise omit `--distribution`)
5. Flash: `modules\hmi\flash.ps1`

If the board doesn't respond, make sure the pass-through has taken
(`usbipd list` shows *Attached*), then flash again.

### 4b. Zero-tool fallback (always works)

No USB passthrough needed — flash from Windows directly:

1. After step 3, the firmware is at `build\zephyr\zephyr.bin`.
2. Copy it onto the ST-Link drive: the board enumerates as a USB drive
   (e.g. `NODE_G474RE`). Drag the `.bin` onto it.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Cannot find a Zephyr workspace` | Run the script from inside `hmi-workspace` (it walks up looking for the `zephyr` folder). |
| `west: configuring - pulled 1000+ objects` on first build | Normal; it's the initial build of Zephyr + LVGL. Firmware builds in a few minutes. |
| Long pause at `[xxx/565]` | The image was re-run from a pristine (`-p always`) state; subsequent builds are faster. |
| `STM32_Programmer_CLI: not found` / flash runner errors | The image was built without the ST tools; rebuild per `docker/fetch-stm32cubeprog.ps1` and push a new `hmi-build` tag. |
| Flash fails with USB errors | Do step 4a again (Windows updates can drop the attach); or use fallback 4b. |
| Docker image pull is slow | Expected on the first run (~8–9 GB). It's cached afterwards. |

## Consumer quick reference (non-Windows)

| Platform | Build | Flash |
|---|---|---|
| Linux / WSL | `make -C modules/hmi build` | `make -C modules/hmi flash` |
| Any (manual) | `docker compose -f modules/hmi/docker/docker-compose.yml run --rm hmi` | `docker run --rm -it --privileged -v <ws>:/workdir ghcr.io/human234/hmi-build:0.1.1 west flash` |

## About the image

`ghcr.io/human234/hmi-build:0.1.1` is the official Zephyr developer image
(`zephyr-build:v0.29.3`, SDK 1.0.1, matching Zephyr v4.4.x) plus a pruned
STM32CubeProgrammer v2.23.0 install tree (ST licence SLA0048). It is public
so consumers can pull it without an account. The tree is produced once from
ST's own installer (silently, headless `java -jar` won't work — see
`docker/fetch-stm32cubeprog.ps1` + `docker/auto-install.xml`) and cached as
`docker/stm32cubeprog-tree.tar.gz` (git-ignored); the `docker/Dockerfile`
has the exact recipe.