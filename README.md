# SunshineCloud-Universal-Systemd-Desktop

基于 buildpack-deps 的 systemd 容器镜像集合，支持多种 Linux 发行版和桌面环境。

## 支持的版本

### Debian 系列

- Debian 12 Bookworm
- Debian 11 Bullseye

### Ubuntu LTS 系列

- Ubuntu 24.04 Noble Numbat
- Ubuntu 22.04 Jammy Jellyfish
- Ubuntu 20.04 Focal Fossa

## 镜像类型

本仓库提供两种类型的镜像：

### 1. DevContainer 基础镜像

适用于 VS Code DevContainer 开发环境，包含完整的开发工具链。

**包含组件：**

- systemd 完整支持
- Node.js (LTS) + NVM + PNPM
- Git + Git LFS + GitHub CLI
- Docker-in-Docker
- PowerShell
- Go 语言
- Rust 语言
- Java (Microsoft Build of OpenJDK) + Gradle + Maven
- Micromamba (Python 环境管理)
- SSH 服务器
- Ansible
- Ollama 大语言模型运行环境

**预配置用户：**

- root (密码: 123456789)
- Administrator (密码: 123456789, sudo 权限)
- matrix0523 (密码: 123456789, sudo 权限, NOPASSWD)
- sunshinecloud (UID/GID: 1329)
- ollama (系统用户)

### 2. 桌面环境镜像

提供完整的图形桌面环境，通过 xRDP 访问。

**可用桌面：**

- [Deafult]  KDE Plasma (kde)
- Xfce (xfce)
- GNOME (gnome)

**桌面功能：**

- xRDP 远程桌面 (端口 3389)
- 中文语言支持
- Firefox 浏览器 (中文版)
- Flatpak 支持
- 常用桌面应用

## 构建方法

### 构建 DevContainer 基础镜像

```bash
# Debian 12 Bookworm
docker build -t debian-bookworm-systemd -f debian-bookworm/.devcontainer/Dockerfile .

# Ubuntu 24.04 Noble
docker build -t ubuntu-noble-systemd -f ubuntu-noble/.devcontainer/Dockerfile .
```

### 构建桌面环境镜像

使用 build.sh 脚本批量构建：

```bash
# 进入某个发行版目录
cd debian-bookworm

# 构建单个桌面
DIST=$(basename "$PWD")
CODENAME=${DIST##*-}
DESKTOP=kde  # 或 xfce / gnome
docker build -t "${DIST}-${DESKTOP}" -f "Dockerfile.${CODENAME}-${DESKTOP}" .

# 构建所有桌面
for DESKTOP in kde xfce gnome; do
    docker build -t "${DIST}-${DESKTOP}" -f "Dockerfile.${CODENAME}-${DESKTOP}" .
done
```

可用的桌面 Dockerfile：

**Debian Bookworm:**

- `debian-bookworm/Dockerfile.bookworm-kde`
- `debian-bookworm/Dockerfile.bookworm-xfce`
- `debian-bookworm/Dockerfile.bookworm-gnome`

**Debian Bullseye:**

- `debian-bullseye/Dockerfile.bullseye-kde`
- `debian-bullseye/Dockerfile.bullseye-xfce`
- `debian-bullseye/Dockerfile.bullseye-gnome`

**Ubuntu Noble:**

- `ubuntu-noble/Dockerfile.noble-kde`
- `ubuntu-noble/Dockerfile.noble-xfce`
- `ubuntu-noble/Dockerfile.noble-gnome`

**Ubuntu Jammy:**

- `ubuntu-jammy/Dockerfile.jammy-kde`
- `ubuntu-jammy/Dockerfile.jammy-xfce`
- `ubuntu-jammy/Dockerfile.jammy-gnome`

**Ubuntu Focal:**

- `ubuntu-focal/Dockerfile.focal-kde`
- `ubuntu-focal/Dockerfile.focal-xfce`
- `ubuntu-focal/Dockerfile.focal-gnome`

## 使用 Docker Hub 镜像

### 拉取镜像

```bash
# AMD64 基础镜像
docker pull sunshinecloud007/sunshinecloud-universal-systemd-desktop:amd64-bookworm
docker pull sunshinecloud007/sunshinecloud-universal-systemd-desktop:amd64-noble

# ARM64 基础镜像
docker pull sunshinecloud007/sunshinecloud-universal-systemd-desktop:arm64-bookworm
docker pull sunshinecloud007/sunshinecloud-universal-systemd-desktop:arm64-noble
```

### 可用镜像标签

**AMD64 架构：**

- `amd64-bookworm` (Debian 12)
- `amd64-bullseye` (Debian 11)
- `amd64-noble` (Ubuntu 24.04)
- `amd64-jammy` (Ubuntu 22.04)
- `amd64-focal` (Ubuntu 20.04)

**ARM64 架构：**

- `arm64-bookworm` (Debian 12)
- `arm64-bullseye` (Debian 11)
- `arm64-noble` (Ubuntu 24.04)
- `arm64-jammy` (Ubuntu 22.04)
- `arm64-focal` (Ubuntu 20.04)

**构建中间镜像（带 -base 后缀）：**

- `amd64-{codename}-base` - AMD64 未压缩基础镜像
- `arm64-{codename}-base` - ARM64 未压缩基础镜像

## 运行容器

### 运行 DevContainer 基础镜像

```bash
docker run --detach --privileged \
  --volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  --name debian-bookworm-container \
  sunshinecloud007/sunshinecloud-universal-systemd-desktop:amd64-bookworm
```

### 运行桌面环境镜像

```bash
# 运行 KDE 桌面
docker run -d --privileged \
  --name debian-bookworm-kde \
  -p 3389:3389 \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  debian-bookworm-kde

# 使用 RDP 客户端连接
# 地址: localhost:3389
# 用户名: matrix0523
# 密码: 123456789
```

### 进入容器

```bash
docker exec -it debian-bookworm-container /bin/bash
```

## 常用操作

### 使用 Ansible

```bash
docker exec -it debian-bookworm-container ansible --version
docker exec -it debian-bookworm-container ansible-playbook /path/to/playbook.yml
```

### 使用 Ollama

```bash
docker exec -it debian-bookworm-container ollama run llama2
```

### 使用 xRDP 桌面

1. 启动桌面容器并映射 3389 端口
2. 使用 RDP 客户端连接到 localhost:3389
3. 输入用户名和密码登录

**Windows:** 使用内置的"远程桌面连接"
**macOS:** 使用 Microsoft Remote Desktop
**Linux:** 使用 Remmina 或 xfreerdp

## Docker Compose 部署

### 单个容器

```bash
# Debian 12 Bookworm
docker compose -f docker-compose.debian-bookworm.yml up -d

# Ubuntu 24.04 Noble
docker compose -f docker-compose.ubuntu-noble.yml up -d
```

### 多容器部署

同时运行所有版本进行测试：

```bash
docker compose -f docker-compose.multi.yml up -d
```

SSH 端口映射：

- Debian 12 Bookworm: 2201
- Debian 11 Bullseye: 2202
- Ubuntu 24.04 Noble: 2203
- Ubuntu 22.04 Jammy: 2204
- Ubuntu 20.04 Focal: 2205

### 常用命令

```bash
# 查看容器状态
docker compose -f docker-compose.debian-bookworm.yml ps

# 查看日志
docker compose -f docker-compose.debian-bookworm.yml logs -f

# 停止并删除
docker compose -f docker-compose.debian-bookworm.yml down
```

## 自动化构建

### GitHub Actions 工作流

本仓库使用 GitHub Actions 自动构建和发布镜像。

**触发条件：**

- 每周一定时构建
- 推送到 master 分支
- 手动触发

**构建流程：**

1. **独立架构构建**

   - AMD64: 使用 `ubuntu-latest` runner
   - ARM64: 使用 `ubuntu-24.04-arm` runner
   - 构建并推送 `{arch}-{codename}-base` 镜像
2. **镜像压缩**

   - 使用 docker export/import 压缩镜像
   - 减小镜像体积
   - 推送最终镜像 `{arch}-{codename}`
3. **多架构清单**

   - 创建 multi-arch manifest
   - 合并 AMD64 和 ARM64 镜像

**工作流文件：**

- `Build-{Distro}-AMD64.yml` - AMD64 构建
- `Build-{Distro}-ARM64.yml` - ARM64 构建
- `Compress-{Distro}.yml` - AMD64 压缩
- `Compress-{Distro}-ARM64.yml` - ARM64 压缩
- `Manifest-{Distro}.yml` - 多架构清单

## DevContainer 配置

每个发行版都包含 `.devcontainer/devcontainer.json` 配置文件。

**容器名称：**

- `Debian-Bookworm-Systemd-Devcontainer`
- `Debian-Bullseye-Systemd-Devcontainer`
- `Ubuntu-Noble-Systemd-Devcontainer`
- `Ubuntu-Jammy-Systemd-Devcontainer`
- `Ubuntu-Focal-Systemd-Devcontainer`

**启用的功能：**

- common-utils (Zsh, Oh My Zsh)
- node (NVM, PNPM, Yarn)
- git, git-lfs, github-cli
- docker-in-docker
- powershell
- go, rust, java
- nvs (Node Version Switcher)
- micromamba (Python 环境)

**已禁用的功能：**

- python (使用 micromamba 替代)
- conda (使用 micromamba 替代)
- nvidia-cuda
- machine-learning-packages
- setup-user
- patch-python, patch-conda

## 目录结构

```
.
├── debian-bookworm/
│   ├── .devcontainer/
│   │   ├── Dockerfile           # DevContainer 基础镜像
│   │   └── devcontainer.json    # VS Code 配置
│   ├── Dockerfile.bookworm-kde  # KDE 桌面
│   ├── Dockerfile.bookworm-xfce # Xfce 桌面
│   └── Dockerfile.bookworm-gnome # GNOME 桌面
├── debian-bullseye/
├── ubuntu-noble/
├── ubuntu-jammy/
├── ubuntu-focal/
├── .github/workflows/           # GitHub Actions 工作流
├── docker-compose.*.yml         # Docker Compose 配置
└── build.sh                     # 构建脚本
```

## 注意事项

### 安全警告

本镜像包含预配置的用户和密码，**仅用于测试和开发环境**。

生产环境使用前请务必：

1. 修改所有用户密码
2. 删除不需要的用户
3. 配置适当的安全策略
4. 使用防火墙限制访问
5. 禁用不需要的服务

### systemd 要求

运行 systemd 容器需要：

- `--privileged` 特权模式
- 挂载 `/sys/fs/cgroup`
- 设置 `--cgroupns=host`

### 桌面环境注意事项

- xRDP 默认端口 3389
- 首次登录可能需要配置语言和键盘
- Firefox 已预装中文语言包
- Flatpak 应用需要手动安装

## 许可证

本项目基于 MIT 许可证开源。

## 维护者

SunshineCloudTech
