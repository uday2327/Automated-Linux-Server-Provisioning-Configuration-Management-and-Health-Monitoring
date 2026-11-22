# Final Repository Audit

## Status

This audit distinguishes static repository evidence from live AWS evidence.

## Core repository

- `terraform/`: AWS VPC, subnet, security groups, key pair and two EC2 instances.
- `ansible/`: complete web and monitoring orchestration and role content.
- `app/`: Express health/status/application metrics service.
- `docker/`: Dockerfile, Compose file and build context exclusions.
- `monitoring/`: Nagios, Prometheus and Grafana configuration.
- `scripts/`: health, recovery and failure simulation helpers.
- `.github/workflows/`: validation and protected deployment workflows.

## Findings resolved in repository work

- Added `/metrics` and endpoint tests.
- Added `app/package-lock.json` and Docker `npm ci`.
- Added Docker build exclusions.
- Connected metrics and Grafana playbooks to `site.yml`.
- Corrected the Nagios handler to `nagios4`.
- Added Prometheus configuration-validation handler.
- Added monitoring-SG Node Exporter ingress for private self-scraping.
- Added Terraform plan ignore patterns and removed `terraform/tfplan` from tracking.
- Removed duplicate tracked Ansible inventory variables from tracking.

## Remaining live blockers

- AWS credentials and backend access.
- AWS OIDC provider/role.
- EC2 instance profile and SSM Agent registration.
- Live SSH or SSM access.
- Live Docker engine.
- Live monitoring health verification.
