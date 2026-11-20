# Setup guide (Windows 11 + WSL 2)

This guide separates local setup from cloud provisioning. It does not assume that AWS credentials, a GitHub repository connection, EC2 instances, or software are already configured. The audit host had Git 2.51.0.windows.2, Node v25.2.1, npm 11.7.0, Python 3.11.5, Docker 28.5.1, and Docker Compose v2.40.2-desktop.1. Terraform, Ansible, AWS CLI, actionlint, promtool, and Nagios validators were not found on Windows PATH. These findings do not describe WSL tool availability.

## Stage 1: Open the project

1. In Windows 11, open VS Code and choose **File > Open Folder**. Select the project workspace.
2. Open the integrated terminal and choose the Ubuntu (WSL) profile. If it is not listed, install/configure WSL Ubuntu and the VS Code WSL extension first.
3. In [VS CODE UBUNTU TERMINAL], verify the path:

```bash
cd "/mnt/c/Users/dixit/OneDrive/Desktop/aws automated server provision and health services"
pwd
```

Expected: the project directory under `/mnt/c/...`. Keep cloud commands in WSL so SSH keys and Linux permissions behave consistently.

## Stage 2: Check or install local tools

In [VS CODE UBUNTU TERMINAL], check each command before installing anything:

```bash
for tool in git python3 terraform aws ansible docker; do command -v "$tool" || echo "$tool: not found"; done
```

Expected: a path for installed tools and `not found` for missing ones. Install Terraform and AWS CLI from their official vendor instructions and Ansible in a Python virtual environment only after reviewing the installation steps. Do not install the whole stack blindly. Docker should normally come from Docker Desktop integration, not a second daemon in WSL.

Create/activate an Ansible virtual environment (after Python venv support exists):

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install ansible-core ansible-lint
ansible-galaxy collection install -r ansible/requirements.yml
ansible --version
```

This installs Ansible packages into the project-local ignored `.venv`; use the same environment when running Ansible. If you do not want to install packages yet, skip this step and mark Ansible checks NOT RUN.

## Stage 3: Verify Docker Desktop integration

Start Docker Desktop in Windows, enable WSL integration for the Ubuntu distribution, then run in [VS CODE UBUNTU TERMINAL]:

```bash
docker version
docker compose version
```

Expected: both client and server sections for `docker version`, plus a Compose version. If the server section cannot connect, start Docker Desktop and enable the correct WSL integration. Do not run `docker compose down` as a generic troubleshooting step.

## Stage 4: GitHub access and repository

Use the existing local repository; do not change its remote or history as part of setup. In [VS CODE UBUNTU TERMINAL]:

```bash
git status --short --branch
git remote -v
```

Expected: current branch and repository URL. Authenticate to GitHub using the approved Git Credential Manager or `gh auth login` if GitHub CLI is installed. Never paste tokens into a command or chat. Before committing, inspect `git diff` and `git status`; this workspace already has user-created uncommitted files.

## Stage 5: Configure AWS authentication

If AWS CLI is installed, use AWS Identity Center where available. In [VS CODE UBUNTU TERMINAL]:

```bash
aws configure sso
aws sso login --profile YOUR_PROFILE
export AWS_PROFILE=YOUR_PROFILE
aws sts get-caller-identity
```

Replace `YOUR_PROFILE` with a local profile name. Expected output is an account ID and ARN for the intended identity. Do not send credentials or the full identity output publicly. If authentication fails, check the SSO start URL, region, browser login, and profile name. Do not use long-lived keys in the repository.

No AWS account or identity was verified during the audit.

## Stage 6: Prepare Terraform values

In [VS CODE UBUNTU TERMINAL]:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` locally. Set a real AWS region, trusted administrator CIDR (`/32` where possible), existing public SSH key path, and reviewed instance settings. The example CIDR and key path are not live values. Keep `terraform.tfvars` untracked.

The S3 backend example is not ready to use as-is. Before `terraform init` with the backend enabled, create a protected state bucket separately, enable versioning/encryption/block-public-access, and configure S3 native state locking. This can incur AWS costs. Do not create it without reviewing costs and authorization.

## Stage 7: Validate and review Terraform

From [VS CODE UBUNTU TERMINAL], in `terraform/`:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Expected: formatting already correct, providers initialized, and configuration valid. `init -backend=false` does not configure the remote backend; it may need network access to download the provider. If commands are unavailable, install Terraform first rather than claiming validation passed.

Only after a real backend and authentication are configured:

```bash
terraform init -reconfigure -backend-config=/secure/path/backend.hcl
terraform plan
```

Read the entire plan and cost implications. Ask for explicit approval before `terraform apply`; this audit did not apply anything.

## Stage 8: Map Terraform outputs to Ansible

After approved provisioning, read the outputs:

```bash
terraform output
```

Copy the web and monitoring public/private addresses into local copies of `ansible/inventory/hosts.ini.example` and `ansible/group_vars/all.yml.example`. Use private addresses for Prometheus/Nagios internal checks; use public addresses for SSH only when needed. Save as `hosts.ini` and `all.yml`, which are ignored by Git.

Check the inventory and syntax:

```bash
cd ..
ansible-inventory -i ansible/inventory/hosts.ini --list
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/site.yml --syntax-check
```

Expected: two host groups and a successful syntax message. If values are still placeholders, stop and correct them. Test SSH with the configured user/key only after the instances exist and security-group rules permit your current IP.

## Stage 9: Configure servers and application

Review the playbook diff and target list first. After approval to configure those remote machines:

```bash
ansible -i ansible/inventory/hosts.ini all -m ping
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/site.yml
```

Expected: both hosts respond and tasks finish without failed tasks. Do not run this against an unknown inventory. If a task fails, check SSH, sudo, Ubuntu version, repository access, and variable values. The audit did not run these commands remotely.

For local app checks in [VS CODE UBUNTU TERMINAL]:

```bash
cd app
npm install
npm test
cd ..
docker compose -f docker/docker-compose.yml config -q
docker build -t aws-health-app:local -f docker/Dockerfile .
```

These commands may download Node packages and build a local image. The current repository has no package lock; the workflow currently uses `npm install`; add a reviewed lock file for reproducible CI. The audit ran Compose config but did not build or start a container.

## Stage 10: Verify application and monitoring

On the deployed web host, verify from a permitted client:

```bash
curl --fail http://WEB_PUBLIC_IP/health
```

Expected JSON with status `ok`. Replace the sample host with the Terraform output. On the monitoring host, check Prometheus targets in its UI, open Grafana and confirm the data source/query panels show actual metrics, and validate Nagios configuration with `nagios4 -v /etc/nagios4/nagios.cfg`. A dashboard file alone does not prove metrics are flowing.

Admin ports 9090, 3000 and 80 are restricted by `admin_cidr`; keep that CIDR narrow. Verify Nagios web authentication before exposing the interface.

## Stage 11: GitHub Actions and deployment

In the GitHub website, configure a `production` environment with required reviewers and branch restrictions. Configure only the needed SSH host, username, and key secrets; also ensure the remote host can pull the GHCR image. Never store secret values in repository files. Run validation on a pull request first. The existing app deployment path requires `/opt/aws-health-app` and a matching Compose file on the host; confirm this after Ansible configuration. Do not enable deployment until package permissions and remote authentication have been reviewed.

## Troubleshooting and safe cleanup

- Terraform authentication: check `aws sts get-caller-identity` and selected profile.
- Terraform backend: confirm bucket name/region, access rights, versioning, and lockfile support.
- SSH: check address, key path/permissions, username `ubuntu`, and admin CIDR.
- Ansible variables: make sure private inventory/group-vars files exist and placeholders are replaced.
- Docker: check Docker Desktop's WSL integration and run `docker compose config -q`.
- Prometheus targets down: check Node Exporter services, private IPs, and port 9100 security-group access.
- Grafana empty panels: check Prometheus target state, datasource URL, dashboard queries, and time range.
- Nagios: check `nagios4 -v` and plugin availability.

Before destroying infrastructure, run `terraform plan -destroy`, inspect every resource, and obtain explicit approval. This audit did not create or destroy AWS resources.


