# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-11-14

### Added
- Automated smoke test suite (`tests/smoke_test.sh`) verifying `bash -n`, `--help` / `-h` across all entrypoints, router default-command forwarding, `uv.toml` generation, and `new-api` secret handling.
- GitHub Actions CI (`shellcheck` + `tests/smoke_test.sh`), `.github/dependabot.yml`, MIT `LICENSE`, bilingual documentation (`README.md` / `README_EN.md`), and `CHANGELOG.md`.

### Changed
- Updated root `main.sh` to forward remaining arguments directly to `env/<name>/main.sh` without forcing `install`, and updated `env/kubeadm/main.sh` to default to `mirror`.
- Replaced bare `shift` across all 11 `env/*/main.sh` scripts with `[[ $# -gt 0 ]] && shift`.
- Updated `env/apt/mirror.sh` to detect `dpkg --print-architecture` (`ubuntu` vs `ubuntu-ports`) and support Ubuntu 24.04+ DEB822 `/etc/apt/sources.list.d/ubuntu.sources`.
- Updated `env/pre-commit/install.sh` to prefer `uv tool` -> `pipx` -> `apt-get` -> `pip --user --break-system-packages` for PEP 668 compatibility.
- Updated `env/uv/mirror.sh` to write modern `[[index]]` `uv.toml` syntax.
- Hardened `env/new-api/install.sh` to bind `127.0.0.1` by default, mask passwords when logging `SQL_DSN`, and pass secrets via a `0600` `.env` file instead of `-e` CLI flags.
- Hardened `env/{docker,k3s,kubeadm}/mirror.sh` to pass paths via positional parameters to `sudo bash -c` instead of string interpolation.
- Deduplicated `CLAUDE.md` as a symlink to `AGENT.md` and switched `.pre-commit-config.yaml` to HTTPS `pre-commit-hooks`.

### Fixed
- Fixed `env/npm-codex` to install `@openai/codex` (OpenAI Codex CLI) instead of nonexistent `@anthropic-ai/codex`.
- Fixed `env/npm/install.sh` invoking `$ROOT_DIR/env/apt/mirror.sh` when `APT_MIRROR` is set and corrected example URL without trailing `/ubuntu`.
- Updated `README.md` to document all 11 environments (including `new-api` and `pre-commit`) and removed phantom `env/docker/mirror.conf`.
