# docker-desktop

[![build](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml/badge.svg)](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml)
[![GitHub stars](https://img.shields.io/github/stars/scottyhardy/docker-remote-desktop.svg?style=social)](https://github.com/scottyhardy/docker-remote-desktop/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/scottyhardy/docker-remote-desktop.svg?style=social)](https://github.com/scottyhardy/docker-remote-desktop/network)
[![Docker Stars](https://img.shields.io/docker/stars/scottyhardy/docker-remote-desktop.svg?style=social)](https://hub.docker.com/r/scottyhardy/docker-remote-desktop)
[![Docker Pulls](https://img.shields.io/docker/pulls/scottyhardy/docker-remote-desktop.svg?style=social)](https://hub.docker.com/r/scottyhardy/docker-remote-desktop)

Docker image with RDP server using [xrdp](https://www.xrdp.org) on Ubuntu with [Xfce](https://xfce.org).

Images are built using Ubuntu

## Getting Started

Run with an interactive bash session:

```bash
docker run -it --rm \
  --user root \
  --name="xubuntu-vm" \
  --hostname="$(hostname)" \
  --publish="3389:3389/tcp" \
  --shm-size="2g" \
  --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
  --mount type=bind,source=/Users/shankerthebunker/shared,target=/shared \
  xubuntu-dev:latest /bin/bash
```

Start as a detached daemon:

```bash
docker run --detach --rm \
  --user root \
  --name="xubuntu-vm" \
  --hostname="$(hostname)" \
  --publish="3389:3389/tcp" \
  --shm-size="2g" \
  --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
  --mount type=bind,source=/Users/shankerthebunker/shared,target=/shared \
  xubuntu-dev:latest /bin/bash
```

Stop the detached container:

```bash
ddocker kill xubuntu-vm
```

Download the latest version of the image:

```bash
docker pull scottyhardy/docker-remote-desktop
```

## Connecting with an RDP client

All Windows desktops and servers come with Remote Desktop pre-installed and macOS users can download the Microsoft Remote Desktop application for free from the App Store.  For Linux users, I'd suggest using the Remmina Remote Desktop client.

For the hostname, use `localhost` if the container is hosted on the same machine you're running your Remote Desktop client on and for remote connections just use the name or IP address of the machine you are connecting to.
NOTE: To connect to a remote machine, it will require TCP port 3389 to be exposed through the firewall.

To log in, use the following default user account details:

```bash
Username: ubuntu
Password: ubuntu
```

![Screenshot of login prompt](https://raw.githubusercontent.com/scottyhardy/docker-remote-desktop/master/screenshot_1.png)

![Screenshot of XFCE desktop](https://raw.githubusercontent.com/scottyhardy/docker-remote-desktop/master/screenshot_2.png)

## Building docker-remote-desktop

Clone the GitHub repository:

```bash
git clone https://github.com/Shankerthebunker2791/docker-remote-desktop.git
cd docker-remote-desktop
```

Build the image with the supplied script:

```bash
./build
```

Or run the following docker command:

```bash
docker build --no-cache -f Dockerfile.xubuntu -t xubuntu-dev .
```

## Running local images with scripts

I've created some simple scripts that give the minimum requirements for either running the container interactively or running as a detached daemon.

To run with an interactive bash session:

```bash
./run
```

To start as a detached daemon:

```bash
./start
```

To stop the detached container:

```bash
./stop
```
