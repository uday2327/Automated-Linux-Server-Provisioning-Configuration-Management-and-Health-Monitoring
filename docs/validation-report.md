# Validation report

Date: 2026-11-19. Commands ran from the project root on Windows PowerShell. No software was installed. `PASS` means the stated local check actually completed; it does not mean the project was deployed.

| Command / check | Result | Output / limit |
|---|---|---|
| `git status --short --branch` | PASS | Branch is `main`; reports pre-existing modified and untracked user files plus audit edits. No branch/history operation was performed. |
| `git remote -v` | PASS | Existing `origin` matches the repository URL supplied in the prompt; unchanged. |
| `git ls-files` | PASS | 17 files currently in the index. Many project files are untracked user work and were preserved. |
| `git diff --check` | PASS | No whitespace errors after cleanup of audit formatting. Git reported expected CRLF conversion warnings for Windows-authored text files. |
| `docker version` | BLOCKED | Docker 28.5.1 client found; Docker Desktop Linux engine pipe is unavailable. No image build or container run. |
| `docker compose version` | PASS | Docker Compose v2.40.2-desktop.1. |
| `docker compose -f docker/docker-compose.yml config -q` | PASS | Compose configuration parsed. Does not require the engine. |
| `bash -n scripts/health_check.sh` | PASS | No syntax errors after converting CRLF to LF. |
| `bash -n scripts/recover_service.sh` | PASS | No syntax errors after line-ending correction. |
| `bash -n scripts/simulate_failure.sh` | PASS | No syntax errors after line-ending correction; script was not executed. |
| `node --check app/server.js` | PASS | JavaScript syntax only. |
| `node --check app/test/server.test.js` | PASS | Test source syntax only. |
| `node --test app/test/server.test.js` | FAIL | Cannot load `express`; dependency is not installed locally. No package installation was performed. |
| Python/PyYAML 6.0.3 parse of all `.yml`/`.yaml` | PASS | 26 YAML files parsed with PyYAML 6.0.3. This is a syntax parse, not GitHub workflow semantic validation. |
| JSON parse of Grafana dashboard | PASS | One dashboard JSON parsed. |
| Local Markdown links in README, audit, and docs | PASS | All local targets resolve (11 Markdown files scanned). |
| Terraform (`terraform fmt -check -recursive`, `init -backend=false`, `validate`) | NOT RUN | Terraform is not installed on the Windows PATH. No WSL command was run. |
| Ansible (`ansible --version`, inventory, playbook syntax checks) | NOT RUN | Ansible is not installed on the Windows PATH. No remote hosts were contacted. |
| AWS identity (`aws sts get-caller-identity`) | NOT RUN | AWS CLI is not installed; no account was queried. |
| `actionlint` | NOT RUN | Validator not installed. Workflows received static review and YAML parsing only. |
| `promtool check config` | NOT RUN | Validator not installed; no Prometheus service exists locally. |
| Nagios config validation | NOT RUN | Nagios validator is not installed. |
| Docker image build | NOT RUN | Docker engine unavailable. |
| AWS apply/destroy or remote Ansible | NOT RUN | Explicitly out of audit scope; no cloud or remote host changes. |
| GitHub workflow run / push | NOT RUN | No workflows were triggered and nothing was pushed. |

## Summary

Local static syntax checks passed for the inspected YAML, JSON, JavaScript source, shell scripts, and Compose file. The application test failed due to the missing Express dependency. Engine-backed checks and infrastructure-specific validators remain unavailable. A source scan found no AWS access key, private-key header, or GitHub token pattern in project files (paths/types only). No runtime integration or cloud behavior is verified.


