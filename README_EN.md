English | [简体中文](README.md)

# setup-env

Modular Linux environment bootstrapper and mirror configurator. A fixed router (`main.sh`) dispatches to self-contained scripts under `env/<name>/`.

## Quick Start

```bash
# List all 11 environments
./main.sh

# Install environments
./main.sh docker install     # Docker Engine
./main.sh k3s install        # k3s (lightweight Kubernetes)
./main.sh new-api install    # New API LLM gateway container (defaults to 127.0.0.1:3000)
./main.sh uv install         # uv (Python package & project manager)
./main.sh npm install        # Node.js + npm
./main.sh npm-claude install # Claude Code CLI (@anthropic-ai/claude-code)
./main.sh npm-codex install  # OpenAI Codex CLI (@openai/codex)
./main.sh openclaw install   # openclaw
./main.sh pre-commit install # pre-commit hook framework (uv tool / pipx / apt / pip)

# Configure mirrors
./main.sh apt mirror         # apt sources mirror (detects amd64/arm64 and Ubuntu 24.04 DEB822)
./main.sh docker mirror      # Docker registry mirrors (/etc/docker/daemon.json)
./main.sh k3s mirror         # k3s containerd registry mirrors
./main.sh kubeadm mirror     # kubeadm containerd mirrors (hosts.toml)
./main.sh uv mirror          # PyPI index mirror (writes [[index]] in uv.toml)
./main.sh npm mirror         # npm registry mirror
```

> Tip: `apt` and `kubeadm` default to `mirror` when invoked without a subcommand (`./main.sh apt` or `./main.sh kubeadm`).

## Project Structure

```
setup-env/
├── main.sh                  # Fixed environment router
├── lib/common.sh            # Shared helpers (bac_cp, logging)
├── tests/
│   └── smoke_test.sh        # Syntax, help, router, and sandbox smoke tests
└── env/
    ├── apt/                 # apt sources mirror (DEB822 + ubuntu-ports aware)
    ├── docker/              # Docker Engine install & daemon.json mirror
    ├── k3s/                 # k3s install & registries.yaml mirror
    ├── kubeadm/             # containerd certs.d/<registry>/hosts.toml mirrors
    ├── new-api/             # New API Docker deployment (0600 .env, masked DSN)
    ├── npm/                 # Node.js + npm install & registry mirror
    ├── npm-claude/          # @anthropic-ai/claude-code
    ├── npm-codex/           # @openai/codex (OpenAI Codex CLI)
    ├── openclaw/            # openclaw
    ├── pre-commit/          # pre-commit framework installer
    └── uv/                  # uv install & uv.toml [[index]] mirror
```

## Verification

```bash
bash tests/smoke_test.sh
```

## License

[MIT](LICENSE)
