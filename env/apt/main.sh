#!/bin/bash
# apt env — system package manager mirror configuration
set -e
ENV_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

show_help() {
    cat <<EOF
Usage: main.sh apt <command> [args...]

Commands:
  mirror      Configure apt sources mirror
              Backs up /etc/apt/sources.list, then replaces with mirror URLs.
              Default: https://mirrors.tuna.tsinghua.edu.cn

  -h, --help  Show this help message

Examples:
  main.sh apt mirror
  main.sh apt mirror https://mirrors.aliyun.com
  main.sh apt mirror https://mirrors.ustc.edu.cn
EOF
}

COMMAND="${1:-mirror}"

if [ "$COMMAND" = "-h" ] || [ "$COMMAND" = "--help" ]; then
    show_help
    exit 0
fi

shift

case "$COMMAND" in
    mirror)
        exec bash "$ENV_DIR/mirror.sh" "$@"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Run 'main.sh apt -h' for usage."
        exit 1
        ;;
esac
