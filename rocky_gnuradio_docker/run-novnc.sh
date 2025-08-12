#!/usr/bin/env bash
set -euo pipefail
export PYTHONPATH=/opt/novnc/utils/websockify
exec python3 -u -m websockify --web /opt/novnc 0.0.0.0:8082 localhost:5900
