# Remaining work before first AWS deployment

## 1. Resolve local tooling

Install and verify Terraform, AWS CLI, and Ansible in Ubuntu on WSL 2, plus a Python virtual environment for Ansible. Enable Docker Desktop's WSL integration. The audit did not install software.

## 2. Finish safe repository configuration

- Keep `.env.example` limited to non-secret `APP_PORT`; never put credentials in it.
- Create and review `package-lock.json`, then confirm app CI uses a reproducible install.
- Review GitHub Actions permissions; grant `packages: write` only to image publication.
- Configure GitHub's `production` environment with main-branch restrictions and required reviewers.
- Decide how the EC2 host authenticates to GHCR; if private, provide a narrowly scoped package-read credential through a protected mechanism.
- Ensure remote deployment setup creates `/opt/aws-health-app` and the expected Compose file.
- Keep `.terraform.lock.hcl` committed after Terraform initialization.

## 3. Prepare AWS without applying project infrastructure yet

- Choose account and region; configure AWS Identity Center or another approved short-lived authentication method.
- Run `aws sts get-caller-identity` and confirm the intended account.
- Choose a trusted administrator public IP CIDR and confirm the expected monthly costs.
- Prepare an S3 state bucket separately with public access blocked, encryption, versioning, and `use_lockfile = true`. This setup can incur AWS charges and was not performed here.
- Review IAM permissions and backend access separately; do not put AWS secrets in Terraform files.

## 4. Validate Terraform and provision only after plan review

From WSL Ubuntu, initialize with the real backend, run format/validate, inspect `terraform plan`, and ask for explicit approval before `terraform apply`. Capture outputs only in a safe local place.

## 5. Configure and validate Ansible

- Copy example inventory and group vars to local files ignored by Git.
- Populate addresses from Terraform outputs, not the sample values.
- Check SSH reachability and run `ansible-playbook --syntax-check` for site.yml.
- Review package/service names and run playbooks only against the intended instances after explicit approval.

## 6. Verify app and monitoring on the real hosts

Build/pull the image, verify `http://WEB_PUBLIC_IP/health`, confirm Node Exporter on both private IPs, confirm Prometheus targets are UP, check Grafana panels, and validate Nagios configuration and UI authentication. No such runtime verification has occurred.

## 7. Turn on CI/CD carefully

Run CI on a branch/PR first. Confirm image publication. Configure production protection and deployment secrets, then approve a controlled deployment and verify the remote health check. There is no Git push, workflow dispatch, or deployment from this audit.

## 8. Cost-aware cleanup

Track the resources created for the project. Before any future destroy operation, inspect the plan and obtain explicit approval. This audit did not create or destroy AWS resources.

