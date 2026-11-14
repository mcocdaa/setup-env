#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1" >&2
    FAIL=$((FAIL + 1))
}

TMP_DIR="$(mktemp -d)"
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# 1. 语法检查所有 .sh 文件
syntax_ok=true
while IFS= read -r -d '' script; do
    if ! bash -n "$script"; then
        fail "syntax error in $script"
        syntax_ok=false
    fi
done < <(find "$REPO_ROOT" -name '*.sh' -not -path '*/.git/*' -print0)
if $syntax_ok; then
    pass "bash -n passed for all shell scripts"
fi

# 2. 根路由零参数列出全部 11 个环境 + 根帮助
root_list="$(bash "$REPO_ROOT/main.sh")"
root_help="$(bash "$REPO_ROOT/main.sh" --help)"
all_envs=(apt docker k3s kubeadm new-api npm npm-claude npm-codex openclaw pre-commit uv)
list_ok=true
for e in "${all_envs[@]}"; do
    if ! printf '%s\n' "$root_list" | grep -Eq "^[[:space:]]+${e}[[:space:]]"; then
        fail "root main.sh output missing env: $e"
        list_ok=false
    fi
done
if $list_ok && [[ "$root_help" == *"Usage:"* ]]; then
    pass "root main.sh lists all 11 environments and supports --help"
fi

# 3. 逐一检查 11 个 env/*/main.sh 及子命令脚本的 -h / --help
help_ok=true
for e in "${all_envs[@]}"; do
    if ! bash "$REPO_ROOT/main.sh" "$e" --help >/dev/null; then
        fail "main.sh $e --help failed"
        help_ok=false
    fi
    if ! bash "$REPO_ROOT/env/$e/main.sh" -h >/dev/null; then
        fail "env/$e/main.sh -h failed"
        help_ok=false
    fi
    for sub in "$REPO_ROOT/env/$e"/*.sh; do
        [ -f "$sub" ] || continue
        base="$(basename "$sub")"
        [ "$base" = "main.sh" ] && continue
        if ! bash "$sub" --help >/dev/null; then
            fail "$sub --help failed"
            help_ok=false
        fi
    done
done
if $help_ok; then
    pass "all 11 envs and subcommands support -h/--help via router and direct invocation"
fi

# 4. 在临时副本中验证路由默认命令转发（apt/kubeadm -> mirror，docker -> install，透传参数）
TMP_REPO="$TMP_DIR/repo"
mkdir -p "$TMP_REPO"
cp "$REPO_ROOT/main.sh" "$TMP_REPO/"
cp -r "$REPO_ROOT/lib" "$REPO_ROOT/env" "$TMP_REPO/"

cat > "$TMP_REPO/env/apt/mirror.sh" <<'EOF'
#!/bin/bash
echo "CALLED:apt/mirror:$*"
EOF
cat > "$TMP_REPO/env/kubeadm/mirror.sh" <<'EOF'
#!/bin/bash
echo "CALLED:kubeadm/mirror:$*"
EOF
cat > "$TMP_REPO/env/docker/install.sh" <<'EOF'
#!/bin/bash
echo "CALLED:docker/install:$*"
EOF
cat > "$TMP_REPO/env/uv/mirror.sh" <<'EOF'
#!/bin/bash
echo "CALLED:uv/mirror:$*"
EOF

out_apt="$(bash "$TMP_REPO/main.sh" apt)"
out_kubeadm="$(bash "$TMP_REPO/main.sh" kubeadm)"
out_docker="$(bash "$TMP_REPO/main.sh" docker)"
out_uv="$(bash "$TMP_REPO/main.sh" uv mirror https://example.org/simple)"
if [[ "$out_apt" == "CALLED:apt/mirror:" ]] \
    && [[ "$out_kubeadm" == "CALLED:kubeadm/mirror:" ]] \
    && [[ "$out_docker" == "CALLED:docker/install:" ]] \
    && [[ "$out_uv" == "CALLED:uv/mirror:https://example.org/simple" ]]; then
    pass "router dispatches default commands (apt/kubeadm->mirror, docker->install) and forwards args"
else
    fail "router dispatch unexpected: apt=$out_apt kubeadm=$out_kubeadm docker=$out_docker uv=$out_uv"
fi

# 5. 验证 uv/mirror.sh 生成合法 [[index]] uv.toml 及备份
UV_CFG="$TMP_DIR/uv/uv.toml"
UV_CONFIG_FILE="$UV_CFG" bash "$REPO_ROOT/main.sh" uv mirror "https://example.org/simple" >/dev/null
UV_CONFIG_FILE="$UV_CFG" bash "$REPO_ROOT/main.sh" uv mirror "https://example.org/simple2" >/dev/null
if grep -Fq '[[index]]' "$UV_CFG" \
    && grep -Fq 'url = "https://example.org/simple2"' "$UV_CFG" \
    && grep -Fq 'default = true' "$UV_CFG" \
    && [[ -f "${UV_CFG}.bac.0" ]]; then
    pass "uv mirror writes [[index]] uv.toml and creates .bac.0 backup"
else
    fail "uv mirror config check failed"
fi

# 6. 验证 npm-codex 使用 @openai/codex
if grep -Fq '@openai/codex' "$REPO_ROOT/env/npm-codex/install.sh" \
    && grep -Fq '@openai/codex' "$REPO_ROOT/env/npm-codex/main.sh" \
    && ! grep -Fq '@anthropic-ai/codex' "$REPO_ROOT/env/npm-codex/install.sh"; then
    pass "npm-codex targets @openai/codex"
else
    fail "npm-codex package check failed"
fi

# 7. 验证 new-api 默认绑定 127.0.0.1、DSN 脱敏及 0600 .env 文件（使用 mock docker）
mkdir -p "$TMP_DIR/bin"
DOCKER_LOG="$TMP_DIR/docker.log"
cat > "$TMP_DIR/bin/docker" <<'EOF'
#!/bin/bash
echo "docker $*" >> "$MOCK_DOCKER_LOG"
if [[ "${1:-}" == "ps" ]]; then
    exit 0
fi
exit 0
EOF
chmod +x "$TMP_DIR/bin/docker"

NEW_API_DATA="$TMP_DIR/new-api-data"
new_api_out="$(PATH="$TMP_DIR/bin:$PATH" MOCK_DOCKER_LOG="$DOCKER_LOG" \
    bash "$REPO_ROOT/main.sh" new-api install --mysql --sql-dsn "root:SuperSecret123@tcp(db:3306)/oneapi" -d "$NEW_API_DATA")"
env_mode="$(stat -c '%a' "$NEW_API_DATA/.env" 2>/dev/null || stat -f '%Lp' "$NEW_API_DATA/.env")"

if [[ "$new_api_out" != *"SuperSecret123"* ]] \
    && [[ "$new_api_out" == *"root:***@tcp(db:3306)/oneapi"* ]] \
    && [[ "$env_mode" == "600" ]] \
    && grep -Fq -- "-p 127.0.0.1:3000:3000" "$DOCKER_LOG" \
    && grep -Fq -- "--env-file $NEW_API_DATA/.env" "$DOCKER_LOG" \
    && ! grep -Fq "SuperSecret123" "$DOCKER_LOG"; then
    pass "new-api masks DSN in logs, binds 127.0.0.1 by default, and uses 0600 --env-file"
else
    fail "new-api security check failed (mode=$env_mode, out=$new_api_out, log=$(cat "$DOCKER_LOG"))"
fi

echo ""
echo "Summary: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
