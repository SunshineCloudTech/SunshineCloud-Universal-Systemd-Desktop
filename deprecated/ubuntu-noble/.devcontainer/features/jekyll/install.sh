#!/usr/bin/env bash
#===================================================================================
# Jekyll 静态站点生成器安装脚本
#
# 功能：在开发容器中安装 Jekyll 静态站点生成器
# 用途：
#   - 为 GitHub Pages 项目提供本地开发环境
#   - 支持 Markdown 博客和文档站点的快速构建
#   - 提供主题开发和自定义功能
#
# 前置依赖：
#   - Ruby 环境（通过 RVM 管理）
#   - gem 包管理器
#
# 参数：
#   $1: Jekyll 版本号（默认：latest）
#   $2: 用户名（默认：matrix0523）
#
# 使用场景：
#   - 静态博客开发（GitHub Pages、GitLab Pages）
#   - 技术文档站点构建
#   - 公司官网和产品页面开发
#   - Markdown 内容管理系统
#
# 维护者：SunshineCloud 团队
# 创建时间：2024
# 最后更新：基于 Microsoft DevContainer Features 模板
#===================================================================================
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# 解析命令行参数，设置默认值
VERSION=${1:-"latest"}     # Jekyll 版本，默认为最新版
USERNAME=${2:-"matrix0523"} # 系统用户名，用于权限设置

# 启用严格错误处理，任何命令失败时立即退出
set -e

echo "正在检查 Jekyll 安装脚本的前置条件..."

# 验证 Ruby 环境是否已安装
# RVM（Ruby Version Manager）是 Ruby 版本管理工具
if ! /usr/local/rvm/rubies/default/bin/ruby --version > /dev/null ; then
    echo "错误：未检测到 Ruby 环境。Jekyll 需要 Ruby 运行时支持。"
    echo "请先安装 Ruby 功能特性或确保 RVM 正确配置。"
    exit 1
fi

echo "Ruby 环境检查通过，开始安装 Jekyll..."

# 检查 Jekyll 是否已经安装，避免重复安装
if ! jekyll --version > /dev/null ; then
    echo "正在安装 Jekyll 静态站点生成器..."
    
    # 设置 gem 二进制文件路径
    # RVM 将 Ruby 和 gem 安装在特定目录结构中
    GEMS_DIR=/usr/local/rvm/rubies/default/bin
    PATH=$GEMS_DIR/gem:$PATH
    
    # 根据指定版本安装 Jekyll
    if [ "${VERSION}" = "latest" ]; then
        echo "安装最新版本的 Jekyll..."
        gem install jekyll
    else
        echo "安装指定版本的 Jekyll: ${VERSION}"
        gem install jekyll -v "${VERSION}"
    fi

    echo "配置 Jekyll 文件权限和用户组访问..."
    
    # 将 gem 目录的所有权分配给指定用户和 rvm 组
    # 这确保了用户可以管理已安装的 gems
    chown -R "${USERNAME}:rvm" "${GEMS_DIR}/"
    
    # 设置组读写权限，允许 rvm 组成员管理 gems
    chmod -R g+r+w "${GEMS_DIR}/"
    
    # 为所有目录设置组继承权限（setgid）
    # 确保新创建的文件继承正确的组权限
    find "${GEMS_DIR}" -type d | xargs -n 1 chmod g+s

    echo "配置 RVM gems 扩展目录权限..."
    
    # RVM gems 扩展目录，存储编译的 native extensions
    RVM_GEMS_DIR=/usr/local/rvm/gems/default/extensions
    
    # 确保用户对扩展目录有完整的管理权限
    # 这对于安装包含 C 扩展的 gems 很重要
    chown -R "${USERNAME}:rvm" "${RVM_GEMS_DIR}/"
    chmod -R g+r+w "${RVM_GEMS_DIR}/"
    find "${RVM_GEMS_DIR}" -type d | xargs -n 1 chmod g+s
    
    echo "Jekyll 安装完成！"
    echo "现在可以使用以下命令："
    echo "  jekyll new my-site     # 创建新的 Jekyll 站点"
    echo "  jekyll serve           # 启动开发服务器"
    echo "  jekyll build           # 构建静态站点"
else
    echo "Jekyll 已安装，跳过安装步骤。"
    jekyll --version
fi

echo "Jekyll 功能特性配置完成！"
