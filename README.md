# docker-desktop

[![GitHub stars](https://img.shields.io/github/stars/scottyhardy/docker-remote-desktop.svg?style=social)](https://github.com/scottyhardy/docker-remote-desktop/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/scottyhardy/docker-remote-desktop.svg?style=social)](https://github.com/scottyhardy/docker-remote-desktop/network)
[![Docker Stars](https://img.shields.io/docker/stars/scottyhardy/docker-remote-desktop.svg?style=social)](https://hub.docker.com/r/scottyhardy/docker-remote-desktop)
[![Docker Pulls](https://img.shields.io/docker/pulls/scottyhardy/docker-remote-desktop.svg?style=social)](https://hub.docker.com/r/scottyhardy/docker-remote-desktop)

A collection of Docker Compose configurations for running full desktop virtual machines inside Docker containers. This project provides three VM flavours — **Xubuntu (XFCE)**, **Windows**, and **macOS** — each accessible via remote desktop protocols (RDP or VNC).

## Project Overview

| VM | Compose File | Connection | Port |
|----|---|---|---|
| **Xubuntu (XFCE + CI/CD toolchain)** | `docker-compose-xubuntu.yml` | RDP | `3392` |
| **Windows (QEMU/KVM)** | `docker-compose-windows.yml` | RDP / Web (noVNC) | `3390` / `8009` |
| **macOS (QEMU/KVM)** | `docker-compose-macos.yml` | VNC / Web (noVNC) | `5901` / `8006` |

### Xubuntu VM

A full Xubuntu desktop built from `Dockerfile.xubuntu` with a complete CI/CD toolchain pre-installed:

- **Languages:** Java 21 (OpenJDK), Python 3.12, Node.js 20 LTS, PowerShell (pwsh)
- **Build tools:** Gradle 9.4.1, Maven 3.9.9, Ant 1.10.17
- **Mobile:** Android SDK, emulator, platform-tools (adb)
- **Containers:** Docker CLI, Docker Compose, Buildx (Docker-outside-of-Docker via socket mount)
- **CI/CD:** GitLab Runner (pre-installed, ready to register)
- **Desktop apps:** Firefox, LibreOffice, GIMP, VLC, VS Code-friendly terminal emulators, and more
- **Utilities:** Git, tmux, jq, shellcheck, strace, meld, telnet, ffmpeg, and many more

### Windows VM

Runs a full Windows installation (XP through Server 2025) inside Docker using [dockur/windows](https://github.com/dockur/windows). Installation is fully automatic — no manual steps required.

### macOS VM

Runs a macOS installation (Big Sur through Sequoia) inside Docker using [dockur/macos](https://github.com/dockur/macos). Requires manual installation via the browser-based viewer on first run.

> **Note:** Apple's EULA only permits running macOS on Apple hardware.

---

## Quick Start

### Xubuntu

```bash
# Build and start
docker compose -f docker-compose-xubuntu.yml up -d --build

# Connect via RDP → localhost:3392
# Username: ubuntu | Password: ubuntu
```

### Windows

```bash
# Start (auto-downloads ISO and installs)
docker compose -f docker-compose-windows.yml up -d

# Watch installation in browser → http://localhost:8009
# Connect via RDP → localhost:3390
# Username: Docker | Password: admin
```

### macOS

```bash
# Start (downloads recovery image)
docker compose -f docker-compose-macos.yml up -d

# Open installer in browser → http://localhost:8006
# Follow manual installation steps (see docker-compose-macos.yml comments)
# Connect via VNC → localhost:5901
```

---

## Lifecycle Commands

### Starting

```bash
# Xubuntu (build + start)
docker compose -f docker-compose-xubuntu.yml up -d --build

# Xubuntu (start, already built)
docker compose -f docker-compose-xubuntu.yml up -d

# Windows
docker compose -f docker-compose-windows.yml up -d

# macOS
docker compose -f docker-compose-macos.yml up -d
```

### Stopping

```bash
# Graceful stop (preserves state)
docker compose -f docker-compose-xubuntu.yml stop
docker compose -f docker-compose-windows.yml stop
docker compose -f docker-compose-macos.yml stop
```

### Restarting

```bash
# Resume from where you left off
docker compose -f docker-compose-xubuntu.yml start
docker compose -f docker-compose-windows.yml start
docker compose -f docker-compose-macos.yml start
```

### Viewing Logs

```bash
docker compose -f docker-compose-xubuntu.yml logs -f
docker compose -f docker-compose-windows.yml logs -f
docker compose -f docker-compose-macos.yml logs -f
```

### Removing Containers (data persists)

```bash
docker compose -f docker-compose-xubuntu.yml down
docker compose -f docker-compose-windows.yml down
docker compose -f docker-compose-macos.yml down
```

### Rebuilding After Dockerfile Changes

```bash
docker compose -f docker-compose-xubuntu.yml up -d --build --force-recreate
```

---

## Cleanup & Deletion

### Remove containers only (persistent data is kept)

```bash
docker compose -f docker-compose-xubuntu.yml down
docker compose -f docker-compose-windows.yml down
docker compose -f docker-compose-macos.yml down
```

### Remove containers + named volumes (full reset for Xubuntu)

```bash
docker compose -f docker-compose-xubuntu.yml down -v
```

### Full reset (destroy everything and start fresh)

```bash
# Xubuntu — remove named volume
docker compose -f docker-compose-xubuntu.yml down -v
rm -rf ./shared ./projects

# Windows — remove VM disk data + shared folder
docker compose -f docker-compose-windows.yml down
rm -rf ./windows-data ./windows-shared

# macOS — remove VM disk data + shared folder
docker compose -f docker-compose-macos.yml down
rm -rf ./macos-data ./macos-shared

# Or simply:
./kill all
```

### Remove built images

```bash
docker rmi xubuntu-dev:latest
docker rmi dockurr/windows
docker rmi dockurr/macos
```

---

## Data Persistence

| VM | Persistence Mechanism | Host Path |
|----|---|---|
| Xubuntu | Named volume `xubuntu-home` → `/home/ubuntu` | Docker-managed |
| Xubuntu | Bind mount `./shared` → `/home/ubuntu/shared` | `./shared` |
| Xubuntu | Bind mount `./projects` → `/home/ubuntu/projects` | `./projects` |
| Windows | Bind mount `./windows-data` → `/storage` | `./windows-data` |
| Windows | Bind mount `./windows-shared` → `/shared` | `./windows-shared` |
| macOS | Bind mount `./macos-data` → `/storage` | `./macos-data` |
| macOS | Bind mount `./macos-shared` → `/shared` | `./macos-shared` |

**What survives what:**

| Operation | Data persists? |
|---|---|
| `docker compose stop` / `start` | ✅ Yes |
| `docker compose down` / `up` | ✅ Yes (named volumes + bind mounts) |
| `docker compose restart` | ✅ Yes |
| Host machine reboot | ✅ Yes |
| `docker compose down -v` | ❌ Named volumes deleted |
| Deleting bind mount folders | ❌ Bind mount data gone |

---

## Connecting with Remote Desktop

### Xubuntu (RDP on port 3392)

| Platform | How to Connect |
|---|---|
| Windows | Win+R → `mstsc` → `localhost:3392` |
| macOS | "Windows App" from App Store → Add PC → `localhost:3392` |
| Linux | `xfreerdp /v:localhost:3392 /u:ubuntu /p:ubuntu` or Remmina |

**Credentials:** `ubuntu` / `ubuntu`

### Windows (RDP on port 3390)

| Platform | How to Connect |
|---|---|
| Windows | Win+R → `mstsc` → `localhost:3390` |
| macOS | "Windows App" from App Store → Add PC → `localhost:3390` |
| Linux | `xfreerdp /v:localhost:3390 /u:Docker /p:admin` or Remmina |

**Credentials:** `Docker` / `admin`

### macOS (VNC on port 5901 / Web on port 8006)

| Platform | How to Connect |
|---|---|
| Web browser | `http://localhost:8006` (noVNC, no client needed) |
| macOS | Finder → Go → Connect to Server → `vnc://localhost:5901` |
| Windows | VNC client (RealVNC, TightVNC) → `localhost:5901` |
| Linux | `vncviewer localhost:5901` or Remmina |

---

## Building the Xubuntu Image

```bash
# Using the build script
./build

# Or manually
docker build --no-cache -f Dockerfile.xubuntu -t xubuntu-dev .
```

## Helper Scripts

| Script | Purpose |
|---|---|
| `./build` | Build/pull all images (or target one: `./build xubuntu`) |
| `./start` | Start all VMs as daemons (or target one: `./start windows`) |
| `./stop` | Gracefully stop VMs, preserving data (or target one) |
| `./run` | Run a VM interactively (`./run xubuntu` for bash, `./run windows` for logs) |
| `./kill` | Full teardown + Docker cleanup (`./kill all` or `./kill xubuntu`) |
| `./deploy` | Tag and push Xubuntu image to Docker Hub |

All scripts accept a target argument: `xubuntu`, `windows`, `macos`, or `all` (default).

The `./kill` script is the nuclear option — it removes containers, volumes, bind-mount data, and purges Docker clutter (dangling images, build cache, unused networks/volumes). Use `./kill docker` to only clean Docker without touching VM data.

---

## Docker Compose File Details

### `docker-compose-xubuntu.yml`

Builds from `Dockerfile.xubuntu` and runs a self-contained Xubuntu desktop container. Key configuration:

- **RDP port:** Host `3392` → Container `3389`
- **Shared memory:** 2 GB (`shm_size: "2g"`)
- **Volumes:** Named volume for home dir, bind mounts for `./shared` and `./projects`, Docker socket mount
- **Restart policy:** `unless-stopped`
- **KVM:** Disabled by default (only needed for Android emulator)

### `docker-compose-windows.yml`

Pulls and runs `dockurr/windows` with QEMU emulation. Key configuration:

- **Web viewer:** Host `8009` → Container `8006`
- **RDP port:** Host `3390` → Container `3389`
- **Windows version:** Configurable via `VERSION` env var (default: `xp`)
- **Resources:** 4 GB RAM, 2 CPU cores, 30 GB virtual disk
- **Volumes:** `./windows-data` for VM disk, `./windows-shared` for file exchange
- **KVM:** Disabled (`KVM: "N"`)
- **Restart policy:** `unless-stopped`
- **Graceful shutdown:** 2 minute stop grace period

### `docker-compose-macos.yml`

Pulls and runs `dockurr/macos` with QEMU emulation. Key configuration:

- **Web viewer:** Host `8006` → Container `8006`
- **VNC port:** Host `5901` → Container `5900`
- **macOS version:** Configurable via `VERSION` env var (default: `11` Big Sur)
- **Resources:** 4 GB RAM, 2 CPU cores, 30 GB virtual disk
- **Volumes:** `./macos-data` for VM disk, `./macos-shared` for file exchange
- **KVM:** Disabled (`KVM: "N"`)
- **Restart policy:** `unless-stopped`
- **Graceful shutdown:** 2 minute stop grace period

---

## Custom ISO

To use your own installer ISO instead of auto-downloading:

1. Drop the file into the project root:
   - Windows: name it `windows.iso`
   - macOS: name it `macos.iso`

2. Uncomment the mount line in the corresponding compose file:
   ```yaml
   # docker-compose-windows.yml
   - ./windows.iso:/boot.iso

   # docker-compose-macos.yml
   - ./macos.iso:/boot.iso
   ```

When `/boot.iso` is mounted, the `VERSION` env var is ignored and your local ISO is used instead.

ISOs are excluded from git via `.gitignore` (`*.iso`).

---

## USB Device Passthrough

You can pass USB devices (external hard drives, video capture cards, cameras, etc.) from the host into the VMs.

### Platform Support

| Host OS | Xubuntu | Windows VM | macOS VM |
|---------|---------|-----------|----------|
| **Linux** | ✅ Direct (`devices:`) | ✅ Via QEMU (`ARGUMENTS`) | ✅ Via QEMU (`ARGUMENTS`) |
| **macOS** | ❌ Not possible | ❌ Not possible | ❌ Not possible |
| **Windows** | ❌ Not possible | ❌ Not possible | ❌ Not possible |

USB passthrough requires a **Linux host** because Docker Desktop on macOS/Windows runs inside its own VM and cannot access host USB hardware directly.

### Xubuntu (native container, Linux host)

Add to `docker-compose-xubuntu.yml`:

```yaml
devices:
  # All USB devices:
  - /dev/bus/usb:/dev/bus/usb

  # Or specific device (find with: lsusb && ls /dev/bus/usb/):
  - /dev/bus/usb/001/003:/dev/bus/usb/001/003

  # USB hard drive (block device):
  - /dev/sdb:/dev/sdb

  # Video capture card:
  - /dev/video0:/dev/video0
```

### Windows / macOS VMs (QEMU, Linux host)

Add to the `environment:` section of the compose file:

```yaml
environment:
  ARGUMENTS: "-device usb-host,vendorid=0x1234,productid=0x5678"
```

Find your device's vendor/product ID with: `lsusb`

Also mount the USB bus:
```yaml
devices:
  - /dev/bus/usb
```

### Finding Your USB Device

On the Linux host:
```bash
# List all USB devices with vendor:product IDs
lsusb

# Example output:
# Bus 001 Device 003: ID 1f75:0917 Innostor Technology Corporation
#                        ^^^^ ^^^^
#                        vendorid  productid

# For video capture cards:
ls /dev/video*

# For USB drives:
lsblk
```

---

## CI/CD Pipeline

Both GitHub Actions and GitLab CI configurations are included. They run the same pipeline on **any branch push** or manual trigger.

**Pipeline flow:** Clean → Build → Deploy → Test

| Stage | What it does |
|-------|-------------|
| Clean | Stops all running VMs, purges Docker (images, volumes, cache), removes data dirs |
| Build | Builds Xubuntu from `Dockerfile.xubuntu`, pulls `dockurr/windows` + `dockurr/macos` |
| Deploy | `docker compose up -d` for all three VMs — they stay running on the machine |
| Test | 18 validation tests, generates JUnit XML report viewable in GitHub/GitLab UI |

VMs remain running on the remote machine indefinitely until the next push triggers a fresh clean + redeploy cycle.

---

### How It Works

1. You push code to any branch (or click "Run pipeline" manually)
2. The CI system picks up the job and routes it to your self-hosted runner
3. The runner **stops and removes** all existing Docker containers, images, volumes
4. It **builds** the Xubuntu image from scratch and pulls Windows/macOS images
5. It **starts** all three VMs via `docker compose up -d`
6. It **runs 18 tests** to verify everything is healthy and generates a JUnit XML report
7. The VMs **stay running** on the machine — you connect via RDP/VNC from anywhere
8. Next time you push, step 1-7 repeats (full clean slate each time)

---

### Platform Compatibility

| Runner OS | Xubuntu | Windows VM | macOS VM | Notes |
|-----------|---------|-----------|----------|-------|
| **Linux** | ✅ | ✅ Best (KVM) | ✅ Best (KVM) | Enable KVM for 10-50x faster QEMU VMs |
| **macOS** | ✅ | ⚠️ Slow | ⚠️ Slow | No KVM — QEMU uses software emulation |
| **Windows** | ✅ | ⚠️ Slow | ⚠️ Slow | No KVM — QEMU uses software emulation |

---

### GitHub Actions Setup

**File:** `.github/workflows/deploy.yml`

**Pre-conditions:**
- A remote machine (Linux/macOS/Windows) where you want the VMs to run
- Docker and Docker Compose installed on that machine
- Network access from your machine to the runner (for RDP/VNC connections)

**Step-by-step setup:**

1. **Install the GitHub Actions runner** on your remote machine:
   ```bash
   # Download from: https://github.com/YOUR_ORG/YOUR_REPO/settings/actions/runners/new
   # Then:
   ./config.sh --url https://github.com/YOUR_ORG/YOUR_REPO --token YOUR_TOKEN
   ./run.sh   # or install as service: sudo ./svc.sh install && sudo ./svc.sh start
   ```

2. **Set the runner label** (so the workflow knows which runner to use):
   - Go to: Repository → Settings → Variables → Actions
   - Add variable: `RUNNER_LABEL` = the label you gave your runner (e.g., `self-hosted`, `my-mac`, `linux-server`)
   - If you skip this, it defaults to `self-hosted`

3. **Add Docker Hub secrets** (for pulling images):
   - Go to: Repository → Settings → Secrets → Actions
   - Add: `DOCKERHUB_USERNAME` = your Docker Hub username
   - Add: `DOCKERHUB_TOKEN` = your Docker Hub access token ([create here](https://hub.docker.com/settings/security))

4. **Push to any branch** — the pipeline triggers automatically:
   ```bash
   git push
   ```

5. **View results:**
   - Pipeline progress: Actions tab in your repository
   - Test report: Click the workflow run → "VM Validation" check → see pass/fail per test
   - JUnit artifact: downloadable from the Artifacts section (retained 90 days)

**Runner variable reference:**

| Variable/Secret | Where to set | Purpose |
|---|---|---|
| `RUNNER_LABEL` | Settings → Variables → Actions | Selects which runner to use |
| `DOCKERHUB_USERNAME` | Settings → Secrets → Actions | Docker Hub login |
| `DOCKERHUB_TOKEN` | Settings → Secrets → Actions | Docker Hub authentication |

---

### GitLab CI Setup

**File:** `.gitlab-ci.yml`

**Pre-conditions:**
- A remote machine (Linux/macOS/Windows) where you want the VMs to run
- Docker and Docker Compose installed on that machine
- GitLab Runner installed on that machine
- The runner must use **shell executor** (not docker executor!)

**Why shell executor?** The docker executor runs each job inside a throwaway container — when the job ends, the container (and your VMs inside it) dies. Shell executor runs directly on the host OS, so the VMs persist after the pipeline finishes and you can connect to them anytime.

**Step-by-step setup:**

1. **Install GitLab Runner** on your remote machine:
   ```bash
   # macOS:
   brew install gitlab-runner

   # Linux (Debian/Ubuntu):
   curl -fsSL https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
   sudo apt install gitlab-runner

   # Windows:
   # Download from https://docs.gitlab.com/runner/install/windows.html
   ```

2. **Register the runner with shell executor:**
   ```bash
   gitlab-runner register \
     --executor shell \
     --tag-list "docker" \
     --url https://gitlab.com \
     --token YOUR_REGISTRATION_TOKEN
   ```
   Get your registration token from: Repository → Settings → CI/CD → Runners → "New project runner"

   The `--tag-list` value (e.g., `"docker"`) is the tag you'll reference in the CI/CD variables.

3. **Start the runner:**
   ```bash
   # Foreground (for testing):
   gitlab-runner run

   # As a service (recommended):
   gitlab-runner install && gitlab-runner start
   ```

4. **Set CI/CD variables:**
   - Go to: Repository → Settings → CI/CD → Variables
   - Add: `RUNNER_TAG` = the tag you registered with (e.g., `docker`)
   - Add: `DOCKERHUB_USERNAME` = your Docker Hub username (check "Mask variable")
   - Add: `DOCKERHUB_TOKEN` = your Docker Hub access token (check "Mask variable")

5. **Push to any branch** — the pipeline triggers automatically:
   ```bash
   git push
   ```

6. **View results:**
   - Pipeline progress: CI/CD → Pipelines
   - Test report: Click pipeline → "Tests" tab (shows pass/fail per test in the UI)
   - Merge request widget: If you push to a branch with an open MR, test results appear inline
   - JUnit artifact: downloadable from the job page (retained 90 days)

**CI/CD variable reference:**

| Variable | Where to set | Purpose |
|---|---|---|
| `RUNNER_TAG` | Settings → CI/CD → Variables | Matches your runner's registered tag |
| `DOCKERHUB_USERNAME` | Settings → CI/CD → Variables (masked) | Docker Hub login |
| `DOCKERHUB_TOKEN` | Settings → CI/CD → Variables (masked) | Docker Hub authentication |

---

### Connecting After Deploy

Once the pipeline finishes successfully, the VMs are running on your remote machine. Connect from any device on the same network:

| VM | Connection | Address |
|----|-----------|---------|
| Xubuntu | RDP client | `<runner-ip>:3392` (ubuntu/ubuntu) |
| Windows | RDP client or browser | `<runner-ip>:3390` (Docker/admin) or `http://<runner-ip>:8009` |
| macOS | VNC client or browser | `<runner-ip>:5901` or `http://<runner-ip>:8006` |

Replace `<runner-ip>` with the IP/hostname of your remote runner machine. Use `localhost` if connecting from the runner itself.

---

### Tests Executed

| # | Test | What it validates |
|---|------|---|
| 1 | Xubuntu container running | Container started and didn't crash |
| 2 | xrdp listening on 3389 | RDP server is accepting connections |
| 3 | Python 3.12 installed | Python interpreter works |
| 4 | Java 21 installed | JDK is functional |
| 5 | Node.js 20 installed | Node runtime works |
| 6 | Docker CLI installed | Docker-outside-of-Docker functional |
| 7 | Gradle installed | Build tool available |
| 8 | Maven installed | Build tool available |
| 9 | Ant installed | Build tool available |
| 10 | Ubuntu user exists | User account created by entrypoint |
| 11 | SSH host keys regenerated | Security: unique keys per container |
| 12 | adb (Android) available | Android SDK path configured |
| 13 | PowerShell (pwsh) available | Cross-platform scripting ready |
| 14 | GitLab Runner available | Can register as nested runner |
| 15 | telnet available | Network diagnostic tool |
| 16 | ffmpeg available | Media processing tool |
| 17 | Windows container running | QEMU VM started successfully |
| 18 | macOS container running | QEMU VM started successfully |

---

## Prerequisites

- **Docker** and **Docker Compose** installed on the host
- **Disk space:**
  - Xubuntu image: ~8-10 GB (built locally)
  - Windows: ~20-30 GB after installation
  - macOS: ~25-40 GB after installation
- **KVM** (optional): Only required for the Android emulator inside Xubuntu, or for better performance with Windows/macOS VMs on Linux hosts
- **Apple hardware** (macOS VM only): Required by Apple's EULA

---

## Apple Silicon (M1/M2/M3/M4) Support

This project fully supports Apple Silicon Macs. No changes needed — just run the compose files as-is.

| VM | Apple Silicon | Performance | Notes |
|----|---|---|---|
| **Xubuntu** | ✅ Works | Full speed | Docker Desktop runs arm64 Linux containers natively via Hypervisor.framework |
| **Windows VM** | ✅ Works | Slow (no KVM) | QEMU emulates x86 via software (TCG). XP/7 usable, Win 10/11 sluggish |
| **macOS VM** | ⚠️ Works | Slow (no KVM) | QEMU emulation. For better performance, use UTM or Parallels instead |

**Why it works out of the box:**

- The Dockerfile detects `arm64` via `dpkg --print-architecture` and installs the correct packages (ARM Java, ARM Android system image, ARM Node.js)
- All compose files set `KVM: "N"` so QEMU skips the KVM check and uses software emulation
- Docker Desktop on Apple Silicon builds arm64 images natively — no Rosetta needed for the Xubuntu container

**Tips for Apple Silicon:**

- Xubuntu runs at full native speed — use it as your main dev environment
- For Windows, use `VERSION: "xp"` or `VERSION: "7u"` for acceptable performance under emulation
- If you need a fast Windows/macOS VM on Apple Silicon, consider UTM (free) or Parallels (paid) for those, and use this project for the Xubuntu dev environment

---

## Screenshots

![Screenshot of login prompt](https://raw.githubusercontent.com/scottyhardy/docker-remote-desktop/master/screenshot_1.png)

![Screenshot of XFCE desktop](https://raw.githubusercontent.com/scottyhardy/docker-remote-desktop/master/screenshot_2.png)
