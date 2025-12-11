ARG VARIANT="noble"
FROM buildpack-deps:${VARIANT}
LABEL maintainer="SunshineCloudTech"
ENV container="docker"
ENV pip_packages="ansible"

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8 \
    TZ=Asia/Shanghai

# Flatpak environment variables
ENV XDG_DATA_DIRS="/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:/home/matrix0523/.local/share/flatpak/exports/share"
ENV FLATPAK_SYSTEM_DIR="/var/lib/flatpak"
ENV FLATPAK_USER_DIR="/home/matrix0523/.local/share/flatpak"

USER root 

# 检测并修改 Debian/Ubuntu 镜像源
# RUN if [ -f /etc/apt/sources.list ]; then \
#         sed -i 's|archive.ubuntu.com|mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list; \
#         echo "已修改 /etc/apt/sources.list"; \
#     fi && \
#     if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then \
#         sed -i 's|archive.ubuntu.com|mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/ubuntu.sources; \
#         echo "已修改 /etc/apt/sources.list.d/ubuntu.sources"; \
#     fi

# Update package list and install basic packages
RUN apt-get update && apt-get upgrade -y && apt-get clean

# 更新系统并安装基础工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    locales \
    tzdata \
    ca-certificates \
    gnupg2 \
    wget \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 配置中文语言环境
RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=zh_CN.UTF-8

# 配置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Enable systemd.
RUN apt-get update && \
    apt-get install -y --no-install-recommends systemd systemd-sysv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*

# Install pip and other requirements.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    python3-pip \
    sudo xterm \
    curl wget \
    ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Setup System User and Permissions  
RUN useradd -m "Administrator" -s /bin/bash && \
    echo "Administrator:123456789" | chpasswd && \
    echo "root:123456789" | chpasswd && \
    usermod -d /home/Administrator/ Administrator && \
    usermod -aG sudo Administrator && \
    useradd -m "matrix0523" -s /bin/bash && \
    echo "matrix0523:123456789" | chpasswd && \
    usermod -d /home/matrix0523/ matrix0523 && \
    usermod -aG sudo matrix0523 && \
    echo 'matrix0523 ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/matrix0523 && \
    # Create ollama user
    useradd -r -s /bin/false -U -m -d /usr/share/ollama ollama && \
    usermod -a -G ollama root && \
    usermod -a -G ollama Administrator && \
    usermod -a -G ollama matrix0523 && \
    # Setup Ollama directories and permissions
    mkdir -p /var/lib/ollama/models && \
    chown -R ollama:ollama /var/lib/ollama && \
    chmod -R 755 /var/lib/ollama

# Create Directory Structure
RUN mkdir -p /home/Administrator/Desktop /home/Administrator/Documents /home/Administrator/Downloads \
    /home/Administrator/Music /home/Administrator/Pictures /home/Administrator/Public \
    /home/Administrator/Templates /home/Administrator/thinclient_drives /home/Administrator/Videos && \
    mkdir -p /home/matrix0523/Desktop /home/matrix0523/Documents /home/matrix0523/Downloads \
    /home/matrix0523/Music /home/matrix0523/Pictures /home/matrix0523/Public \
    /home/matrix0523/Templates /home/matrix0523/thinclient_drives /home/matrix0523/Videos && \
    mkdir -p /app /SunshineCloud /lost+found && \
    mkdir -p /DATA/AppData /DATA/Documents /DATA/Downloads /DATA/Gallery /DATA/Compressed \
    /DATA/Desktop /DATA/Games /DATA/General /DATA/ISOS /DATA/Media /DATA/Others \
    /DATA/Programs /DATA/Public /DATA/Templates /DATA/Tools /DATA/Torrents /DATA/Videos && \
    mkdir -p /DATA/Media/Movies /DATA/Media/Music /DATA/Media/TV_Shows && \
    mkdir -p /SunshineCloud/AppData /SunshineCloud/Documents /SunshineCloud/Downloads \
    /SunshineCloud/Gallery /SunshineCloud/Compressed /SunshineCloud/Desktop \
    /SunshineCloud/Games /SunshineCloud/General /SunshineCloud/ISOS /SunshineCloud/Media \
    /SunshineCloud/Others /SunshineCloud/Programs /SunshineCloud/Public \
    /SunshineCloud/Templates /SunshineCloud/Tools /SunshineCloud/Torrents /SunshineCloud/Videos && \
    mkdir -p /SunshineCloud/Media/Movies /SunshineCloud/Media/Music /SunshineCloud/Media/TV_Shows && \
    mkdir -p /media/appdata /media/documents /media/downloads /media/gallery /media/compressed \
    /media/desktop /media/games /media/general /media/isos /media/media /media/others \
    /media/programs /media/public /media/templates /media/tools /media/torrents /media/videos && \
    mkdir -p /media/media/movies /media/media/music /media/media/tv_shows && \
    mkdir -p /var/run/dbus && \
    chown -R Administrator:Administrator /home/Administrator && \
    chown -R matrix0523:matrix0523 /home/matrix0523

# ============================================
# KDE Plasma 桌面环境安装
# ============================================

# 核心软件包和基础库
RUN apt-get update && apt-get install -y --no-install-recommends \
    plasma-desktop \
    plasma-workspace \
    plasma-workspace-wayland \
    kde-plasma-desktop && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 系统集成
RUN apt-get update && apt-get install -y --no-install-recommends \
    xdg-desktop-portal-kde \
    polkit-kde-agent-1 \
    kde-cli-tools \
    kde-cli-tools-data \
    plasma-integration \
    kwin-x11 \
    kwin-common \
    kwin-data && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 网络管理
RUN apt-get update && apt-get install -y --no-install-recommends \
    plasma-nm \
    plasma-pa \
    network-manager \
    network-manager-gnome && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 文件管理和基础应用
RUN apt-get update && apt-get install -y --no-install-recommends \
    kde-baseapps \
    # kde-baseapps-bin \
    dolphin \
    konsole \
    kate \
    okular \
    ark \
    gwenview \
    *spectacle* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 系统设置
RUN apt-get update && apt-get install -y --no-install-recommends \
    plasma-systemmonitor \
    plasma-disks \
    kde-config-gtk-style \
    kde-config-systemd \
    kde-config-screenlocker \
    systemsettings && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 通知和界面
RUN apt-get update && apt-get install -y --no-install-recommends \
    plasma-widgets-addons \
    plasma-desktop-data \
    plasma-workspace-data \
    kdeplasma-addons-data && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 发现软件中心
RUN apt-get update && apt-get install -y --no-install-recommends \
    plasma-discover \
    plasma-discover-common \
    plasma-discover-backend-flatpak \
    plasma-discover-backend-fwupd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 主题和外观
RUN apt-get update && apt-get install -y --no-install-recommends \
    plasma-theme-oxygen \
    kde-style-breeze \
    # kde-style-breeze-qt5 \
    # kde-style-breeze-data \
    plasma-wallpapers-addons \
    plasma-workspace-wallpapers && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 连接性
RUN apt-get update && apt-get install -y --no-install-recommends \
    kdeconnect \
    kdeconnect* \
    plasma-browser-integration && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 语言包（中文）
RUN apt-get update && apt-get install -y --no-install-recommends \
    htop && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 专业应用
# ============================================

# Kdenlive - 视频编辑器
RUN apt-get update && apt-get install -y --no-install-recommends \
    kdenlive \
    kdenlive-data \
    frei0r-plugins \
    ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Krita - 数字绘画软件
RUN apt-get update && apt-get install -y --no-install-recommends \
    krita \
    krita-data && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 浏览器
# ============================================

# Firefox
RUN apt-get update && apt-get install -y --no-install-recommends \
    firefox \
    firefox-locale-zh-hans && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 中文输入法 (Fcitx5)
# ============================================

RUN apt-get update && apt-get install -y --no-install-recommends \
    fcitx5 \
    fcitx5-chinese-addons \
    fcitx5-frontend-gtk2 \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-gtk4 \
    fcitx5-frontend-qt5 \
    fcitx5-frontend-qt6 \
    fcitx5-module-cloudpinyin \
    fcitx5-module-xorg \
    fcitx5-config-qt \
    kde-config-fcitx5 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 配置 Fcitx5 环境变量
RUN echo 'export GTK_IM_MODULE=fcitx' >> /etc/environment && \
    echo 'export QT_IM_MODULE=fcitx' >> /etc/environment && \
    echo 'export XMODIFIERS=@im=fcitx' >> /etc/environment && \
    echo 'export SDL_IM_MODULE=fcitx' >> /etc/environment && \
    echo 'export GLFW_IM_MODULE=ibus' >> /etc/environment

# ============================================
# XRDP 远程桌面支持
# ============================================

RUN apt-get update && apt-get install -y --no-install-recommends \
    xrdp \
    xorgxrdp \
    tigervnc-standalone-server \
    tigervnc-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 配置 XRDP
RUN sed -i 's/3389/3389/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=128/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/xserverbpp=24/xserverbpp=128/g' /etc/xrdp/xrdp.ini && \
    echo "startkde" > /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

# 配置 XRDP 使用 KDE Plasma
RUN echo '#!/bin/sh' > /etc/xrdp/startwm.sh && \
    echo '# XRDP KDE Plasma 启动脚本' >> /etc/xrdp/startwm.sh && \
    echo '' >> /etc/xrdp/startwm.sh && \
    echo '# 加载系统环境' >> /etc/xrdp/startwm.sh && \
    echo 'if [ -r /etc/default/locale ]; then' >> /etc/xrdp/startwm.sh && \
    echo '  . /etc/default/locale' >> /etc/xrdp/startwm.sh && \
    echo '  export LANG LANGUAGE' >> /etc/xrdp/startwm.sh && \
    echo 'fi' >> /etc/xrdp/startwm.sh && \
    echo '' >> /etc/xrdp/startwm.sh && \
    echo '# 设置输入法环境变量' >> /etc/xrdp/startwm.sh && \
    echo 'export GTK_IM_MODULE=fcitx' >> /etc/xrdp/startwm.sh && \
    echo 'export QT_IM_MODULE=fcitx' >> /etc/xrdp/startwm.sh && \
    echo 'export XMODIFIERS=@im=fcitx' >> /etc/xrdp/startwm.sh && \
    echo 'export SDL_IM_MODULE=fcitx' >> /etc/xrdp/startwm.sh && \
    echo '' >> /etc/xrdp/startwm.sh && \
    echo '# 设置 KDE 环境变量' >> /etc/xrdp/startwm.sh && \
    echo 'export XDG_SESSION_TYPE=x11' >> /etc/xrdp/startwm.sh && \
    echo 'export XDG_SESSION_DESKTOP=KDE' >> /etc/xrdp/startwm.sh && \
    echo 'export XDG_CURRENT_DESKTOP=KDE' >> /etc/xrdp/startwm.sh && \
    echo 'export DESKTOP_SESSION=plasma' >> /etc/xrdp/startwm.sh && \
    echo '' >> /etc/xrdp/startwm.sh && \
    echo '# 启动 D-Bus（如果没有运行）' >> /etc/xrdp/startwm.sh && \
    echo 'if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then' >> /etc/xrdp/startwm.sh && \
    echo '    eval $(dbus-launch --sh-syntax --exit-with-session)' >> /etc/xrdp/startwm.sh && \
    echo 'fi' >> /etc/xrdp/startwm.sh && \
    echo '' >> /etc/xrdp/startwm.sh && \
    echo '# 启动输入法（后台）' >> /etc/xrdp/startwm.sh && \
    echo 'fcitx5 -d 2>/dev/null || fcitx -d 2>/dev/null &' >> /etc/xrdp/startwm.sh && \
    echo '' >> /etc/xrdp/startwm.sh && \
    echo '# 等待一下让服务启动' >> /etc/xrdp/startwm.sh && \
    echo 'sleep 2' >> /etc/xrdp/startwm.sh && \
    echo '' >> /etc/xrdp/startwm.sh && \
    echo '# 启动 KDE Plasma（关键：使用 startplasma-x11）' >> /etc/xrdp/startwm.sh && \
    echo 'exec /usr/bin/startplasma-x11' >> /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

# ============================================
# X11 和显示服务器
# ============================================

RUN apt-get update && apt-get install -y --no-install-recommends \
    xorg \
    x11-xserver-utils \
    x11-utils \
    x11-apps \
    dbus-x11 \
    mesa-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 额外实用工具
# ============================================

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    vim \
    nano \
    htop \
    neofetch \
    wget \
    curl \
    git \
    unzip \
    zip \
    unrar* \
    p7zip-full \
    flatpak \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-noto-color-emoji \
    fonts-wqy-microhei \
    fonts-wqy-zenhei && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 音频支持
# ============================================

RUN apt-get update && apt-get install -y --no-install-recommends \
    pulseaudio \
    pulseaudio-utils \
    alsa-utils \
    pavucontrol-qt && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Build and install PulseAudio xRDP module
WORKDIR /tmp
RUN apt-get update && apt-get install -y --no-install-recommends \
    doxygen \
    lsb-release \
    build-essential \
    cmake \
    m4 \
    git \
    libpulse* \
    sudo \
    curl \
    wget \
    coreutils && \
    git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp && \
    cd pulseaudio-module-xrdp && \
    bash scripts/install_pulseaudio_sources_apt.sh && \
    ./bootstrap && \
    ./configure PULSE_DIR=$HOME/pulseaudio.src && \
    make -j"$(nproc)" install && \
    cd / && \
    rm -rf /tmp/pulseaudio-module-xrdp && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /
RUN sudo apt update && sudo apt install software-proper* -y
# RUN sudo add-apt-repository ppa:xtradeb/apps
# RUN sudo apt update
# RUN sudo apt install chromium -y
# Install Ansible via Pip.
# RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
RUN pip3 install --break-system-packages $pip_packages

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ollama
# RUN curl -fsSL https://ollama.com/install.sh | sh

# Install Ansible inventory file.
RUN mkdir -vp /etc/ansible
RUN echo '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

# 创建 KDE 用户
RUN useradd -m -s /bin/bash -G sudo,audio,video docker && \
    echo "matrix0523:matrix0523" | chpasswd && \
    echo "matrix0523 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    usermod -aG audio,video Administrator && \
    usermod -aG audio,video matrix0523

# 为 XRDP 创建必要的目录
RUN mkdir -p /var/run/xrdp && \
    mkdir -p /var/run/xrdp-sesman && \
    chown xrdp:xrdp /var/run/xrdp 2>/dev/null || true && \
    chown xrdp:xrdp /var/run/xrdp-sesman 2>/dev/null || true

# 清理
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/* \
           /var/cache/apt/archives/*

# Configure MOTD and bash settings
RUN echo "███████╗██╗   ██╗███╗   ██╗███████╗██╗  ██╗██╗███╗   ██╗███████╗ ██████╗██╗      ██████╗ ██╗   ██╗██████╗ " > /etc/motd && \
    echo "██╔════╝██║   ██║████╗  ██║██╔════╝██║  ██║██║████╗  ██║██╔════╝██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗" >> /etc/motd && \
    echo "███████╗██║   ██║██╔██╗ ██║███████╗███████║██║██╔██╗ ██║█████╗  ██║     ██║     ██║   ██║██║   ██║██║  ██║" >> /etc/motd && \
    echo "╚════██║██║   ██║██║╚██╗██║╚════██║██╔══██║██║██║╚██╗██║██╔══╝  ██║     ██║     ██║   ██║██║   ██║██║  ██║" >> /etc/motd && \
    echo "███████║╚██████╔╝██║ ╚████║███████║██║  ██║██║██║ ╚████║███████╗╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝" >> /etc/motd && \
    echo "╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝ ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝ " >> /etc/motd && \
    echo "                                                                                                          " >> /etc/motd && \
    echo "if [ -t 1 ]; then" >> /etc/bash.bashrc && \
    echo "  if command -v run-parts >/dev/null 2>&1 && [ -d /etc/update-motd.d ]; then" >> /etc/bash.bashrc && \
    echo "    run-parts /etc/update-motd.d > /tmp/_motd" >> /etc/bash.bashrc && \
    echo "    cat /etc/motd" >> /etc/bash.bashrc && \
    echo "    cat /tmp/_motd" >> /etc/bash.bashrc && \
    echo "    rm -f /tmp/_motd" >> /etc/bash.bashrc && \
    echo "  else" >> /etc/bash.bashrc && \
    echo "    cat /etc/motd" >> /etc/bash.bashrc && \
    echo "  fi" >> /etc/bash.bashrc && \
    echo "fi" >> /etc/bash.bashrc && \
    # Create welcome message for MOTD
    echo '#!/bin/sh' > /etc/update-motd.d/10-uname && \
    echo 'echo "👋 Welcome to SunshineCloud Codespaces! You are on our default image."' >> /etc/update-motd.d/10-uname && \
    echo 'echo "   - It includes runtimes and tools for Python, Node.js, Docker, and more. See the full list here: https://aka.ms/ghcs-default-image"' >> /etc/update-motd.d/10-uname && \
    echo 'echo "   - Want to use a custom image instead? Learn more here: https://aka.ms/configure-codespace"' >> /etc/update-motd.d/10-uname && \
    echo 'echo ""' >> /etc/update-motd.d/10-uname && \
    echo 'echo "🔍 To explore VS Code to its fullest, search using the Command Palette (Cmd/Ctrl + Shift + P or F1)."' >> /etc/update-motd.d/10-uname && \
    echo 'echo ""' >> /etc/update-motd.d/10-uname && \
    echo 'echo "📝 Edit away, run your app as usual, and we'"'"'ll automatically make it available for you to access."' >> /etc/update-motd.d/10-uname && \
    echo 'echo ""' >> /etc/update-motd.d/10-uname && \
    chmod +x /etc/update-motd.d/10-uname

# Install Homebrew
RUN mkdir -vp /SunshineCloud/Homebrew/ && \
    git clone --depth=1 https://github.com/Homebrew/brew /SunshineCloud/Homebrew && \
    chown -R matrix0523:matrix0523 /SunshineCloud/Homebrew && \
    echo 'export PATH="/SunshineCloud/Homebrew/bin:$PATH"' >> /home/matrix0523/.bashrc

# Install Visual Studio Code
RUN echo "Installing Visual Studio Code..." && \
    # Install dependencies
    apt-get update && \
    apt-get install -y --no-install-recommends wget gpg apt-transport-https && \
    # Add Microsoft GPG key and repository
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg && \
    install -D -o root -g root -m 644 /tmp/microsoft.gpg /usr/share/keyrings/microsoft.gpg && \
    rm -f /tmp/microsoft.gpg && \
    # Create VS Code repository configuration
    echo "Types: deb" > /etc/apt/sources.list.d/vscode.sources && \
    echo "URIs: https://packages.microsoft.com/repos/code" >> /etc/apt/sources.list.d/vscode.sources && \
    echo "Suites: stable" >> /etc/apt/sources.list.d/vscode.sources && \
    echo "Components: main" >> /etc/apt/sources.list.d/vscode.sources && \
    echo "Architectures: amd64,arm64,armhf" >> /etc/apt/sources.list.d/vscode.sources && \
    echo "Signed-By: /usr/share/keyrings/microsoft.gpg" >> /etc/apt/sources.list.d/vscode.sources && \
    # Update package cache and install VS Code
    apt-get update && \
    apt-get install -y --no-install-recommends code && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "Visual Studio Code installation completed"

# 暴露 XRDP 端口
EXPOSE 3389

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
ENTRYPOINT [ "/lib/systemd/systemd" ]
