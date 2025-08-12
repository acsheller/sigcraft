# ---------- Base: CUDA on Rocky 9 ----------
FROM nvidia/cuda:12.6.2-devel-rockylinux9

# Core env
ENV TZ=America/New_York \
    DISPLAY=:99 \
    PATH="/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    PYTHONOPTIMIZE=1 \
    TF_CPP_MIN_LOG_LEVEL=3

# ---------- Repos + base packages ----------
RUN dnf -y install epel-release \
 && dnf -y config-manager --set-enabled crb \
 && dnf -y upgrade --refresh \
 && dnf -y install --setopt=install_weak_deps=False --allowerasing \
    ca-certificates gnupg2 which sudo findutils wget tar \
    python3 python3-pip python3-setuptools python3-virtualenv \
    gcc gcc-c++ make cmake git \
    usbutils libusb1-devel procps-ng \
    xorg-x11-server-Xvfb xorg-x11-xauth dbus-x11 x11vnc \
    supervisor vim nano ncdu \
    gnuradio \
    # Minimal XFCE session bits
    xfce4-session xfce4-panel xfce4-settings xfdesktop xfwm4 thunar xfce4-terminal \
    adwaita-icon-theme dejavu-sans-fonts \
 && dnf clean all && rm -rf /var/cache/dnf

# ---------- noVNC + websockify from source ----------
RUN mkdir -p /opt/novnc/utils/websockify \
 && wget -qO- https://github.com/novnc/noVNC/archive/v1.5.0.tar.gz \
    | tar xz --strip-components=1 -C /opt/novnc \
 && wget -qO- https://github.com/novnc/websockify/archive/v0.12.0.tar.gz \
    | tar xz --strip-components=1 -C /opt/novnc/utils/websockify \
 && ln -sf /opt/novnc/vnc.html /opt/novnc/index.html

# ---------- (Optional) Chrome & VS Code ----------
# (These lines are safe to keep; they won't fail the build if repos hiccup)
RUN install -d /etc/yum.repos.d \
 && printf '%s\n' \
    '[google-chrome]' \
    'name=google-chrome' \
    'baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64' \
    'enabled=1' \
    'gpgcheck=1' \
    'gpgkey=https://dl.google.com/linux/linux_signing_key.pub' \
    > /etc/yum.repos.d/google-chrome.repo \
 && dnf -y install google-chrome-stable || true

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc \
 && printf '%s\n' \
    '[code]' \
    'name=Visual Studio Code' \
    'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
    'enabled=1' \
    'gpgcheck=1' \
    'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' \
    > /etc/yum.repos.d/vscode.repo \
 && dnf -y install code || true

# ---------- Non-root user ----------
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} guser \
 && useradd -m -u ${USER_ID} -g guser -s /bin/bash guser \
 && (getent group dialout >/dev/null || groupadd -r dialout) \
 && usermod -aG dialout guser \
 && mkdir -p /home/guser/.vnc /etc/supervisor/conf.d \
 && chown -R ${USER_ID}:${GROUP_ID} /home/guser /etc/supervisor/conf.d /opt/novnc \
 && echo "guser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers



# ---------- (Optional) udev rule for RTL-SDR ----------
RUN install -d -m 755 /etc/udev/rules.d \
 && printf '%s\n' 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", MODE="0666", GROUP="dialout"' \
    > /etc/udev/rules.d/20-rtlsdr.rules

# ---------- App workspace ----------
WORKDIR /app
RUN chown -R guser:guser /app

# ---------- Supervisor configs ----------
COPY supervisor-main.conf /etc/supervisor/supervisord.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ---------- XFCE launcher wrapper ----------
COPY --chown=guser:guser --chmod=0755 start-xfce.sh /usr/local/bin/start-xfce.sh

# ---------- Entrypoint ----------
COPY --chmod=0755 entrypoint.sh /entrypoint.sh

# noVNC launcher wrapper (runs websockify module with correct PYTHONPATH)
COPY --chown=guser:guser --chmod=0755 run-novnc.sh /usr/local/bin/run-novnc.sh
# ---------- Ports ----------
EXPOSE 8080 5900

# ---------- Boot ----------
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
