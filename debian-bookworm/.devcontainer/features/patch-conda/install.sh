#!/usr/bin/env bash
#===================================================================================
# Conda 安全补丁安装脚本
#
# 功能：修复 Conda 环境中存在安全漏洞的 Python 包
# 用途：
#   - 升级存在安全漏洞的 Python 包到安全版本
#   - 确保开发环境符合安全最佳实践
#   - 解决 Conda 官方仓库更新滞后的问题
#
# 当前修复的安全问题：
#   1. cryptography 包安全漏洞 (GHSA-v8gr-m533-ghj9)
#      - 影响：加密操作可能受到攻击
#      - 修复版本：41.0.4+
#   2. urllib3 包安全漏洞 (GHSA-v845-jxx5-vc9f)
#      - 影响：HTTP 请求处理存在安全风险
#      - 修复版本：1.26.18+
#
# 安全漏洞来源：
#   - GitHub Security Advisories
#   - CVE (Common Vulnerabilities and Exposures) 数据库
#   - Python Security 公告
#
# 适用场景：
#   - 生产环境容器部署
#   - 企业级开发环境
#   - 安全合规要求严格的项目
#   - CI/CD 管道安全加固
#
# 维护说明：
#   - 定期检查新的安全公告
#   - 更新修复版本号
#   - 测试包升级的兼容性
#
# 维护者：SunshineCloud 团队
#===================================================================================
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# 设置默认用户名
USERNAME=${USERNAME:-"matrix0523"}

# 启用详细输出和严格错误处理
set -eux

echo "开始执行 Conda 安全补丁..."

# 验证运行权限
if [ "$(id -u)" -ne 0 ]; then
    echo -e '错误：此脚本必须以 root 身份运行。'
    echo -e '请使用 sudo、su 或在 Dockerfile 中添加 "USER root"。'
    exit 1
fi

echo "配置系统环境..."

# 确保登录 shell 获得正确的 PATH 环境变量
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# 设置非交互式安装模式
export DEBIAN_FRONTEND=noninteractive

# 条件执行函数：根据当前用户决定是否使用 su 切换
sudo_if() {
    COMMAND="$*"
    if [ "$(id -u)" -eq 0 ] && [ "$USERNAME" != "root" ]; then
        echo "以用户 $USERNAME 身份执行: $COMMAND"
        su - "$USERNAME" -c "$COMMAND"
    else
        echo "直接执行: $COMMAND"
        $COMMAND
    fi
}

# Python 包更新函数
# 功能：卸载现有版本并安装指定的安全版本
# 参数：
#   $1: Python 解释器路径
#   $2: 包名
#   $3: 目标版本号
update_python_package() {
    PYTHON_PATH=$1
    PACKAGE=$2
    VERSION=$3

    echo "处理 Python 包: $PACKAGE -> $VERSION"
    echo "使用 Python: $PYTHON_PATH"
    
    # 先卸载现有版本，避免版本冲突
    echo "卸载现有版本..."
    sudo_if "$PYTHON_PATH -m pip uninstall --yes $PACKAGE" || true
    
    # 安装指定的安全版本
    echo "安装安全版本 $VERSION..."
    sudo_if "$PYTHON_PATH -m pip install --upgrade --no-cache-dir $PACKAGE==$VERSION"
    
    # 验证安装结果
    echo "验证安装结果..."
    sudo_if "$PYTHON_PATH -m pip show --no-python-version-warning $PACKAGE"
    
    echo "✓ $PACKAGE 更新完成"
}

# Conda 包更新函数
# 功能：使用 conda 命令更新包到指定版本
# 参数：
#   $1: 包名
#   $2: 目标版本号
update_conda_package() {
    PACKAGE=$1
    VERSION=$2

    echo "处理 Conda 包: $PACKAGE -> $VERSION"
    
    # 使用 conda install 命令更新到指定版本
    echo "通过 conda 安装版本 $VERSION..."
    sudo_if "conda install --yes $PACKAGE=$VERSION"
    
    echo "✓ $PACKAGE 更新完成"
}

echo "升级 Conda 环境的 pip..."
# 首先确保 pip 本身是最新版本
sudo_if /opt/conda/bin/python3 -m pip install --upgrade pip

echo ""
echo "开始应用安全补丁..."
echo "==============================================="

# 应用安全补丁
# 注意：这些是临时修复，直到 Conda 官方仓库包含修复版本

echo ""
echo "修复 1: cryptography 包安全漏洞"
echo "漏洞编号: GHSA-v8gr-m533-ghj9"
echo "详情: https://github.com/advisories/GHSA-v8gr-m533-ghj9"
echo "影响: 加密操作安全性问题"
# 升级 cryptography 到安全版本
update_python_package /opt/conda/bin/python3 cryptography "41.0.4"

echo ""
echo "修复 2: urllib3 包安全漏洞"
echo "漏洞编号: GHSA-v845-jxx5-vc9f" 
echo "详情: https://github.com/advisories/GHSA-v845-jxx5-vc9f"
echo "影响: HTTP 请求处理安全性问题"
# 升级 urllib3 到安全版本
update_conda_package urllib3 "1.26.18"

echo ""
echo "==============================================="
echo "✓ 所有安全补丁应用完成！"
echo ""
echo "已修复的安全问题："
echo "  - cryptography >= 41.0.4 (加密安全)"
echo "  - urllib3 >= 1.26.18 (HTTP 安全)"
echo ""
echo "建议定期检查和更新这些包以获取最新的安全修复。"

echo "Conda 安全补丁功能特性完成！"
