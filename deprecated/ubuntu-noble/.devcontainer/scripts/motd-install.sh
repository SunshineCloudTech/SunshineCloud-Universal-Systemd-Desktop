#!/bin/bash
set -e  # 遇到错误立即退出

# 定义要写入的文本内容，使用变量提高可读性和维护性
SUNSHINE_LOGO=$(cat << 'EOF'
███████╗██╗   ██╗███╗   ██╗███████╗██╗  ██╗██╗███╗   ██╗███████╗ ██████╗██╗      ██████╗ ██╗   ██╗██████╗ 
██╔════╝██║   ██║████╗  ██║██╔════╝██║  ██║██║████╗  ██║██╔════╝██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗
███████╗██║   ██║██╔██╗ ██║███████╗███████║██║██╔██╗ ██║█████╗  ██║     ██║     ██║   ██║██║   ██║██║  ██║
╚════██║██║   ██║██║╚██╗██║╚════██║██╔══██║██║██║╚██╗██║██╔══╝  ██║     ██║     ██║   ██║██║   ██║██║  ██║
███████║╚██████╔╝██║ ╚████║███████║██║  ██║██║██║ ╚████║███████╗╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝
╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝ ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝ 
EOF
)

# 创建 /etc/motd 文件
echo "$SUNSHINE_LOGO" > /etc/motd
echo "" >> /etc/motd

# 创建欢迎信息脚本
WELCOME_SCRIPT=$(cat << 'EOF'
#!/bin/sh
echo "👋 Welcome to SunshineCloud Universal Systemd Desktop!"
echo ""
echo "📦 Installed Development Environments:"
echo "   • Node.js (LTS) with NVM, Yarn, PNPM"
echo "   • Python 3.10+ via Micromamba (Conda alternative)"
echo "   • Java (Latest) with Gradle & Maven"
echo "   • Go (Latest) with golangci-lint"
echo "   • Rust (Complete) with rust-analyzer, rustfmt, clippy"
echo "   • PowerShell (Latest)"
echo ""
echo "🛠️ Development Tools:"
echo "   • Docker-in-Docker with Buildx & Compose v2"
echo "   • Git + Git LFS + GitHub CLI"
echo "   • KDE Plasma Desktop with XRDP (Port 3389)"
echo "   • Fcitx5 Chinese Input Method"
echo "   • Visual Studio Code"
echo ""
echo "🤖 AI & Machine Learning:"
echo "   • Ollama AI Models (Port 11434)"
echo "   • JupyterLab (Port 8888) - Available when installed"
echo ""
echo "🌐 Network Services:"
echo "   • XRDP Remote Desktop: Port 3389"
echo "   • SSH Server: Port 2222"
echo "   • JupyterLab: Port 8888"
echo "   • Ollama API: Port 11434"
echo ""
echo "📚 Documentation: https://github.com/SunshineCloudTech/SunshineCloud-Universal-Systemd-Desktop"
echo ""
EOF
)

# 创建 /etc/update-motd.d 目录（如果不存在）
mkdir -p /etc/update-motd.d

# 创建 /etc/update-motd.d/10-uname 文件
echo "$WELCOME_SCRIPT" > /etc/update-motd.d/10-uname
chmod +x /etc/update-motd.d/10-uname

# 配置 bash.bashrc 以显示 motd
BASH_CONFIG=$(cat << 'EOF'
if [ -t 1 ]; then
  if command -v run-parts >/dev/null 2>&1 && [ -d /etc/update-motd.d ]; then
    run-parts /etc/update-motd.d > /tmp/_motd
    cat /etc/motd
    cat /tmp/_motd
    rm -f /tmp/_motd
  else
    cat /etc/motd
  fi
fi
EOF
)

# 检查是否已经配置过，避免重复添加
if ! grep -q "cat /etc/motd" /etc/bash.bashrc 2>/dev/null; then
    echo "$BASH_CONFIG" >> /etc/bash.bashrc
fi

# 验证文件是否创建成功
echo "✅ 配置完成！"
echo "   - /etc/motd 已创建"
echo "   - /etc/update-motd.d/10-uname 已创建并设置可执行权限"
echo "   - /etc/bash.bashrc 已更新"
