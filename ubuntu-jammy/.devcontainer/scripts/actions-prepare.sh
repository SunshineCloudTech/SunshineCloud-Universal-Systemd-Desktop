#!/bin/bash

# 定义要卸载的软件包列表
PACKAGES=(
    # 开发工具和依赖
    g++ gcc make autoconf automake pkg-config libtool libc++-dev libc++abi-dev
    libmagic-dev libsqlite3-dev libyaml-dev fakeroot dpkg-dev bison swig texinfo

    # # 压缩和打包工具
    # bzip2 xz-utils zip unzip tar p7zip-full p7zip-rar pigz xorriso

    # 字体和图像处理相关
    fonts-noto-color-emoji imagemagick libmagickcore-dev libmagickwand-dev

    # 多媒体相关工具
    mediainfo upx ftp aria2

    # 网络工具
    dnsutils netcat net-tools iproute2 iputils-ping openssh-client

    # 其他可能占用空间较大的工具
    ant sqlite3 texinfo sphinxsearch azure-cli dotnet-sdk-6.0 dotnet-sdk-7.0 dotnet-sdk-8.0 
    esl-erlang firefox google-chrome-stable google-cloud-cli hhvm libgl1-mesa-dri llvm-10-dev 
    llvm-11-dev llvm-12-dev microsoft-edge-stable mongodb-mongosh mysql-server-core-8.0 temurin-11-jdk 
    temurin-17-jdk temurin-21-jdk temurin-8-jdk  gcc-10  kubectl libclang-common-10-dev 
    libclang-common-11-dev libclang-common-12-dev libllvm10 libllvm11 libllvm12 mono-devel mono-llvm-tools 
    mysql-client-core-8.0 openjdk-11-jre-headless postgresql-14 powershell openjdk* llvm* 
)

echo "开始卸载占用空间较大的软件包..."

# 遍历卸载软件包
for PACKAGE in "${PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii\s\+$PACKAGE"; then
        echo "正在卸载 $PACKAGE..."
        sudo apt-get remove --purge -y "$PACKAGE"
    else
        echo "$PACKAGE 未安装，跳过..."
    fi
done

# 清理系统中的多余依赖和缓存
echo "清理不必要的依赖和缓存..."
sudo apt-get autoremove --purge -y
sudo apt-get clean

echo "卸载和清理完成！"

# 显示系统中仍占用较多空间的软件包
echo "以下是仍占用较大空间的软件包："
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 20 | awk '{print $2}' | xargs dpkg-query -Wf '${Package} (${Installed-Size} KB)\n'
# 清理系统缓存和垃圾文件
echo "开始清理系统缓存和垃圾文件..."

# 清理 apt 缓存
echo "清理 APT 缓存..."
sudo apt-get clean
sudo apt-get autoclean

# 清理日志文件
echo "清理旧日志文件..."
sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;

# 清理临时文件
echo "清理 /tmp 文件夹中的临时文件..."
sudo rm -rf /tmp/*

# 清理用户的缓存文件
echo "清理用户缓存文件..."
USER_CACHE_DIRS=(
    "$HOME/.cache"
    "$HOME/.config/google-chrome/Default/Cache"
    "$HOME/.config/google-chrome/Default/Application Cache"
    "$HOME/.mozilla/firefox/*/cache2"
    "$HOME/.thumbnails"
    "$HOME/.local/share/Trash"
)

for dir in "${USER_CACHE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "清理 $dir..."
        rm -rf "$dir"/*
    fi
done

# 清理系统缓存
echo "清理内存缓存..."
sudo sync
sudo sysctl -w vm.drop_caches=3

# 清理孤立包（未使用的依赖）
echo "清理孤立软件包..."
sudo apt-get autoremove --purge -y

# 清理 Docker 镜像和容器（如果安装了 Docker）
# if command -v docker &> /dev/null; then
#    echo "清理 Docker 镜像和容器..."
#    docker system prune -a -f
# fi

# 清理 npm 缓存（如果安装了 npm）
if command -v npm &> /dev/null; then
    echo "清理 npm 缓存..."
    npm cache clean --force
fi

# 清理 pip 缓存（如果安装了 pip）
if command -v pip &> /dev/null; then
    echo "清理 pip 缓存..."
    pip cache purge
fi

echo "清理完成！系统运行中的垃圾文件已清理。"

# 检查磁盘使用情况
echo "当前磁盘使用情况："
df -h


echo "完成！"