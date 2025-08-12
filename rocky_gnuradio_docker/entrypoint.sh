#!/usr/bin/env bash
set -e

# reload udev & relax USB perms (optional)
udevadm control --reload-rules || true
udevadm trigger || true
for dev in /dev/bus/usb/*/*; do
  [ -e "$dev" ] && chmod 0666 "$dev" || true
done

# if the bind-mounted home is root-owned on host, try to fix it
if [ -d /home/guser ]; then
  owner_uid="$(stat -c '%u' /home/guser || echo 0)"
  if [ "$owner_uid" != "1000" ]; then
    chown -R 1000:1000 /home/guser || true
  fi
fi

exec "$@"
