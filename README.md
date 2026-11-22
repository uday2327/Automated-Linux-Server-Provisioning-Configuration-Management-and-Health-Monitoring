# AWS Linux Server Provisioning and Monitoring

This repository is a learning project for provisioning two Ubuntu EC2 servers with Terraform, configuring them with Ansible, deploying a small Node.js health application with Docker, and monitoring the servers with Nagios, Prometheus, Node Exporter, and Grafana.

For implementation status and safe local commands, use [FINAL_VALIDATION_REPORT.md](docs/FINAL_VALIDATION_REPORT.md), [FINAL_SETUP_GUIDE.md](docs/FINAL_SETUP_GUIDE.md), [FINAL_CICD_GUIDE.md](docs/FINAL_CICD_GUIDE.md), and [FINAL_OPERATIONS_RUNBOOK.md](docs/FINAL_OPERATIONS_RUNBOOK.md).

## Current status

The repository contains implementation files for the intended architecture, but it has not been deployed to AWS or verified end to end. Several settings remain examples that must be replaced with real Terraform outputs and protected local values. See the [audit](DEVOPS_PROJECT_AUDIT.md), [file inventory](docs/file-inventory.md), [validation report](docs/validation-report.md), and [remaining work](docs/remaining-work.md).

## Architecture

```text
Developer -> GitHub -> GitHub Actions
                         |-- validate Terraform / Ansible
                         |-- test and publish the app image to GHCR
                         `-- gated SSH deployment (requires repository setup)

Terraform -> VPC + public subnet + Web EC2 + Monitoring EC2
Ansible -> Docker/Nginx/app/Node Exporter on Web EC2
        -> Node Exporter/Prometheus/Grafana/Nagios on Monitoring EC2
Prometheus <- Node Exporter on both EC2 instances
Grafana -> Prometheus; Nagios -> host and HTTP checks
```

The web host exposes HTTP on port 80. The application container binds to host loopback on port 3000, behind Nginx. SSH and monitoring UI ports are restricted to the configured administrator CIDR. Node Exporter is reachable only from the monitoring security group.

## Technology

AWS EC2, Terraform, Ansible, Ubuntu, Docker Compose, Node.js/Express, Nginx, GitHub Actions, GHCR, Nagios, Prometheus, Node Exporter, Grafana, and Bash.

## Repository layout

```text
.github/workflows/  CI, application image, and deployment workflows
ansible/            Inventory examples, playbooks, and server roles
app/                Node.js health application and test
docker/             Dockerfile and Compose definition
docs/               Architecture, setup, troubleshooting, and audit support
evidence/           Evidence guidance and incident template
monitoring/         Nagios, Prometheus, and Grafana configuration
scripts/            Health, recovery, and failure simulation helpers
terraform/          AWS network, security groups, EC2, variables and outputs
```

## Implemented in the repository

- Terraform definitions for a VPC, public subnet, internet route, security groups, and two Ubuntu EC2 instances.
- Ansible roles for base packages, Docker, Nginx, Node Exporter, Prometheus, Grafana, Nagios, and recovery scripts.
- A small Express application with `/`, `/health`, `/api/status`, and `/metrics` endpoints.
- A Dockerfile and Compose service with a health check and loopback-only host port binding.
- Monitoring configuration and a Grafana dashboard definition.
- GitHub Actions workflows for validation, application CI/image publishing, and SSH deployment.

These are checked-in configurations, not proof of a successful deployment. See the audit for limitations and unverified integrations.

## Local preparation

Use VS Code with Ubuntu on WSL 2 for Terraform and Ansible, and Docker Desktop with WSL integration for container work. The local audit found Windows Git, Node.js, npm, Python, Docker CLI, and Docker Compose. Terraform, Ansible, AWS CLI, `actionlint`, `promtool`, and Nagios validators were not found on the Windows PATH. Check the [beginner setup guide](docs/setup-guide.md) for exact setup and validation steps.

## Execution outline

1. Configure AWS authentication and a restrictive administrator CIDR.
2. Create and protect a remote Terraform state bucket before remote initialization.
3. Review the Terraform plan, then apply only after a separate explicit approval.
4. Fill the Ansible inventory and group variables from Terraform outputs.
5. Run Ansible syntax checks, test SSH, and configure the servers.
6. Build and deploy the application, then verify `/health` through Nginx.
7. Verify Prometheus targets, Grafana data, and Nagios service checks.
8. Configure GitHub environments and secrets before enabling the gated deployment workflow.

Do not run `terraform apply` as part of this audit. No AWS resources have been created or tested here.

## Monitoring

Prometheus is configured to scrape Node Exporter on both hosts. Grafana's provisioned data source points to Prometheus on the monitoring host. Nagios has host and HTTP service definitions. The target addresses and server-side service configuration must be verified on real instances before these integrations can be called operational.

## Security

Do not commit `.env`, Terraform state, local `.tfvars`, private keys, or credentials. Restrict SSH and admin interfaces to a trusted CIDR. Use GitHub OIDC for future Terraform workflows; the existing Terraform workflow is validation-only and does not authenticate to AWS. Enable required reviewers and branch restrictions for the production environment before deployment.

## Limitations

- No AWS deployment, live application, CI run, or monitoring data has been verified.
- Example inventory and target addresses need to be updated from Terraform outputs.
- GHCR access, production environment protection, and SSH deployment secrets need configuration.
- Terraform remote backend infrastructure does not exist; backend setup may incur AWS charges.
- The application dependency lock file is not present, so reproducible npm installs need to be addressed before CI is relied on.

## Evidence

No live deployment evidence is included. Follow [evidence/README.md](evidence/README.md) and do not store credentials in screenshots or logs.

## Next steps

Start with [docs/setup-guide.md](docs/setup-guide.md), then use [docs/remaining-work.md](docs/remaining-work.md) as the implementation checklist.
