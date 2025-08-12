# Signalcraft Rocky 9 VNC Desktop (XFCE + Xvfb + noVNC)

## Build
```bash
mkdir -p "${HOME}/signalcraft/novnc/home/guser" "${HOME}/signalcraft/gnuradio"
docker compose up -d --build
```

## Use
- Open noVNC: http://localhost:8090/vnc.html
- Or use a native VNC client: `vncviewer localhost:5900` (no password by default in this sample; set one in `supervisord.conf`'s x11vnc command).

## Tips
- If XFCE won’t start and `~/.ICEauthority` or `~/.Xauthority` are permission denied, fix ownership on the host:
  ```bash
  sudo chown -R 1000:1000 "$HOME/signalcraft/novnc/home/guser"
  ```
- Check service status:
  ```bash
  docker compose exec gnuradio supervisorctl -c /etc/supervisor/supervisord.conf status
  ```
