#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${HEALTH_LOG_FILE:-/var/log/health-recovery.log}"
SERVICE=""

usage() {
  echo "Usage: $0 --service app|nginx|node_exporter"
}

while (($#)); do
  case "$1" in
    --service) SERVICE="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
log() {
  printf '%s recover_service level=%s service=%s message=%s\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" "$SERVICE" "$2" | tee -a "$LOG_FILE"
}

if [[ -z "$SERVICE" ]]; then
  usage
  exit 2
fi

recover_app() {
  for attempt in 1 2 3; do
    log INFO "restart_attempt=$attempt action=docker_compose_restart"
    if cd /opt/aws-health-app && docker compose up -d --remove-orphans >/dev/null 2>&1 \
      && curl --fail --silent --max-time 5 http://127.0.0.1/health >/dev/null; then
      log INFO "recovery_succeeded attempt=$attempt"
      return 0
    fi
    sleep "$((attempt * 2))"
  done
  log ERROR "recovery_failed attempts=3"
  return 1
}

recover_service_unit() {
  local unit="$1"
  for attempt in 1 2 3; do
    log INFO "restart_attempt=$attempt action=systemctl_restart"
    if systemctl restart "$unit" && systemctl is-active --quiet "$unit"; then
      log INFO "recovery_succeeded attempt=$attempt"
      return 0
    fi
    sleep "$((attempt * 2))"
  done
  log ERROR "recovery_failed attempts=3"
  return 1
}

case "$SERVICE" in
  app) recover_app ;;
  nginx) recover_service_unit nginx ;;
  node_exporter) recover_service_unit node_exporter ;;
  *) log ERROR "invalid_service"; usage; exit 2 ;;
esac
