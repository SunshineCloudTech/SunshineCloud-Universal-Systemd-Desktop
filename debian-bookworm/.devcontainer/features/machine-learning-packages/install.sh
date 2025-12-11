#!/usr/bin/env bash
#===================================================================================
# 机器学习包集合安装脚本
#
# 功能：批量安装常用的机器学习和数据科学 Python 包
# 用途：
#   - 为数据科学项目提供完整的包环境
#   - 支持机器学习模型开发和训练
#   - 提供数据处理、可视化、分析工具
#
# 安装的包列表：
#   - numpy: 数值计算基础库，支持多维数组操作
#   - pandas: 数据处理和分析库，提供 DataFrame 数据结构
#   - scipy: 科学计算库，扩展 NumPy 功能
#   - matplotlib: 基础绘图库，生成静态图表
#   - seaborn: 统计绘图库，基于 matplotlib 的高级接口
#   - scikit-learn: 机器学习算法库，包含分类、回归、聚类等
#   - torch (PyTorch): 深度学习框架，支持 GPU 加速
#   - requests: HTTP 库，用于 API 调用和数据获取
#   - plotly: 交互式图表库，支持 Web 可视化
#
# 适用场景：
#   - 数据分析和探索性数据分析 (EDA)
#   - 机器学习模型开发和评估
#   - 深度学习研究和应用
#   - 数据可视化和报告生成
#   - 科学计算和数值分析
#
# 维护者：SunshineCloud 团队
# 基于：Microsoft DevContainer Features 模板
#===================================================================================
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# 获取用户名，默认为 matrix0523
USERNAME=${USERNAME:-"matrix0523"}

# 启用详细输出和严格错误处理
# -e: 遇到错误立即退出
# -u: 使用未定义变量时报错
# -x: 显示执行的每条命令（调试模式）
set -eux

echo "开始安装机器学习包集合..."

# 验证脚本运行权限，必须以 root 身份运行
if [ "$(id -u)" -ne 0 ]; then
    echo -e '错误：此脚本必须以 root 身份运行。'
    echo -e '请使用 sudo、su 或在 Dockerfile 中添加 "USER root"。'
    exit 1
fi

echo "配置环境变量和路径..."

# 确保登录 shell 获得正确的 PATH 环境变量
# 当用户通过 ENV 更新 PATH 时，需要在配置文件中恢复
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# 定义条件执行函数
# 如果以 root 运行且用户不是 root，则切换到指定用户执行命令
# 否则直接执行命令
sudo_if() {
    COMMAND="$*"
    if [ "$(id -u)" -eq 0 ] && [ "$USERNAME" != "root" ]; then
        su - "$USERNAME" -c "$COMMAND"
    else
        "$COMMAND"
    fi
}

# 设置非交互式模式，避免安装过程中的提示
export DEBIAN_FRONTEND=noninteractive

# 定义 Python 包安装函数
# 参数：
#   $1: 包名
#   $2: 可选的额外安装选项
install_python_package() {
    PACKAGE=${1:-""}
    OPTIONS=${2:-""}
    
    echo "处理包: $PACKAGE"
    
    # 先尝试卸载现有版本，避免版本冲突
    # 使用 --yes 自动确认，忽略包不存在的错误
    sudo_if /usr/local/python/current/bin/python -m pip uninstall --yes $PACKAGE 2>/dev/null || true
    
    echo "正在安装 $PACKAGE..."
    # 安装包的选项说明：
    # --user: 安装到用户目录，避免系统权限问题
    # --upgrade: 升级到最新版本
    # --no-cache-dir: 不使用缓存，确保获取最新版本
    sudo_if /usr/local/python/current/bin/python -m pip install --user --upgrade --no-cache-dir $PACKAGE $OPTIONS
    
    echo "✓ $PACKAGE 安装完成"
}

echo "验证 Python 和 pip 环境..."

# 检查 Python 和 pip 是否正确安装
if [[ "$(python --version)" != "" ]] && [[ "$(pip --version)" != "" ]]; then
    echo "Python 环境检查通过，开始安装机器学习包..."
    
    echo "安装数值计算基础包..."
    # NumPy: 多维数组操作，是其他科学计算包的基础
    install_python_package "numpy"
    
    echo "安装数据处理包..."
    # Pandas: 数据处理和分析，提供 DataFrame 和 Series 数据结构
    install_python_package "pandas"
    
    echo "安装科学计算包..."
    # SciPy: 科学计算，包含统计、优化、积分等功能
    install_python_package "scipy"
    
    echo "安装数据可视化包..."
    # Matplotlib: 基础绘图库，支持多种图表类型
    install_python_package "matplotlib"
    # Seaborn: 统计可视化库，提供更美观的默认样式
    install_python_package "seaborn"
    
    echo "安装机器学习包..."
    # Scikit-learn: 机器学习库，包含分类、回归、聚类、降维等算法
    install_python_package "scikit-learn"
    
    echo "安装深度学习框架..."
    # PyTorch: 深度学习框架，使用 CPU 版本以减少容器大小
    # CPU 版本适合大多数开发和小规模训练场景
    # install_python_package "torch" "--index-url https://download.pytorch.org/whl/cpu"
    
    echo "安装网络和可视化扩展包..."
    # Requests: HTTP 库，用于 API 调用和数据获取
    install_python_package "requests"
    # Plotly: 交互式图表库，支持在 Jupyter 中显示动态图表
    install_python_package "plotly"
    
    echo "所有机器学习包安装完成！"
    echo ""
    echo "已安装的包概览："
    echo "  数值计算：NumPy, SciPy"
    echo "  数据处理：Pandas"
    echo "  可视化：Matplotlib, Seaborn, Plotly"
    echo "  机器学习：Scikit-learn"
    # echo "  深度学习：PyTorch (CPU 版本)"
    echo "  网络工具：Requests"
    echo ""
    echo "现在可以开始您的数据科学和机器学习项目了！"
    
else
    echo "(*) 错误：需要先安装 Python 和 pip。"
    echo "请确保 Python 功能特性已正确安装并配置。"
    exit 1
fi

echo "机器学习包功能特性安装完成！"