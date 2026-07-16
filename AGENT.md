# setup-env — 模块化环境安装工具

项目用固定路由 `main.sh` 分发到 `env/<name>/main.sh`，每个环境自包含。

## 核心约定

- `main.sh` 是路由，永远不改。新增环境 = 新建 `env/<name>/` 目录，路由自动发现。
- 每个 `env/<name>/main.sh` 接受 `<command>` 作为第一个参数，`shift` 后 `exec bash $COMMAND.sh "$@"`。
- 所有脚本支持 `-h`：根路由、env 入口、子命令脚本各层都有 `show_help()`。
- `lib/common.sh` 提供 `bac_cp`（备份后复制）和 `log_info/warn/error`。
- 镜像配置写在文件里（`mirror.conf` / `daemon.json` / `registries.yaml`），不硬编码在脚本中。CLI 参数可覆盖。
- 每个 `env/<name>/` 有自己的 `.gitignore`，如下载的 `install_docker.sh` 不提交。

## 安装脚本的交互策略

- **Docker**：官方脚本可信，只 patch `-qq` 和 `>/dev/null` 让输出可见，保留 `-y` 和 `DEBIAN_FRONTEND`。
- **apt 系（npm 等）**：不用 `-y` 和 `DEBIAN_FRONTEND=noninteractive`，用户自己确认。
- **curl | sh 系（uv、k3s）**：官方安装器保持原样。

## 文件说明

- `lib/common.sh` — 共享工具库，被各 env 脚本 `source`
- `env/<name>/main.sh` — 入口，解析 command 并分发
- `env/<name>/mirror.conf` — 镜像 URL（apt、uv、npm 用此格式）
- `env/docker/daemon.json` — Docker registry-mirrors 配置
- `env/k3s/registries.yaml` — k3s containerd 镜像配置
