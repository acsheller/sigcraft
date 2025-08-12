# Start with NVIDIA's development container
FROM nvidia/cuda:12.6.2-cudnn-devel-ubuntu22.04

# Preconfigure timezone and base env
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
ENV DISPLAY=:99
ENV PATH="/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV PYTHONOPTIMIZE=1
ENV TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.2;7.5;8.0;8.6+PTX;8.9;9.0"
ENV TF_CPP_MIN_LOG_LEVEL=3

# Core packages (XFCE/Xvfb/VNC/Supervisor/SDR/GNURadio) + helpers
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates gnupg wget curl \
    software-properties-common cmake g++ python3 python3-pip python3-venv git sudo \
    python3-packaging python3-setuptools python-is-python3 build-essential usbutils libusb-1.0-0-dev \
    xfce4 xfce4-terminal x11vnc xvfb novnc python3-websockify supervisor \
    dbus-x11 x11-xserver-utils x11-utils xauth \
    filezilla vim udev python3-mako terminator ncdu gr-osmosdr librtlsdr-dev rtl-sdr \
    gnuradio gnuradio-dev \
 && rm -rf /var/lib/apt/lists/*

# Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google.gpg \
 && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update && apt-get install -y --no-install-recommends google-chrome-stable \
 && rm -rf /var/lib/apt/lists/*

# Visual Studio Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/packages.microsoft.gpg \
 && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" \
    > /etc/apt/sources.list.d/vscode.list \
 && apt-get update && apt-get install -y --no-install-recommends code \
 && rm -rf /var/lib/apt/lists/*

# noVNC + WebSockify (from source) and a convenience index.html symlink
RUN mkdir -p /opt/novnc/utils/websockify \
 && wget -qO- https://github.com/novnc/noVNC/archive/v1.5.0.tar.gz | tar xz --strip-components=1 -C /opt/novnc \
 && wget -qO- https://github.com/novnc/websockify/archive/v0.12.0.tar.gz | tar xz --strip-components=1 -C /opt/novnc/utils/websockify \
 && ln -sf /opt/novnc/vnc.html /opt/novnc/index.html

# Non-root user pinned to host-like UID/GID and in 'dialout' for SDR
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} guser \
 && useradd -m -u ${USER_ID} -g guser -s /bin/bash guser \
 && (getent group dialout >/dev/null || groupadd -r dialout) \
 && usermod -aG dialout guser \
 && mkdir -p /home/guser/.vnc /etc/supervisor/conf.d \
 && chown -R ${USER_ID}:${GROUP_ID} /home/guser /etc/supervisor/conf.d /opt/novnc \
 && echo "guser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# udev rule for RTL-SDR
RUN echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", MODE="0666", GROUP="dialout"' \
    > /etc/udev/rules.d/20-rtlsdr.rules

# App workspace
WORKDIR /app
RUN chown -R guser:guser /app


COPY --chown=guser:guser --chmod=0755 start-xfce.sh /usr/local/bin/start-xfce.sh
COPY --chmod=0755 entrypoint.sh /entrypoint.sh

# Ports
EXPOSE 8080 5900


# Main supervisor config (stdout + socket in /tmp)
COPY supervisor-main.conf /etc/supervisor/supervisord.conf
# Program config stays in conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Entrypoint stays root; CMD starts supervisord with the main config
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
