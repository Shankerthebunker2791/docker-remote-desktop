#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# entrypoint.sh — container start-up for the Xubuntu + xrdp desktop
#
# SECURITY NOTE:
#   The desktop password defaults to "ubuntu" for convenience. This is fine for
#   throwaway local dev, but for anything exposed beyond localhost you MUST set
#   a strong password via the RDP_PASSWORD environment variable, e.g.:
#     docker run -e RDP_PASSWORD='S0me-Strong-Pass' ...
#   A warning is printed below when the insecure default is in use.
# =============================================================================

# Define the password dynamically.
DESKTOP_PASS="${RDP_PASSWORD:-ubuntu}"

if [ "${DESKTOP_PASS}" = "ubuntu" ]; then
    echo "WARNING: using the default RDP password 'ubuntu'. Set RDP_PASSWORD to a strong" >&2
    echo "         value before exposing this container outside localhost." >&2
fi

# 1. Create the user account if it doesn't exist (preserving the UID/GID layout).
#    The password hash is generated with a salt rather than the legacy unsalted
#    form of `openssl passwd`.
if ! id ubuntu >/dev/null 2>&1; then
    groupadd --gid 1020 ubuntu
    useradd --shell /bin/bash --uid 1020 --gid 1020 --groups sudo,audio \
        --create-home --home-dir /home/ubuntu ubuntu
fi

# Always (re)set the password on boot so it tracks RDP_PASSWORD. Use chpasswd
# so the value is passed via stdin instead of appearing in the process list.
echo "ubuntu:${DESKTOP_PASS}" | chpasswd
usermod -aG sudo,audio ubuntu

# 2. Configure passwordless sudo access cleanly.
mkdir -p /etc/sudoers.d
echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu
chmod 440 /etc/sudoers.d/ubuntu

# 3. Ensure home directory ownership is intact.
mkdir -p /home/ubuntu
chown ubuntu:ubuntu /home/ubuntu

# 4. Standardize the X11 session & D-Bus plumbing. PulseAudio is started here,
#    inside the user's session, and is the SINGLE place it gets launched (the
#    previous duplicate system-wide start has been removed to avoid two daemons
#    fighting over the same socket).
cat << 'EOF' > /home/ubuntu/.xsession
#!/usr/bin/env bash
# Spawn a per-session D-Bus bus so PulseAudio can register its socket loop.
export $(dbus-launch)
# Start PulseAudio only if it isn't already running for this session.
pulseaudio --check || pulseaudio --start --exit-idle-time=-1 &
exec xfce4-session
EOF

chown ubuntu:ubuntu /home/ubuntu/.xsession
chmod 755 /home/ubuntu/.xsession

# 5. Clear stale runtime PID/lock files to prevent hanging states.
rm -f /var/run/xrdp/xrdp-sesman.pid
rm -f /var/run/xrdp/xrdp.pid
rm -f /var/run/dbus/pid
rm -f /tmp/.X*-lock

# Regenerate SSH host keys if they are the default image-baked keys (security:
# without this, every container from the same image shares identical host keys).
if [ ! -f /etc/ssh/.keys_regenerated ]; then
    rm -f /etc/ssh/ssh_host_*
    ssh-keygen -A
    touch /etc/ssh/.keys_regenerated
fi

# Ensure standard permissions for X11 server sockets.
chmod 1777 /tmp
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix
rm -rf /tmp/.X11-unix/X*

# 6. Initialize system-wide D-Bus (required for XFCE window and sound state).
mkdir -p /var/run/dbus
dbus-uuidgen --ensure

if [ ! -f /var/run/dbus/pid ]; then
    dbus-daemon --system --fork
fi

# 7. Fire up the xrdp session manager daemon.
/usr/sbin/xrdp-sesman

# 8. Start xrdp in the foreground, or hand off execution to passed arguments.
if [ -z "${1:-}" ]; then
    echo "Starting XRDP Server in foreground on port 3389..."
    exec /usr/sbin/xrdp --nodaemon
else
    /usr/sbin/xrdp
    exec "$@"
fi
