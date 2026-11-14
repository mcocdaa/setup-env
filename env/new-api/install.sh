#!/bin/bash
# New API — docker pull & run
# Default: SQLite mode with calciumion/new-api:latest bound to 127.0.0.1
# Options:
#   -t, --tag     Docker image tag (default: latest)
#   --mysql       Use MySQL instead of SQLite (requires SQL_DSN env var or prompts)
#   -b, --bind    Host IP to bind (default: 127.0.0.1)
#   -p, --port    Host port (default: 3000)
#   -n, --name    Container name (default: new-api)
#   -d, --data    Data directory on host (default: ./new-api-data relative to pwd)
#   -h, --help    Show this help
set -e
# shellcheck source=/dev/null
source "$(dirname "$(realpath "$0")")/../../lib/common.sh"

DOCKER_IMAGE="calciumion/new-api"
TAG="latest"
BIND_HOST="${BIND_HOST:-127.0.0.1}"
PORT="3000"
CONTAINER_NAME="new-api"
DATA_DIR="$(pwd)/new-api-data"
USE_MYSQL=false
SQL_DSN="${SQL_DSN:-}"

show_help() {
    cat <<EOF
Usage: main.sh new-api install [options]

Pull the New API Docker image and start a container.

Default mode: SQLite (data persisted to a host directory), bound to 127.0.0.1.

Options:
  -t, --tag TAG        Image tag (default: latest, e.g. v1.0.0-rc.20)
  --mysql              Enable MySQL mode
  --sql-dsn DSN        MySQL DSN (e.g. "root:pass@tcp(host:3306)/oneapi")
                       If --mysql is set but no DSN, you will be prompted.
  -b, --bind HOST      Host bind address (default: 127.0.0.1, env BIND_HOST)
  -p, --port PORT      Host port to bind (default: 3000)
  -n, --name NAME      Container name (default: new-api)
  -d, --data PATH      Host data directory (default: ./new-api-data)
  -h, --help           Show this help message

Examples:
  main.sh new-api install
  main.sh new-api install -t v1.0.0-rc.20
  main.sh new-api install --mysql --sql-dsn "root:123456@tcp(localhost:3306)/oneapi"
  main.sh new-api install -b 0.0.0.0 -p 8080 -n my-new-api -d /srv/new-api/data

After start, access: http://127.0.0.1:3000
Default login: root / 123456
EOF
}

mask_dsn() {
    printf '%s' "$1" | sed -E 's|^([^:/]+://)?([^:@]+):[^@]*@|\1\2:***@|'
}

while [ $# -gt 0 ]; do
    case "$1" in
        -t|--tag)
            TAG="${2:?Missing value for $1}"; shift 2 ;;
        --mysql)
            USE_MYSQL=true; shift ;;
        --sql-dsn)
            SQL_DSN="${2:?Missing value for $1}"; shift 2 ;;
        -b|--bind)
            BIND_HOST="${2:?Missing value for $1}"; shift 2 ;;
        -p|--port)
            PORT="${2:?Missing value for $1}"; shift 2 ;;
        -n|--name)
            CONTAINER_NAME="${2:?Missing value for $1}"; shift 2 ;;
        -d|--data)
            DATA_DIR="${2:?Missing value for $1}"; shift 2 ;;
        -h|--help)
            show_help; exit 0 ;;
        *)
            echo "Unknown option: $1"
            echo "Run 'main.sh new-api install -h' for usage."
            exit 1 ;;
    esac
done

if $USE_MYSQL; then
    if [ -z "$SQL_DSN" ]; then
        read -r -p "MySQL DSN (e.g. root:pass@tcp(host:3306)/oneapi): " SQL_DSN
    fi
    if [ -z "$SQL_DSN" ]; then
        log_error "MySQL DSN is required for --mysql mode."
        exit 1
    fi
    log_info "MySQL mode: $(mask_dsn "$SQL_DSN")"
else
    log_info "SQLite mode (data at $DATA_DIR)"
fi

FULL_IMAGE="$DOCKER_IMAGE:$TAG"

log_info "Pulling $FULL_IMAGE..."
docker pull "$FULL_IMAGE"

# Stop & remove existing container with the same name (if any)
if docker ps -a --format '{{.Names}}' | grep -Fxq "$CONTAINER_NAME"; then
    log_warn "Container '$CONTAINER_NAME' already exists — stopping & removing..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
fi

# Create data directory and write 0600 .env file (avoid exposing secrets via -e in ps aux)
mkdir -p "$DATA_DIR"
ENV_FILE="$DATA_DIR/.env"
(
    umask 077
    {
        echo "TZ=Asia/Shanghai"
        if $USE_MYSQL; then
            printf 'SQL_DSN=%s\n' "$SQL_DSN"
        fi
    } > "$ENV_FILE"
)
chmod 600 "$ENV_FILE"

DOCKER_ARGS=(
    -d
    --restart always
    --name "$CONTAINER_NAME"
    -p "${BIND_HOST}:${PORT}:3000"
    --env-file "$ENV_FILE"
    -v "$DATA_DIR:/data"
)

log_info "Starting New API container..."
docker run "${DOCKER_ARGS[@]}" "$FULL_IMAGE"

log_info "New API is starting up..."
log_info "  URL:   http://${BIND_HOST}:${PORT}"
log_info "  Login: root / 123456"
log_info ""
log_info "Check logs:  docker logs -f $CONTAINER_NAME"
