#!/usr/bin/env bash
#===================================================================================
# Python 安全补丁安装脚本
#
# 功能：修复标准 Python 环境中存在安全漏洞的包
# 用途：
#   - 升级存在安全漏洞的 Python 包到安全版本
#   - 针对使用 pip 管理的标准 Python 环境
#   - 确保 Python 运行时环境的安全性
#
# 与 patch-conda 的区别：
#   - patch-conda: 专门处理 Conda 环境的包管理和安全修复
#   - patch-python: 处理标准 Python/pip 环境的包管理和安全修复
#
# 包更新策略：
#   1. 卸载现有的不安全版本
#   2. 安装指定的安全版本
#   3. 验证更新结果
#   4. 显示包信息确认版本
#
# 安全漏洞来源：
#   - GitHub Security Advisories
#   - PyPI Security 公告
#   - CVE 数据库
#   - Python Security Response Team 通告
#
# 适用场景：
#   - 标准 Python 项目开发环境
#   - 微服务和 Web 应用部署
#   - 数据科学项目（非 Conda 环境）
#   - CI/CD 安全扫描修复
#
# 维护说明：
#   - 定期监控 Python 包安全公告
#   - 更新脚本中的包版本号
#   - 测试包升级对项目的影响
#   - 记录修复的具体漏洞信息
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

echo "开始执行 Python 安全补丁..."

# 验证运行权限
if [ "$(id -u)" -ne 0 ]; then
    echo -e '错误：此脚本必须以 root 身份运行。'
    echo -e '请使用 sudo、su 或在 Dockerfile 中添加 "USER root"。'
    exit 1
fi

echo "配置系统环境..."

# 确保登录 shell 获得正确的 PATH 环境变量
# 这对于找到正确的 Python 解释器很重要
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
# 功能：安全地更新 Python 包到指定版本
# 参数：
#   $1: Python 解释器路径（例如：/usr/local/python/current/bin/python3）
#   $2: 包名（例如：requests）
#   $3: 目标版本号（例如：2.31.0）
# 流程：
#   1. 卸载现有版本避免冲突
#   2. 安装指定的安全版本
#   3. 验证安装结果并显示包信息
update_package() {
    PYTHON_PATH=$1
    PACKAGE=$2
    VERSION=$3

    echo ""
    echo "处理 Python 包安全更新："
    echo "  Python 路径: $PYTHON_PATH"
    echo "  包名: $PACKAGE"
    echo "  目标版本: $VERSION"
    echo "----------------------------------------"
    
    # 步骤1: 卸载现有版本
    echo "正在卸载现有版本..."
    sudo_if "$PYTHON_PATH -m pip uninstall --yes $PACKAGE" || {
        echo "警告：包 $PACKAGE 可能未安装，继续安装新版本..."
    }
    
    # 步骤2: 安装指定的安全版本
    echo "正在安装安全版本 $VERSION..."
    sudo_if "$PYTHON_PATH -m pip install --upgrade --no-cache-dir $PACKAGE==$VERSION"
    
    # 步骤3: 验证安装结果
    echo "验证安装结果..."
    sudo_if "$PYTHON_PATH -m pip show --no-python-version-warning $PACKAGE" || {
        echo "错误：无法验证包 $PACKAGE 的安装状态"
        return 1
    }
    
    echo "✓ $PACKAGE 安全更新完成"
    echo ""
}

echo ""
echo "Python 环境安全补丁系统"
echo "========================================"
echo "目标用户: $USERNAME"
echo "当前日期: $(date)"
echo ""

# 验证 Python 环境是否可用
PYTHON_EXECUTABLE="/usr/local/python/current/bin/python3"
if ! command -v "$PYTHON_EXECUTABLE" > /dev/null 2>&1; then
    echo "警告：标准 Python 路径不存在，尝试查找系统 Python..."
    PYTHON_EXECUTABLE=$(which python3 2>/dev/null || which python 2>/dev/null || echo "")
    
    if [ -z "$PYTHON_EXECUTABLE" ]; then
        echo "错误：未找到可用的 Python 解释器"
        echo "请确保 Python 功能特性已正确安装"
        exit 1
    fi
fi

echo "使用 Python 解释器: $PYTHON_EXECUTABLE"
echo "Python 版本:"
sudo_if "$PYTHON_EXECUTABLE --version"

echo ""
echo "开始应用 Python 包安全补丁..."
echo "========================================"

# 注意：这里可以添加具体的安全补丁
# 示例（取消注释以启用）：
# echo "应用安全补丁: requests 包 (示例)"
# update_package "$PYTHON_EXECUTABLE" "requests" "2.31.0"

# echo "应用安全补丁: urllib3 包 (示例)"  
# update_package "$PYTHON_EXECUTABLE" "urllib3" "1.26.18"

echo ""
echo "Python 包安全补丁检查完成！"
echo ""
echo "说明："
echo "  - 当前脚本框架已就绪，可根据安全公告添加具体补丁"
echo "  - 请定期检查 PyPI 安全公告和 CVE 数据库"
echo "  - 在生产环境部署前测试包更新的兼容性"
echo ""
echo "添加新补丁的方法："
echo "  1. 在脚本中调用 update_package 函数"
echo "  2. 提供 Python 路径、包名和安全版本号"
echo "  3. 在注释中记录相关的安全公告链接"

echo "Python 安全补丁功能特性完成！"
