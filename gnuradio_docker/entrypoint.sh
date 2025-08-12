#!/bin/bash
set -e

# udev setup (needs root)
udevadm control --reload-rules || true
udevadm trigger || true
for dev in /dev/bus/usb/*/*; do
  [ -e "$dev" ] && chmod 0666 "$dev"
done

# hand off to the main command as guser
# (sudo is already installed in your image)
#exec sudo -E -u guser "$@"
# /entrypoint.sh (last line)
exec "$@"
