#!/bin/bash
set -e  # 遇到错误立即退出

# 定义要写入的文本内容,使用变量提高可读性和维护性
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
echo "👋 Welcome to SunshineCloud Codespaces! You are on our default image."
echo "   - It includes runtimes and tools for Python, Node.js, Docker, and more. See the full list here: https://aka.ms/ghcs-default-image"
echo "   - Want to use a custom image instead? Learn more here: https://aka.ms/configure-codespace"
echo ""
echo "🔍 To explore VS Code to its fullest, search using the Command Palette (Cmd/Ctrl + Shift + P or F1)."
echo ""
echo "📝 Edit away, run your app as usual, and we'll automatically make it available for you to access."
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
