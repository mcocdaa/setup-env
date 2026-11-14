#!/bin/bash
# uv env — Python package & project manager
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

show_help() {
    cat <<EOF
Usage: main.sh uv <command> [args...]

Commands:
  install     Install uv (fast Python package and project manager)
              Downloads and runs the official installer from astral.sh.

  mirror      Configure uv PyPI mirror
              Default: https://pypi.tuna.tsinghua.edu.cn/simple
              Usage: main.sh uv mirror [url]

  -h, --help  Show this help message

Examples:
  main.sh uv install
  main.sh uv mirror
  main.sh uv mirror https://mirrors.aliyun.com/pypi/simple/
  main.sh uv mirror -h         (show mirror help)
EOF
}

COMMAND="${1:-install}"

if [ "$COMMAND" = "-h" ] || [ "$COMMAND" = "--help" ]; then
    show_help
    exit 0
fi

[[ $# -gt 0 ]] && shift

case "$COMMAND" in
    install|mirror)
        exec bash "$ENV_DIR/$COMMAND.sh" "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Run 'main.sh uv -h' for usage."
        exit 1
        ;;
esac
