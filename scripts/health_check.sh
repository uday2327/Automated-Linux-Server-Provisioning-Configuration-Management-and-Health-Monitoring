#!/usr/bin/env bash
set -uo pipefail

LOG_FILE="${HEALTH_LOG_FILE:-/var/log/health-recovery.log}"
APP_HEALTH_URL="${APP_HEALTH_URL:-http://127.0.0.1/health}"
NODE_EXPORTER_URL="${NODE_EXPORTER_URL:-http://127.0.0.1:9100/metrics}"
failures=0

log() {
  printf '%s health_check level=%s message=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" "$2" | tee -a "$LOG_FILE"
}

check_http() {
  local name="$1"
  local url="$2"
  if curl --fail --silent --show-error --max-time 5 "$url" >/dev/null; then
    log INFO "$name reachable"
  else
    log ERROR "$name unreachable url=$url"
    failures=$((failures + 1))
  fi
}

check_service() {
  local name="$1"
  if systemctl is-active --quiet "$name"; then
    log INFO "service=$name active"
  else
    log ERROR "service=$name inactive"
    failures=$((failures + 1))
  fi
}

mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
check_http "application" "$APP_HEALTH_URL"
check_http "node_exporter" "$NODE_EXPORTER_URL"
check_http "nginx_health" "http://127.0.0.1/nginx-health"
check_service nginx
check_service node_exporter

if command -v docker >/dev/null 2>&1; then
  if docker inspect --format '{{.State.Health.Status}}' aws-health-app 2>/dev/null | grep -Eq 'healthy|starting'; then
    log INFO "docker_container=aws-health-app health=ok"
  else
    log ERROR "docker_container=aws-health-app health=unhealthy"
    failures=$((failures + 1))
  fi
fi

disk_usage="$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')"
if [[ "$disk_usage" =~ ^[0-9]+$ ]] && ((disk_usage < 85)); then
  log INFO "disk_usage_percent=$disk_usage"
else
  log ERROR "disk_usage_percent=${disk_usage:-unknown} threshold=85"
  failures=$((failures + 1))
fi

if [[ -n "${MONITORING_HOST:-}" ]]; then
  check_service prometheus
  check_service grafana-server
  check_service nagios
fi

if ((failures == 0)); then
  log INFO "overall_status=healthy"
  exit 0
fi

log ERROR "overall_status=unhealthy failure_count=$failures"
exit 1
