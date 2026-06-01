#!/usr/bin/env bash
set -e

# Define the password dynamically
DESKTOP_PASS=${RDP_PASSWORD:-ubuntu}

# 1. Create the user account if it doesn't exist (Preserving your exact UID/GID settings)
if ! id ubuntu >/dev/null 2>&1; then
    groupadd --gid 1020 ubuntu
    useradd --shell /bin/bash --uid 1020 --gid 1020 --groups sudo,audio \
        --password "$(openssl passwd ${DESKTOP_PASS})" --create-home --home-dir /home/ubuntu ubuntu
else
    # Update password for existing user on boot just in case it was changed in compose
    echo "ubuntu:${DESKTOP_PASS}" | chpasswd
    usermod -aG sudo,audio ubuntu
fi

# 2. Configure passwordless sudo access cleanly
mkdir -p /etc/sudoers.d
echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu
chmod 440 /etc/sudoers.d/ubuntu

# 3. Ensure home directory ownership is intact
mkdir -p /home/ubuntu
chown -R ubuntu:ubuntu /home/ubuntu

# 4. FIX THE AUDIO HANG & BLANK SCREEN: Standardize X11 session & D-Bus environmental plumbing
cat << 'EOF' > /home/ubuntu/.xsession
#!/usr/bin/env bash
# Dynamically spawn a local D-Bus session bus instance so PulseAudio can register a socket loop
export $(dbus-launch)
pulseaudio --start --exit-idle-time=-1 &
exec xfce4-session
EOF

chown ubuntu:ubuntu /home/ubuntu/.xsession
chmod 755 /home/ubuntu/.xsession

# 5. Clear stale service runtime locking PIDs to prevent hanging states
rm -f /var/run/xrdp/xrdp-sesman.pid
rm -f /var/run/xrdp/xrdp.pid
rm -f /var/run/dbus/pid
rm -f /tmp/.X*-lock

# FIX IMAGE 1 display handshake: Ensure standard directory permissions for X11 server sockets
chmod 1777 /tmp
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix
rm -rf /tmp/.X11-unix/X*

# 6. Initialize system-wide D-Bus (Required for XFCE window and sound state)
mkdir -p /var/run/dbus
# FIX IMAGE 2 machine-id requirement: Generate absolute system hardware identifier mappings
dbus-uuidgen --ensure

if [ ! -f /var/run/dbus/pid ]; then
    dbus-daemon --system --fork
fi

# Start the PulseAudio daemon natively for the ubuntu user
# This creates the necessary ~/.config/pulse directories at runtime
echo "Starting PulseAudio daemon globally..."
su - ubuntu -c "pulseaudio --start"

# 7. Fire up the XRDP session manager daemon
/usr/sbin/xrdp-sesman

# 8. Start XRDP in foreground or handoff execution to arguments
if [ -z "$1" ]; then
    echo "Starting XRDP Server in foreground on port 3389..."
    exec /usr/sbin/xrdp --nodaemon
else
    /usr/sbin/xrdp
    exec "$@"
fi