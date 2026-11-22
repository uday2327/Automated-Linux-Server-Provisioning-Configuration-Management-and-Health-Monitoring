#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0
skipped=0

pass() { printf 'PASS: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1"; failures=$((failures + 1)); }
skip() { printf 'SKIPPED: %s\n' "$1"; skipped=$((skipped + 1)); }
run() {
  local label="$1"
  shift
  if "$@"; then pass "$label"; else fail "$label"; fi
}

cd "$ROOT" || exit 1

for tool in terraform ansible-playbook ansible-inventory node npm python3; do
  if command -v "$tool" >/dev/null 2>&1; then pass "tool available: $tool"
  else fail "tool missing: $tool"
  fi
done

if command -v terraform >/dev/null 2>&1; then
  run "Terraform format" terraform fmt -check -recursive
  temp_terraform="$(mktemp -d)"
  cp terraform/*.tf terraform/.terraform.lock.hcl "$temp_terraform/"
  if (cd "$temp_terraform" && AWS_EC2_METADATA_DISABLED=true terraform init -backend=false -input=false >/dev/null); then
    pass "Terraform backend-free initialization"
  else
    fail "Terraform backend-free initialization"
  fi
  rm -rf "$temp_terraform"
  run "Terraform validation" bash -c 'cd "$1" && AWS_EC2_METADATA_DISABLED=true terraform validate' _ "$ROOT/terraform"
else
  skip "Terraform formatting"
  skip "Terraform initialization"
  skip "Terraform validation"
fi

if command -v ansible-playbook >/dev/null 2>&1; then
  export ANSIBLE_CONFIG="$ROOT/ansible/ansible.cfg"
  run "Ansible example inventory" ansible-inventory -i ansible/inventory/hosts.ini.example --list
  while IFS= read -r playbook; do
    run "Ansible syntax: $playbook" ansible-playbook -i ansible/inventory/hosts.ini.example "$playbook" --syntax-check
  done < <(find ansible/playbooks -maxdepth 1 -name '*.yml' -print | sort)
else
  skip "Ansible inventory and syntax checks"
fi

if command -v ansible-lint >/dev/null 2>&1; then
  run "Ansible lint" ansible-lint ansible
elif [[ -x "$ROOT/.venv/bin/ansible-lint" ]]; then
  run "Ansible lint" bash -c 'cd "$1" && export ANSIBLE_CONFIG="$1/ansible.cfg" && "$2" .' _ "$ROOT/ansible" "$ROOT/.venv/bin/ansible-lint"
else
  skip "Ansible lint (ansible-lint not installed)"
fi

if command -v npm >/dev/null 2>&1; then
  run "npm dependency installation" bash -c 'cd "$1" && npm ci --ignore-scripts --no-audit --no-fund' _ "$ROOT/app"
  run "Application tests" bash -c 'cd "$1" && npm test' _ "$ROOT/app"
  run "Application JavaScript syntax" node --check "$ROOT/app/server.js"
else
  skip "npm dependency installation"
  skip "Application tests"
  skip "Application JavaScript syntax"
fi

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    run "Docker Compose validation" docker compose -f docker/docker-compose.yml config --quiet
    run "Docker image build" docker build --file docker/Dockerfile --tag aws-health-app:test .
  else
    skip "Docker daemon unavailable"
  fi
else
  skip "Docker unavailable"
fi

while IFS= read -r script; do
  run "Shell syntax: $script" bash -n "$script"
done < <(find scripts -maxdepth 1 -name '*.sh' -print | sort)

python3 - <<'PY'
import pathlib
import yaml

failed = False
for path in sorted(pathlib.Path(".").rglob("*")):
    if path.is_file() and path.suffix in {".yml", ".yaml"} and ".git" not in path.parts:
        try:
            list(yaml.safe_load_all(path.read_text(encoding="utf-8")))
        except Exception as exc:
            print(f"FAIL: YAML: {path}: {exc}")
            failed = True
if not failed:
    print("PASS: YAML parsing")
PY
status=$?
if (( status != 0 )); then failures=$((failures + 1)); fi

for path in terraform/tfplan terraform/*.tfplan terraform/*.tfstate terraform/*.tfvars ansible/inventory/hosts.ini ansible/group_vars/all.yml ansible/inventory/group_vars/all.yml; do
  if [[ -f "$path" ]] && git check-ignore -q "$path"; then pass "ignored local artifact: $path"
  elif [[ -f "$path" ]]; then fail "tracked or nonignored artifact: $path"
  fi
done

printf '\nSummary: failures=%d skipped=%d\n' "$failures" "$skipped"
if (( failures > 0 || failures == 0 && skipped > 0 )); then
  exit "$(( failures > 0 ? 1 : 2 ))"
fi
