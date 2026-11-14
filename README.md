[English](README_EN.md) | 简体中文

# setup-env

模块化 Linux 环境安装与镜像配置工具。一个固定路由 + 一组自包含的环境脚本，按需组合。

## 快速开始

```bash
# 列出所有环境（共 11 个）
./main.sh

# 安装
./main.sh docker install     # Docker Engine
./main.sh k3s install        # k3s (lightweight Kubernetes)
./main.sh new-api install    # New API LLM 网关容器（默认绑定 127.0.0.1:3000）
./main.sh uv install         # uv (Python 包管理器)
./main.sh npm install        # Node.js + npm
./main.sh npm-claude install # Claude Code CLI (@anthropic-ai/claude-code)
./main.sh npm-codex install  # OpenAI Codex CLI (@openai/codex)
./main.sh openclaw install   # openclaw
./main.sh pre-commit install # pre-commit Git Hook 框架（uv tool / pipx / apt / pip）

# 配置镜像
./main.sh apt mirror         # apt 源镜像（自动区分 amd64/arm64 与 Ubuntu 24.04 DEB822）
./main.sh docker mirror      # Docker 镜像加速
./main.sh k3s mirror         # k3s containerd 镜像
./main.sh kubeadm mirror     # kubeadm containerd 镜像（hosts.toml）
./main.sh uv mirror          # PyPI 镜像（写入 uv.toml [[index]]）
./main.sh npm mirror         # npm registry 镜像
```

> 提示：`apt` 与 `kubeadm` 仅提供 `mirror` 子命令，直接运行 `./main.sh apt` 或 `./main.sh kubeadm` 会自动路由到 `mirror`。

## 项目结构

```
setup-env/
├── main.sh                  # 固定路由（透传参数，不随新增环境膨胀）
├── lib/common.sh            # 共享工具库
├── tests/
│   └── smoke_test.sh        # 语法、help、路由与核心模块冒烟测试
└── env/
    ├── apt/                 # apt 源管理（支持 DEB822 与 ubuntu-ports）
    │   ├── main.sh
    │   ├── mirror.sh
    │   └── mirror.conf
    ├── docker/              # Docker Engine
    │   ├── main.sh
    │   ├── install.sh       #   下载官方脚本 → 去静默 → 安装
    │   ├── mirror.sh        #   配置 /etc/docker/daemon.json 镜像加速
    │   └── daemon.json      #   registry-mirrors 配置
    ├── k3s/                 # k3s Kubernetes
    │   ├── main.sh
    │   ├── install.sh
    │   ├── mirror.sh
    │   └── registries.yaml  #   containerd 镜像配置
    ├── kubeadm/             # kubeadm Kubernetes（containerd）
    │   ├── main.sh
    │   ├── mirror.sh        #   写入 /etc/containerd/certs.d/<reg>/hosts.toml
    │   └── certs.d/         #   按 registry 分目录的 hosts.toml
    │       ├── docker.io/
    │       ├── registry-1.docker.io/
    │       ├── ghcr.io/
    │       ├── gcr.io/
    │       ├── quay.io/
    │       └── registry.k8s.io/
    ├── new-api/             # New API (calciumion/new-api Docker 部署)
    │   ├── main.sh
    │   └── install.sh       #   支持 SQLite / MySQL (0600 .env) / 自定义绑定地址
    ├── npm/                 # Node.js + npm
    │   ├── main.sh
    │   ├── install.sh       #   支持 APT_MIRROR=https://mirrors.tuna.tsinghua.edu.cn
    │   ├── mirror.sh
    │   └── mirror.conf
    ├── npm-claude/          # @anthropic-ai/claude-code
    │   ├── main.sh
    │   └── install.sh
    ├── npm-codex/           # @openai/codex (OpenAI Codex CLI)
    │   ├── main.sh
    │   └── install.sh
    ├── openclaw/            # openclaw
    │   ├── main.sh
    │   └── install.sh
    ├── pre-commit/          # pre-commit Git Hook 框架
    │   ├── main.sh
    │   └── install.sh
    └── uv/                  # uv Python 包管理器
        ├── main.sh
        ├── install.sh
        ├── mirror.sh
        └── mirror.conf
```

## 设计原则

### main.sh 是固定路由

无论增加多少环境，`main.sh` 都不需要修改。它只做两件事：
1. 无参数 → 列出所有 `env/*/` 和环境内可用命令
2. 有参数 → 将 `<env>` 之后的其余参数直接透传给 `env/<name>/main.sh`，由各环境自行决定默认子命令

### 每个环境自包含

`env/<name>/` 目录有独立的 `main.sh`、`.gitignore`、配置文件。新增环境只需新建一个目录，不影响已有环境。

### 镜像配置走文件

镜像 URL 统一放在配置文件里（如 `mirror.conf`、`daemon.json`、`registries.yaml`、`hosts.toml`），改镜像不需要改脚本。执行时命令行参数可以临时覆盖。

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
[ "$COMMAND" = "-h" ] || [ "$COMMAND" = "--help" ] && { echo "Usage: ..."; exit 0; }
[[ $# -gt 0 ]] && shift
exec bash "$ENV_DIR/$COMMAND.sh" "$@"
```

**env/\<name\>/\<command\>.sh**（具体脚本），可选加 `.gitignore` 和配置文件。

不需要改 `main.sh`，新增的 `env/<name>/` 会自动出现在列表里。

## 测试与验证

```bash
bash tests/smoke_test.sh
```

## License

[MIT](LICENSE)
