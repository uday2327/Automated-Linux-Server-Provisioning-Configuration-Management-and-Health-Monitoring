# Terraform: AWS infrastructure

This directory creates a VPC with one public subnet and two Ubuntu 24.04 EC2 instances: a web server and a monitoring server. It also creates an internet route, a shared EC2 key pair, and separate security groups. There are no modules or IAM instance roles because the configured instances do not call AWS APIs. The resources are tagged with the project name and role.

## Required tools and access

Use Ubuntu on WSL 2 with Terraform 1.10 or newer, AWS CLI v2, and an SSH client. Use an AWS IAM Identity Center (SSO) profile or another short-lived approved identity. The Terraform workflow pins Terraform 1.10.5 and runs validation only; it does not authenticate to AWS or deploy resources.

## 1. Configure AWS SSO and verify identity

In the VS Code Ubuntu terminal:

```bash
aws configure sso
aws sso login --profile dev
export AWS_PROFILE=dev
aws sts get-caller-identity
aws configure get region --profile dev
```

Use your own profile name instead of `dev`. The identity output must show the account and role you intend to use. Set the profile region in the AWS CLI or in `terraform.tfvars`; Terraform's `aws_region` variable is authoritative for the provider.

## 2. Prepare SSH access

If you do not already have a suitable key pair, create one in WSL:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/aws-devops-sre
chmod 600 ~/.ssh/aws-devops-sre
chmod 644 ~/.ssh/aws-devops-sre.pub
```

Terraform reads only the `.pub` public key. The private key remains in WSL and is never a Terraform input or output.

## 3. Set project values

From the repository root:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set `aws_region`, your current public IPv4 CIDR in `admin_cidr` (prefer `/32`), and `ssh_public_key_path`. Adjust instance types only after checking regional availability and cost. The sample admin address is documentation-only. `terraform.tfvars` is ignored by Git.

## 4. State initialization

The configuration declares an S3 backend but does not create its bucket. The example backend settings are in `backend.hcl.example`; replace the sample bucket with a bucket you own. Before using it, configure S3 public access block, encryption, versioning, least-privilege access, and S3 native state locking (`use_lockfile = true`). The backend example does not create these protections or resources. S3 storage and requests can incur charges.

Save a private backend config file outside the repository. Then run:

```bash
terraform init -backend-config=/secure/path/backend.hcl
```

For syntax-only initialization without a real backend, use:

```bash
terraform init -backend=false
```

Do not switch between local and remote state casually; Terraform may require explicit state migration. Never commit state files or backend credentials.

## 5. Format, validate, and review a plan

```bash
terraform fmt -check -recursive
terraform validate
terraform plan
```

Read the full plan. Check the region, two instance types, SSH CIDR, public HTTP exposure, and estimated costs. `terraform plan` requires configured AWS credentials and a usable backend. A successful plan is not approval to apply.

## 6. Apply only after human approval

After you have reviewed the plan and explicitly decided to create these resources, run manually:

```bash
terraform apply
```

Review the plan shown by Terraform and type `yes` only when it matches your intent. GitHub Actions never runs apply. No infrastructure was created during the audit.

## 7. Supply addresses to Ansible

Show outputs:

```bash
terraform output
```

The outputs include web/monitoring instance IDs and public/private IP addresses. Copy the private IPs to `ansible/inventory/hosts.ini` and `ansible/group_vars/all.yml`; use public IPs only for SSH when required. The inventory/group variables remain local and ignored. Do not copy private SSH keys into Terraform outputs or the repository.

## 8. Intentional destroy

Only when you intentionally want to delete project infrastructure, inspect first:

```bash
terraform plan -destroy
```

Review every resource and obtain explicit approval before running:

```bash
terraform destroy
```

Never use destroy as routine troubleshooting. Preserve or back up state according to your retention needs.

## Troubleshooting

- **No valid credential sources:** log in with `aws sso login --profile dev`, then check `AWS_PROFILE` and `aws sts get-caller-identity`.
- **Wrong region or no AMI:** verify `aws_region`; the AMI lookup selects Canonical Ubuntu 24.04 amd64 in that region.
- **SSH key file error:** check `ssh_public_key_path` points to an existing `.pub` file visible from WSL.
- **CIDR validation failure:** use an IPv4 CIDR such as your current public IP with `/32`; `0.0.0.0/0` is rejected.
- **Backend bucket not found/access denied:** create and secure the bucket separately, use the correct region, and confirm the SSO identity has backend permissions.
- **State lock held:** confirm no other Terraform run is active before considering lock recovery; do not delete a lock while another run may be operating.
- **Resource limit or quota error:** check the selected region's EC2 quota and instance availability before applying again.
- **Unexpected plan replacement:** stop and inspect the changed attributes and current state before approving any change.

## Validation status

Terraform was not installed on the audited Windows PATH, so `fmt`, `init`, and `validate` were not run locally. See [the validation report](../docs/validation-report.md) and [remaining work](../docs/remaining-work.md).
