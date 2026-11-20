# Final Project Audit

**Audit date:** 2026-11-19
**Workspace:** `aws automated server provision and health services`
**Branch:** `main` (preserved)
**Scope:** Static review and safe local validation only. No AWS resources or remote servers were touched.

## Executive summary

The repository has a coherent two-instance AWS design and contains substantial Terraform, Ansible, application, container, workflow, and monitoring configuration. It is **READY WITH BLOCKERS** for controlled implementation preparation, not ready for AWS deployment: no live resources or end-to-end results were verified; example addresses and backend values need configuration; several external account and workflow settings remain; and Terraform, Ansible, AWS CLI, and monitoring validators are unavailable in the local Windows PATH.

## Actual architecture

Terraform defines an Ubuntu 24.04 web EC2 and monitoring EC2 in one public subnet. Ansible configures Docker/Nginx/app/Node Exporter on the web host and Node Exporter/Prometheus/Grafana/Nagios on the monitoring host. Prometheus scrapes Node Exporter on each host; Grafana queries local Prometheus; Nagios checks host availability and web endpoints. GitHub Actions contains Terraform validation, app build/test/image publication, Ansible validation, and an SSH deployment workflow. These are repository definitions only; no workflow, server, or metric integration was observed live.

## Terraform inventory and simplification

The original Terraform directory contained 11 files: `backend.hcl.example`, `backend.tf`, `compute.tf`, `network.tf`, `outputs.tf`, `providers.tf`, `README.md`, `security.tf`, `terraform.tfvars.example`, `variables.tf`, and `versions.tf`. All remain. No duplicate resource definitions, modules, locals, or unused input variables were found. The unused `vpc_id` and `public_subnet_id` outputs were removed. EC2 Name tags now include `project_name`.

The final Terraform inventory is the same set of 11 paths. S3 native `use_lockfile` replaces deprecated DynamoDB locking in the example; Terraform minimum version is 1.10.0. `admin_cidr` validation rejects invalid IPv4 and the unrestricted `0.0.0.0/0` value. CI pins Terraform 1.10.5 and performs validation only. A provider lock file does not exist yet because Terraform is unavailable locally; `.gitignore` allows it to be committed.

## File inventory

The full path-by-path inventory, status, references, and actions is in [docs/file-inventory.md](docs/file-inventory.md). No project file was removed. The final worktree contains 77 files across 44 non-Git directories; none are empty. Five files were added for Ansible collection requirements and audit/setup deliverables. Existing directories are purposeful.

## Review findings and actions

| Severity | Finding | Action/status |
|---|---|---|
| High | `site.yml` omitted the app deployment play | Fixed by importing `deploy_app.yml` after web preparation |
| High | Prometheus and Nagios IPs were literal placeholders, not template expressions | Fixed to use Ansible variables; values still require real Terraform outputs |
| Medium | Web security group had a loopback-only ingress rule for app port 3000, which is not an external path | Removed; Docker continues to publish only on host loopback |
| Medium | App Compose setting and `.env.example` were inconsistent/duplicated | Compose supports `APP_PORT` with a default and `.env.example` now contains only that optional variable |
| Medium | `.gitignore` ignored Terraform provider lock file | Removed that ignore rule so the generated lock file can be committed |
| Medium | Bash scripts were CRLF and failed `bash -n` | Converted line endings to LF; syntax checks pass after correction |
| Medium | App workflow previously used `npm ci` without a committed lock; changed to `npm install`, which remains less reproducible until a lock file is added | Workflow changed to `npm install`; add a lock file for reproducibility |
| Medium | SSH deployment assumes a prepared remote directory, Compose file and GHCR pull access | Not verified; configure and protect the GitHub production environment before enabling |
| Medium | Terraform S3 backend is a stub; example uses deprecated DynamoDB locking | Kept backend infrastructure uncreated; use S3 native `use_lockfile` for a future setup, with bucket versioning and access controls. [HashiCorp S3 backend docs](https://developer.hashicorp.com/terraform/language/backend/s3) |
| Low | Several README files still describe components as future work | Root README and architecture doc now describe discovered configuration; per-folder notes are retained and may still need harmonization |
| Low | `.env.example` had duplicated names and values from earlier edits | Reduced to the optional `APP_PORT` value; no secrets |
| Informational | `DEVOPS_PROJECT_AUDIT.md` originally described a different empty repository | Replaced with this current audit |

### Kept files

All original files were retained, including short directory README files, `commands.cfg`, sample configs, evidence templates, and the older setup/runbook materials. Their small size or possible redundancy was not sufficient reason to delete user work. No evidence artifacts were present beyond templates and guidance.

## Component audit

### Terraform

Provider region and default tags are variable-driven. Configuration defines a VPC, public subnet, internet gateway/route, security groups, key pair, and two EC2 instances. Ubuntu AMI selection uses Canonical owner ID and a Noble 24.04 name filter. IMDSv2 is required and EBS roots are encrypted. SSH and monitoring ingress use `admin_cidr`; HTTP is public on the web host; exporter access is allowed from the VPC CIDR. The loopback-only application security-group rule was removed as unnecessary.

The S3 backend block is intentionally incomplete. The example now uses S3 native `use_lockfile`; create and protect the bucket separately. Terraform minimum version is 1.10.0 to support native S3 locking. Do not configure a paid backend or apply resources during this audit. A committed `.terraform.lock.hcl` should be generated during Terraform initialization and retained. Input variables are all referenced; there are no modules/locals. The VPC and subnet outputs were unused and removed.

### Ansible

Inventory examples separate web and monitoring groups. Terraform outputs are not automatically converted into inventory. `site.yml` now configures web, deploys the application, then configures monitoring. Roles reference example group variables and need an operator-created `all.yml`. They have not received syntax validation because Ansible is unavailable. Some tasks use absolute references derived from `playbook_dir`; these remain unverified by Ansible.

### Application and Docker

The Express app listens on 3000 and exposes health/status/metrics routes. Docker builds from repository root using `docker/Dockerfile`, installs Express, runs as a non-root user, and has a health check. Compose publishes `127.0.0.1:3000:3000`, matching Nginx's upstream and limiting direct external access. Docker Compose config validation passed. No image build or container start was performed. A package lock is absent, so the CI workflow uses `npm install`; add a reviewed lock file before relying on reproducible CI.

### GitHub Actions

All workflow files are under `.github/workflows`. Terraform workflow is validation-only and has read-only contents permission. App workflow tests and publishes to GHCR, then deploys over SSH on main pushes under a `production` environment. The environment must be configured with required reviewers and branch restrictions; SSH host/user/key and GHCR pull access remain external requirements. Workflow permissions need tightening by separating read-only test work from package-write publication. No AWS OIDC workflow exists; no Terraform apply workflow is present, which avoids unreviewed infrastructure changes.

### Monitoring

Prometheus has a 15-second scrape/evaluation interval and scrapes both Node Exporters. Its targets now template Ansible group vars. Grafana datasource points to `127.0.0.1:9090` on the monitoring host and a dashboard has CPU, memory, disk, network, uptime, and target availability PromQL panels. Nagios host and service definitions use group vars and standard `check_ping`/`check_http` plugin commands. `commands.cfg` is not installed and contains only an include directive; retain it pending a Nagios config review. Nagios config validation, plugin availability, UI authentication, and live target status are unverified.

### Scripts

Health and recovery scripts have bounded checks/retries. Failure simulation stops the application container or Nginx and is intentionally not executed. Scripts now use LF endings and pass `bash -n`. Recovery commands have not been executed. No Python scripts exist.

## Security review

- No credentials or private-key values were found in the reviewed project files. This is a working-tree review, not a complete Git-history secret scan.
- `.gitignore` covers `.env`, local tfvars, state, key/certificate suffixes, caches and logs. The provider lockfile exclusion was removed.
- SSH uses a required admin CIDR variable. Ensure it is a current trusted `/32`; the example address is documentation-only.
- Web HTTP is public by design. Admin interfaces are restricted to `admin_cidr`; exporter ingress is VPC-wide and should be narrowed to the monitoring security group when practical.
- Nagios/Grafana password values are placeholders in the sample group variables; actual protected credentials and UI authentication have not been verified.
- Recovery script logs may contain health URLs but do not intentionally print credentials. No scripts were executed.
- CI deploys via SSH rather than AWS OIDC; no AWS credentials are presently in workflows. Use OIDC for future AWS API access, following [GitHub AWS OIDC guidance](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws).
- Package permissions and production deployment protections need review before enabling CI deployment.

## Validation

Exact commands and results are in [docs/validation-report.md](docs/validation-report.md). YAML, JSON, JavaScript syntax, shell syntax, and Compose configuration checks passed. Terraform, Ansible, AWS CLI, actionlint, promtool, and Nagios validators were not available. There was no runtime or cloud validation.

## Three independent reviews

1. **Functionality:** Found missing app play in `site.yml` and literal monitor target placeholders. Both cross-file issues were corrected. Package-lock and remote deployment prerequisites remain.
2. **Security/reliability:** Found unnecessary app SG loopback ingress and provider lockfile ignore; corrected both. Confirmed no secret-like values surfaced in the source review. Workflow permissions and server-side monitoring UI access remain to configure.
3. **Completeness/maintainability:** Found stale audit/architecture language and duplicated `.env.example` keys; the prior audit was replaced and architecture/README updated. Per-folder status notes were updated; future setup commands still need to be exercised in WSL.

## Integration matrix

| Component | Configuration present | Connection represented | Validation | Status |
|---|---|---|---|---|
| GitHub | Existing `origin` remote | Repository contains workflow definitions | Remote inspected; no push | Present, not remotely operated |
| GitHub Actions | Three workflow files | Terraform/app/Ansible path triggers | YAML parse/static review only | Needs actionlint/CI and permission review |
| Terraform | VPC, subnet, SGs, key pair, two EC2 resources | Outputs provide IPs for manual Ansible configuration | Terraform unavailable | Configured, unvalidated; backend incomplete |
| AWS EC2 | Terraform resources only | Web and monitoring instances described | No AWS CLI/account or deployment used | Not provisioned |
| Ansible | Inventory examples, site/web/monitoring/app playbooks and roles | Uses Terraform output values via local inventory/group vars | Ansible unavailable | Configured, unvalidated |
| Docker | Dockerfile and Compose | Ansible and app workflow reference Compose/Dockerfile | Compose config passed; engine/build unavailable | Configured, not built |
| Application | Express service and test source | Docker image uses app files | JS syntax passed; test blocked by missing Express | Source present, runtime unverified |
| Nginx | Ansible role/template | Proxies loopback port 3000 to container | No Nginx validator/server | Configured, unverified |
| Nagios | Host/service definitions and Ansible role | Checks host, HTTP, Nginx, exporter | No Nagios validator/server | Configured, unverified |
| Prometheus | Scrape config/alert rules and role | Scrapes both Node Exporters | YAML parse only; no promtool/server | Configured, targets need real IPs |
| Node Exporter | Ansible role on both hosts | Port 9100 allowed from VPC | No service/runtime test | Configured, unverified |
| Grafana | Datasource, dashboard provider, JSON dashboard | Datasource points to local Prometheus | YAML/JSON syntax only | Provisioning present, live data unverified |
| Scripts | Health/recovery/simulation | Installed by recovery role | `bash -n` passed; not executed | Syntax valid, behavior unverified |
| Documentation | README, audit, architecture, guide, inventory, validation and remaining-work files | Links point to local docs | Link scan passed | Present; future setup still to be performed |

## Readiness verdict

**READY WITH BLOCKERS.** The repository is suitable for local implementation preparation. It is not ready for AWS deployment or a claim of full operation until toolchain checks, example configuration updates, package locking, deployment protections, remote-state preparation, and end-to-end validation are completed.

See [docs/remaining-work.md](docs/remaining-work.md) for the ordered checklist.
