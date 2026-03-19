#!/usr/bin/env bash
set -euo pipefail

# keepAwake 
nice -n 19 /usr/local/bin/keepAwake.sh &

# Replace working diretory
# sed -i -E 's|^Exec=exo-open --launch TerminalEmulator(.*)$|Exec=exo-open --launch TerminalEmulator --working-directory=/home/operator/workspace|' \
#   /usr/share/applications/xfce4-terminal-emulator.desktop


# Print out the NoVNC certificate fingerprint
echo 'NoVNC Certificate Fingerprint:'
openssl x509 \
  -in /etc/ssl/private/novnc_combined.pem \
  -noout -fingerprint -sha256

# Ensure .vnc dir exists and is owned by the VNC user
VNCDIR="${HOME}/.vnc"
XRESOURCES="${HOME}/.Xresources"
mkdir -p "$VNCDIR"
chown "${USER}:${USER}" "$VNCDIR"

# Create a minimal .Xresources if missing (xrdb will load it)
if [[ ! -f "$XRESOURCES" ]]; then
  cat > "$XRESOURCES" <<EOF
! Default X resources
*background:    grey
*foreground:    white
EOF
  chown "${USER}:${USER}" "$XRESOURCES"
fi

# Create .Xauthority
XAUTH="${HOME}/.Xauthority"
if [[ ! -f "$XAUTH" ]]; then
  touch "$XAUTH"
  chown "${USER}:${USER}" "$XAUTH"
fi

# Remove any leftover X lock files
rm -f /tmp/.X*-lock

# Start the VNC server on display :0
vncserver :0 \
  -rfbport "$VNCPORT" \
  -geometry "$VNCDISPLAY" \
  -depth "$VNCDEPTH" \
  -localhost \
  -SecurityTypes None

# Exec NoVNC (so it stays in PID 1 and receives signals)
exec /usr/share/novnc/utils/launch.sh \
  --listen "$NOVNCPORT" \
  --vnc "localhost:$VNCPORT" \
  --cert /etc/ssl/private/novnc_combined.pem
