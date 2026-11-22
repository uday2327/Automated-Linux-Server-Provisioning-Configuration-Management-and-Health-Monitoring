# Command Reference

## Safe local verification

```bash
./scripts/verify-project.sh
```

Exit codes:

- `0`: required checks passed and no checks were skipped.
- `1`: one or more required checks failed.
- `2`: all available required checks passed but optional checks were skipped.

## Terraform

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Live-state planning requires separate approval:

```bash
terraform init -backend-config="$HOME/.config/aws-devops-sre/backend.hcl"
terraform plan -out=tfplan
terraform show tfplan
```

Do not run `terraform apply` or `terraform destroy` until the approved plan is reviewed.

## Ansible

```bash
cd ansible
export ANSIBLE_CONFIG="$PWD/ansible.cfg"
ansible-inventory -i inventory/hosts.ini.example --list
for playbook in playbooks/*.yml; do
  ansible-playbook -i inventory/hosts.ini.example "$playbook" --syntax-check
done
```

Live deployment is separate from these static checks and requires explicit approval.

## Application and Docker

```bash
cd app
npm ci
npm test
node --check server.js

cd ..
docker compose -f docker/docker-compose.yml config --quiet
docker build --file docker/Dockerfile --tag aws-health-app:test .
```
