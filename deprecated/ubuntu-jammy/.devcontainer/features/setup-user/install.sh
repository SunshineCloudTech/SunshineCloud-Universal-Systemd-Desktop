#!/usr/bin/env bash
#===================================================================================
# 用户环境配置安装脚本
#
# 功能：为 AI/ML 开发容器设置用户配置
# 用途：
#   - 配置 AI/ML 开发环境的用户目录结构
#   - 建立工具链之间的符号链接
#   - 设置正确的文件权限和用户组
#   - 优化 GitHub Codespaces 兼容性
#
# 配置的开发环境：
#   - Node.js (通过 NVM 管理)
#   - Python (通过 Conda/系统管理)
#
# 目录结构说明：
#   - /usr/local/*: 系统级别的工具安装
#   - /home/matrix0523/*: Codespaces 兼容的用户目录
#   - /home/${USERNAME}/*: 实际用户的个人目录
#   - /opt/*: 系统可选软件目录
#
# 维护者：SunshineCloud 团队
# 基于：Microsoft DevContainer Features
#===================================================================================
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# 设置默认用户名（从 devcontainer.json 的 common-utils 配置）
USERNAME=${USERNAME:-"matrix0523"}

# 启用详细输出和严格错误处理
set -eux

echo "开始配置 AI/ML 用户开发环境..."

# 验证运行权限
if [ "$(id -u)" -ne 0 ]; then
    echo -e '错误：此脚本必须以 root 身份运行。'
    echo -e '请使用 sudo、su 或在 Dockerfile 中添加 "USER root"。'
    exit 1
fi

echo "配置系统环境变量..."

# 确保登录 shell 获得正确的 PATH 环境变量
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# 设置非交互式安装模式
export DEBIAN_FRONTEND=noninteractive

# 条件执行函数
sudo_if() {
    COMMAND="$*"
    if [ "$(id -u)" -eq 0 ] && [ "$USERNAME" != "root" ]; then
        su - "$USERNAME" -c "$COMMAND"
    else
        $COMMAND
    fi
}


echo "配置 Node.js 环境 (NVM)..."
# Node.js 通过 NVM (Node Version Manager) 管理
# 为 GitHub Codespaces 兼容性创建标准路径链接
if [ -d "/usr/local/share/nvm" ]; then
    NODE_PATH="/home/matrix0523/nvm"
    ln -snf /usr/local/share/nvm "$NODE_PATH" || echo "Node.js 链接已存在或无法创建"
    
    # 创建 current 链接指向默认版本
    if [ -d "$NODE_PATH" ]; then
        mkdir -p /home/${USERNAME}/.nvm
        ln -snf "$NODE_PATH" /home/${USERNAME}/.nvm/nvm || true
        echo "✓ Node.js 环境链接: $NODE_PATH"
    fi
else
    echo "⚠ Node.js NVM 未安装，跳过配置"
fi

echo "配置 Python 环境..."
# Python 版本管理，同时兼容系统级和用户级配置
if [ -d "/usr/local/python" ]; then
    PYTHON_PATH="/home/${USERNAME}/.python/current"
    mkdir -p /home/${USERNAME}/.python
    ln -snf /usr/local/python/current "$PYTHON_PATH" || echo "Python 链接已存在或无法创建"
    echo "✓ Python 环境链接: $PYTHON_PATH"
else
    echo "⚠ Python 安装目录未找到，跳过配置"
fi

echo ""
echo "设置目录权限和用户组..."
echo "============================================="

echo "配置用户主目录权限..."
# 设置用户主目录的完整权限
HOME_DIR="/home/${USERNAME}/"
chown -R ${USERNAME}:${USERNAME} ${HOME_DIR}
chmod -R g+r+w "${HOME_DIR}"                    # 设置组读写权限
# 使用 find -exec 处理包含空格的目录名
find "${HOME_DIR}" -type d -exec chmod g+s {} \; 2>/dev/null || echo "部分用户目录组继承权限设置跳过"

echo "配置 /opt 目录权限..."
# 设置 /opt 目录权限
OPT_DIR="/opt/"
chown -R ${USERNAME}:${USERNAME} ${OPT_DIR} 2>/dev/null || echo "部分 /opt 目录权限设置跳过"
chmod -R g+r+w "${OPT_DIR}" 2>/dev/null || echo "部分 /opt 目录权限设置跳过"
# 使用 find -exec 处理包含空格的目录名，并添加错误处理
find "${OPT_DIR}" -type d -exec chmod g+s {} \; 2>/dev/null || echo "部分 /opt 目录组继承权限设置跳过"

echo ""
echo "配置 sudo 安全路径..."
echo "============================================="

# 为用户配置 sudo 时的安全路径
# 包含开发工具的路径，确保 sudo 命令可以找到开发工具
SECURE_PATH="/home/matrix0523/nvm/current/bin:/home/${USERNAME}/.python/current/bin:/home/${USERNAME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"

echo "设置用户 ${USERNAME} 的 sudo 安全路径..."
mkdir -p /etc/sudoers.d
echo "Defaults secure_path=\"${SECURE_PATH}\"" > /etc/sudoers.d/${USERNAME}
echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}
chmod 0440 /etc/sudoers.d/${USERNAME}

echo ""
echo "✓ 用户环境配置完成！"
echo ""
echo "配置总结："
echo "=========================================="
echo "用户名: ${USERNAME}"
echo "Node.js 路径: /home/matrix0523/nvm"
echo "Python 路径: /home/${USERNAME}/.python/current"
echo ""
echo "权限设置: ✓ 已完成"
echo ""
echo "AI/ML 开发环境已准备就绪！"

echo "用户环境配置功能特性完成！"
