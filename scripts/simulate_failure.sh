#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  app)
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) stopping app container"
    docker stop aws-health-app
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) app stopped; reversible with: docker start aws-health-app"
    ;;
  nginx)
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) stopping nginx"
    sudo systemctl stop nginx
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) nginx stopped; reversible with: sudo systemctl start nginx"
    ;;
  *)
    echo "Usage: $0 app|nginx" >&2
    exit 2
    ;;
esac
