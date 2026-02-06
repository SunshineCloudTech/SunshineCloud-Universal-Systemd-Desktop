#!/usr/bin/env bash
#===================================================================================
# Node Version Switcher (NVS) 安装脚本
#
# 功能：安装和配置 NVS Node.js 版本管理器
# 用途：
#   - 管理多个 Node.js 版本的安装和切换
#   - 支持项目级别的 Node.js 版本绑定
#   - 提供跨平台的 Node.js 版本管理解决方案
#
# NVS 主要特性：
#   - 支持安装 LTS 和最新版本的 Node.js
#   - 自动检测项目的 .nvmrc 文件
#   - 支持别名和默认版本设置
#   - 与 npm、Yarn 包管理器集成
#
# 常用命令：
#   nvs add latest          # 安装最新版本
#   nvs add lts             # 安装最新 LTS 版本
#   nvs use 18.17.0         # 使用指定版本
#   nvs link 18.17.0        # 设置默认版本
#   nvs ls                  # 列出已安装版本
#
# 适用场景：
#   - 前端项目开发（React、Vue、Angular）
#   - 后端 Node.js 应用开发
#   - 全栈 JavaScript/TypeScript 项目
#   - 多项目维护，需要不同 Node.js 版本
#
# 维护者：SunshineCloud 团队
# 基于：Microsoft DevContainer Features 和 NVS 项目
#===================================================================================
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# 配置默认参数
USERNAME=${USERNAME:-"matrix0523"}    # 目标用户名
NVS_HOME=${NVS_HOME:-"/usr/local/nvs"} # NVS 安装目录

# 启用详细输出和严格错误处理
set -eux

echo "开始安装 Node Version Switcher (NVS)..."

# 验证运行权限
if [ "$(id -u)" -ne 0 ]; then
    echo -e '错误：此脚本必须以 root 身份运行。'
    echo -e '请使用 sudo、su 或在 Dockerfile 中添加 "USER root"。'
    exit 1
fi

echo "配置系统环境变量..."

# 确保登录 shell 获得正确的 PATH 环境变量
# 这对于 NVS 命令的正确执行很重要
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# 检查并更新软件包列表的函数
apt_get_update_if_needed()
{
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "更新软件包列表..."
        apt-get update
    else
        echo "跳过软件包列表更新（已是最新）。"
    fi
}

# 检查并安装必需的系统包
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        echo "安装缺失的系统包: $@"
        apt_get_update_if_needed
        apt-get -y install --no-install-recommends "$@"
    else
        echo "系统包已安装: $@"
    fi
}

# 更新 shell 配置文件的函数
# 确保 NVS 在新的 shell 会话中可用
updaterc() {
    echo "更新 Shell 配置文件（bash 和 zsh）..."
    
    # 更新 bash 配置
    if [[ "$(cat /etc/bash.bashrc)" != *"$1"* ]]; then
        echo -e "$1" >> /etc/bash.bashrc
        echo "已更新 /etc/bash.bashrc"
    fi
    
    # 更新 zsh 配置（如果存在）
    if [ -f "/etc/zsh/zshrc" ] && [[ "$(cat /etc/zsh/zshrc)" != *"$1"* ]]; then
        echo -e "$1" >> /etc/zsh/zshrc
        echo "已更新 /etc/zsh/zshrc"
    fi
}

# 设置非交互式安装模式
export DEBIAN_FRONTEND=noninteractive

echo "配置 NVS 用户组和权限..."

# 创建 nvs 系统组（如果不存在）
# 这允许多个用户共享 NVS 安装
if ! cat /etc/group | grep -e "^nvs:" > /dev/null 2>&1; then
    echo "创建 nvs 用户组..."
    groupadd -r nvs
else
    echo "nvs 用户组已存在。"
fi

# 将指定用户添加到 nvs 组
echo "将用户 ${USERNAME} 添加到 nvs 组..."
usermod -a -G nvs "${USERNAME}"

echo "安装 NVS 核心文件..."

# 配置 Git 安全目录，允许在容器中克隆
git config --global --add safe.directory ${NVS_HOME}

# 创建 NVS 安装目录
mkdir -p ${NVS_HOME}

echo "从 GitHub 克隆 NVS 仓库..."
# 克隆 NVS 仓库
# --depth 1: 只克隆最新提交，减少下载时间
# -c advice.detachedHead=false: 抑制分离 HEAD 警告
git clone -c advice.detachedHead=false --depth 1 https://github.com/jasongin/nvs ${NVS_HOME} 2>&1

# 记录源仓库信息，用于后续更新和调试
echo "记录 NVS 源信息..."
(cd ${NVS_HOME} && git remote get-url origin && echo $(git log -n 1 --pretty=format:%H -- .)) > ${NVS_HOME}/.git-remote-and-commit

echo "执行 NVS 安装程序..."
# 运行 NVS 自身的安装脚本
# 这会设置必要的符号链接和配置
bash ${NVS_HOME}/nvs.sh install

echo "清理 NVS 安装缓存..."
# 清理缓存文件，减少容器大小
rm -f ${NVS_HOME}/cache/* 2>/dev/null || true

# 清理 Git 仓库文件，进一步减少容器大小
echo "清理 Git 历史文件..."
rm -rf ${NVS_HOME}/.git

echo "配置 Shell 环境..."
# 将 NVS 添加到系统 PATH
# 使用条件检查避免重复添加
updaterc "# NVS (Node Version Switcher) 配置\nif [[ \"\${PATH}\" != *\"${NVS_HOME}\"* ]]; then export PATH=${NVS_HOME}:\${PATH}; fi"

echo "设置文件权限和所有权..."
# 将 NVS 目录的所有权分配给用户和 nvs 组
chown -R "${USERNAME}:nvs" "${NVS_HOME}"

# 设置组权限，允许 nvs 组成员管理 NVS
chmod -R g+r+w "${NVS_HOME}"

# 为目录设置组继承权限
find "${NVS_HOME}" -type d | xargs -n 1 chmod g+s

echo "创建用户特定的 NVS 符号链接..."
# 为 Codespace 用户创建符号链接（如果目录存在）
# 这确保了与 GitHub Codespaces 的兼容性
NVS_USER_DIR="/home/matrix0523/.nvs"
if [ -d "/home/matrix0523" ]; then
    mkdir -p ${NVS_USER_DIR}
    ln -snf ${NVS_HOME}/* $NVS_USER_DIR 2>/dev/null || true
    echo "已为 Codespace 用户创建 NVS 链接。"
fi

echo ""
echo "✓ NVS (Node Version Switcher) 安装完成！"
echo ""
echo "现在可以使用以下命令："
echo "  nvs add latest          # 安装最新版本的 Node.js"
echo "  nvs add lts             # 安装最新 LTS 版本"
echo "  nvs add 18.17.0         # 安装指定版本"
echo "  nvs use 18.17.0         # 切换到指定版本"
echo "  nvs link 18.17.0        # 设置默认版本"
echo "  nvs ls                  # 列出已安装的版本"
echo "  nvs ls-remote           # 列出可用的远程版本"
echo ""
echo "重新启动终端或运行 'source ~/.bashrc' 以使 NVS 生效。"

echo "NVS 功能特性安装完成！"
