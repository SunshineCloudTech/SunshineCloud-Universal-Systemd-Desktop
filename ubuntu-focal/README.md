# Ubuntu Focal (20.04 LTS) Systemd Container

## 概述

这是基于 Ubuntu 20.04 LTS (Focal Fossa) 的 systemd 容器开发环境。提供完整的多语言开发工具链和 systemd 初始化系统支持。

## 基础镜像

- 基础: `buildpack-deps:focal`
- 架构: linux/amd64, linux/arm64

## 主要功能

### 系统特性

- 完整的 systemd 初始化系统
- Docker-in-Docker 支持
- SSH 服务器
- Ansible 自动化工具

### 开发语言支持

- **Python 3.10**: 包含 pip, pipx, poetry, uv, JupyterLab
- **Node.js LTS**: 包含 npm, yarn, pnpm
- **Java (latest)**: 通过 SDKMAN! 管理，包含 Gradle, Maven
- **Go (latest)**: 包含 golangci-lint
- **Rust (latest)**: 包含 rust-analyzer, clippy, rustfmt
- **PowerShell (latest)**: 跨平台脚本支持

### 包管理器

- Homebrew: 安装在 `/SunshineCloud/Homebrew`
- Micromamba: Conda 替代品，轻量级包管理

### 容器化工具

- Docker-in-Docker (Moby)
- Docker Buildx
- Docker Compose v2
- Kubernetes CLI 工具

## 目录结构

```
/app                    - 应用程序目录
/SunshineCloud          - SunshineCloud 数据目录
/DATA                   - 通用数据目录
/media                  - 媒体文件目录
/var/run/dbus           - D-Bus 通信目录
/home/Administrator     - 管理员用户主目录
/home/matrix0523        - matrix0523 用户主目录
```

## 用户配置

### 预配置用户

- **root**: 密码 `123456789`
- **Administrator**: 密码 `123456789`, sudo 权限
- **matrix0523**: 密码 `123456789`, sudo 权限（无密码）

## 使用方法

### 使用 Docker Compose

```bash
# 使用预配置的 compose 文件
docker compose -f docker-compose.ubuntu-focal.yml up -d

# 进入容器
docker compose -f docker-compose.ubuntu-focal.yml exec ubuntu-focal bash
```

### 直接运行

```bash
# 拉取镜像（多架构，自动选择对应架构）
docker pull sunshinecloud007/sunshinecloud-universal-systemd-desktop:ubuntu-focal

# 运行容器
docker run -d --name ubuntu-focal \
  --privileged \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  sunshinecloud007/sunshinecloud-universal-systemd-desktop:ubuntu-focal
```

### 作为 Dev Container 使用

在 VS Code 中打开此目录，选择 "Reopen in Container" 即可使用完整的开发环境。

## 镜像标签

- `ubuntu-focal-base`: 构建镜像（未压缩）
- `ubuntu-focal`: 生产镜像（压缩优化）
- `ubuntu-focal-latest`: 最新版本别名

## 版本特性

Ubuntu 20.04 LTS (Focal Fossa) 是成熟的长期支持版本：

- LTS 支持至 2025 年（标准支持）
- 扩展安全维护至 2030 年
- 最稳定的 Ubuntu LTS 版本之一
- 适合需要最大兼容性的场景
- 广泛的企业级应用支持

## 注意事项

1. 容器必须以 `--privileged` 模式运行才能使用 systemd
2. 需要挂载 `/sys/fs/cgroup` 以支持 cgroup v2
3. 建议使用 `--cgroupns=host` 以获得最佳兼容性
4. 首次启动可能需要较长时间来初始化 systemd
5. 作为较旧的 LTS 版本，部分最新特性可能不可用

## 更新日志

- 2024年版本: 添加 Java, Rust, PowerShell 支持
- 添加 Homebrew 包管理器
- 集成 Micromamba 替代 Conda
- 移除 Ollama（可按需手动安装）

## 相关链接

- Docker Hub: https://hub.docker.com/r/sunshinecloud007/sunshinecloud-universal-systemd-desktop
- GitHub: https://github.com/SunshineCloudTech/SunshineCloud-Universal-Systemd-Desktop
- Ubuntu Focal 发布说明: https://releases.ubuntu.com/20.04/
