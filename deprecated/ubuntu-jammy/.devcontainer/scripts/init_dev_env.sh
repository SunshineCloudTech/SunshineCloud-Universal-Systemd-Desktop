#!/bin/bash
# filepath: install_dev_environment.sh

set -e  # 遇到错误时退出

echo "=========================================="
echo "开始安装开发环境 (Docker + Node.js + DevContainers CLI)"
echo "适用于 WSL Debian 系统"
echo "=========================================="

# 检查是否为root用户
if [ "$EUID" -eq 0 ]; then
    echo "警告: 请不要以root用户运行此脚本"
    echo "请使用普通用户运行: ./install_dev_environment.sh"
    exit 1
fi

# 检查是否在WSL中
if ! grep -qE "(microsoft|WSL)" /proc/version 2>/dev/null; then
    echo "警告: 此脚本专为WSL环境设计"
    read -p "是否继续? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "步骤 1/5: 更新系统包列表..."
sudo apt-get update

echo "步骤 2/5: 安装必要的依赖包..."
sudo apt-get install -y --no-install-recommends \
    curl \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    build-essential

echo "步骤 3/5: 安装 Docker..."
echo "正在下载并执行 Docker 官方安装脚本..."

# 检查curl是否可用，否则使用wget
if command -v curl &> /dev/null; then
    echo "使用 curl 安装 Docker..."
    curl -fsSL https://raw.githubusercontent.com/docker/docker-install/master/install.sh | sh
else
    echo "使用 wget 安装 Docker..."
    wget -O- https://raw.githubusercontent.com/docker/docker-install/master/install.sh | sh
fi

echo "配置 Docker 用户权限..."
sudo usermod -aG docker $USER

echo "步骤 4/5: 安装 Node.js 22.x..."
echo "正在添加 NodeSource 仓库..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -

echo "正在安装 Node.js..."
sudo apt-get install -y --no-install-recommends nodejs

echo "验证 Node.js 和 npm 安装..."
node_version=$(node --version)
npm_version=$(npm --version)
echo "Node.js 版本: $node_version"
echo "npm 版本: $npm_version"

echo "步骤 5/5: 安装 DevContainers CLI..."
echo "正在全局安装 @devcontainers/cli..."
sudo npm install -g @devcontainers/cli

echo "=========================================="
echo "安装完成!"
echo "=========================================="
echo "已安装的组件:"
echo "✓ Docker: $(docker --version 2>/dev/null || echo '需要重新登录后生效')"
echo "✓ Node.js: $node_version"
echo "✓ npm: $npm_version"
echo "✓ DevContainers CLI: $(devcontainer --version 2>/dev/null || echo '已安装')"
echo ""
echo "重要提示:"
echo "1. 请重新登录或运行 'newgrp docker' 以使 Docker 权限生效"
echo "2. 在 WSL 中，您可能需要手动启动 Docker 服务:"
echo "   sudo service docker start"
echo "3. 建议重启 WSL 实例以确保所有更改生效"
echo ""
echo "验证安装:"
echo "  docker --version"
echo "  node --version"
echo "  npm --version"
echo "  devcontainer --version"
echo "=========================================="