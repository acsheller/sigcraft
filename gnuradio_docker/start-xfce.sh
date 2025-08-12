#!/usr/bin/env bash
set -euo pipefail
export DISPLAY=${DISPLAY:-:99}
export HOME=${HOME:-/home/guser}

# Wait for Xvfb socket to appear so we don't race
for i in {1..20}; do
  [ -S "/tmp/.X11-unix/X${DISPLAY#:}" ] && break
  sleep 0.5
done

# Launch XFCE within a dbus session
exec dbus-launch --exit-with-session startxfce4