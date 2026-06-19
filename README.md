# docker-desktop

[![build](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml/badge.svg)](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml)
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

- **Languages:** Java 21 (OpenJDK), Python 3.12, Node.js 20 LTS
- **Build tools:** Gradle 9.4.1, Maven 3.9.9, Ant 1.10.17
- **Mobile:** Android SDK, emulator, platform-tools (adb)
- **Containers:** Docker CLI, Docker Compose, Buildx (Docker-outside-of-Docker via socket mount)
- **Desktop apps:** Firefox, LibreOffice, GIMP, VLC, VS Code-friendly terminal emulators, and more
- **Utilities:** Git, tmux, jq, shellcheck, strace, meld, and many more

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

# Windows — remove VM disk data
docker compose -f docker-compose-windows.yml down
rm -rf ./windows-data

# macOS — remove VM disk data
docker compose -f docker-compose-macos.yml down
rm -rf ./macos-data
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
| macOS | Bind mount `./macos-data` → `/storage` | `./macos-data` |

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
| `./build` | Build the Xubuntu Docker image |
| `./run` | Run container interactively with bash |
| `./start` | Start container as a detached daemon |
| `./stop` | Stop (kill) the running container |
| `./deploy` | Tag and push image to Docker Hub |

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
- **Volumes:** `./windows-data` for VM disk, `./shared` for file exchange
- **KVM:** Disabled (`KVM: "N"`)
- **Restart policy:** `unless-stopped`
- **Graceful shutdown:** 2 minute stop grace period

### `docker-compose-macos.yml`

Pulls and runs `dockurr/macos` with QEMU emulation. Key configuration:

- **Web viewer:** Host `8006` → Container `8006`
- **VNC port:** Host `5901` → Container `5900`
- **macOS version:** Configurable via `VERSION` env var (default: `11` Big Sur)
- **Resources:** 4 GB RAM, 2 CPU cores, 30 GB virtual disk
- **Volumes:** `./macos-data` for VM disk, `./shared` for file exchange
- **KVM:** Disabled (`KVM: "N"`)
- **Restart policy:** `unless-stopped`
- **Graceful shutdown:** 2 minute stop grace period

---

## Prerequisites

- **Docker** and **Docker Compose** installed on the host
- **Disk space:**
  - Xubuntu image: ~8-10 GB (built locally)
  - Windows: ~20-30 GB after installation
  - macOS: ~25-40 GB after installation
- **KVM** (optional): Only required for the Android emulator inside Xubuntu, or for better performance with Windows/macOS VMs on Linux hosts
- **Apple hardware** (macOS only): Required by Apple's EULA

---

## Screenshots

![Screenshot of login prompt](https://raw.githubusercontent.com/scottyhardy/docker-remote-desktop/master/screenshot_1.png)

![Screenshot of XFCE desktop](https://raw.githubusercontent.com/scottyhardy/docker-remote-desktop/master/screenshot_2.png)
