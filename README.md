# setup-env

模块化环境安装工具。一个固定路由 + 一组独立的环境脚本，按需组合。

## 快速开始

```bash
# 列出所有环境
./main.sh

# 安装
./main.sh docker install     # Docker Engine
./main.sh k3s install        # k3s (lightweight Kubernetes)
./main.sh uv install         # uv (Python 包管理器)
./main.sh npm install        # Node.js + npm
./main.sh npm-claude install # Claude Code CLI
./main.sh npm-codex install  # Claude Codex
./main.sh openclaw install   # openclaw

# 配置镜像
./main.sh apt mirror         # apt 源镜像
./main.sh docker mirror      # Docker 镜像加速
./main.sh k3s mirror         # k3s containerd 镜像
./main.sh kubeadm mirror     # kubeadm containerd 镜像（hosts.toml）
./main.sh uv mirror          # PyPI 镜像
./main.sh npm mirror         # npm registry 镜像
```

## 项目结构

```
setup-env/
├── main.sh                  # 固定路由（不随新增环境膨胀）
├── lib/common.sh            # 共享工具库
├── env/
│   ├── apt/                 # apt 源管理
│   │   ├── main.sh          #   入口
│   │   ├── mirror.sh        #   配置 apt 镜像
│   │   └── mirror.conf      #   镜像 URL 配置
│   ├── docker/              # Docker
│   │   ├── main.sh          #   入口
│   │   ├── install.sh       #   下载官方脚本 → 去静默 → 安装
│   │   ├── mirror.sh        #   配置 daemon.json 镜像加速
│   │   ├── daemon.json      #   registry-mirrors 配置
│   │   └── mirror.conf      #   （可选）镜像配置
│   ├── k3s/                 # k3s Kubernetes
│   │   ├── main.sh
│   │   ├── install.sh
│   │   ├── mirror.sh
│   │   └── registries.yaml  #   containerd 镜像配置
│   ├── kubeadm/             # kubeadm Kubernetes（containerd）
│   │   ├── main.sh
│   │   ├── mirror.sh        #   写入 /etc/containerd/certs.d/<reg>/hosts.toml
│   │   └── certs.d/         #   按 registry 分目录的 hosts.toml
│   │       ├── docker.io/
│   │       ├── registry-1.docker.io/
│   │       ├── ghcr.io/
│   │       ├── gcr.io/
│   │       ├── quay.io/
│   │       └── registry.k8s.io/
│   ├── uv/                  # uv Python 包管理器
│   │   ├── main.sh
│   │   ├── install.sh
│   │   ├── mirror.sh
│   │   └── mirror.conf
│   ├── npm/                 # Node.js + npm
│   │   ├── main.sh
│   │   ├── install.sh
│   │   ├── mirror.sh
│   │   └── mirror.conf
│   ├── npm-claude/          # @anthropic-ai/claude-code
│   │   ├── main.sh
│   │   └── install.sh
│   ├── npm-codex/           # @anthropic-ai/codex
│   │   ├── main.sh
│   │   └── install.sh
│   └── openclaw/            # openclaw
│       ├── main.sh
│       └── install.sh
└── README.md
```

## 设计原则

### main.sh 是固定路由

无论增加多少环境，`main.sh` 都不需要修改。它只做两件事：
1. 无参数 → 列出所有 `env/*/` 和环境内可用命令
2. 有参数 → 分发到 `env/<name>/main.sh <command>`

### 每个环境自包含

`env/<name>/` 目录有独立的 `main.sh`、`.gitignore`、配置文件。新增环境只需新建一个目录，不影响已有环境。

### 镜像配置走文件

镜像 URL 统一放在配置文件里（如 `mirror.conf`、`daemon.json`、`registries.yaml`），改镜像不需要改脚本。执行时命令行参数可以临时覆盖。

### 备份再覆盖 (bac_cp)

所有系统配置文件的写入都先备份（`file → file.bac.N`），来自 `lib/common.sh`。

### 安装可见可确认

- Docker 官方脚本只 patch `-qq` 和 `>/dev/null`（保留 `-y`，官方脚本可信）
- npm 等通过 apt 安装不加 `-y` 和 `DEBIAN_FRONTEND=noninteractive`，用户正常确认

## 添加新环境

```bash
mkdir -p env/<name>
```

最少需要两个文件：

**env/\<name\>/main.sh**（入口）：
```bash
#!/bin/bash
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
COMMAND="${1:-install}"
[ "$COMMAND" = "-h" ] && { echo "Usage: ..."; exit 0; }
shift
exec bash "$ENV_DIR/$COMMAND.sh" "$@"
```

**env/\<name\>/\<command\>.sh**（具体脚本），可选加 `.gitignore` 和配置文件。

不需要改 `main.sh`，新增的 `env/<name>/` 会自动出现在列表里。
