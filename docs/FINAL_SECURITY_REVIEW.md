# Final Security Review

## Confirmed controls

- SSH is restricted by `admin_cidr`.
- Web HTTP remains public.
- Node Exporter is restricted to monitoring sources.
- Prometheus and Grafana have no public ingress rules.
- Terraform plans and SSH private keys are excluded from the repository.
- Ansible keeps host-key checking enabled.
- Docker application port binding remains localhost-only.
- GitHub workflows do not use permanent AWS access keys.

## Manual requirements

- Rotate any secret that was committed previously.
- Configure and protect AWS OIDC trust.
- Configure protected GitHub environment reviewers.
- Configure EC2 instance profiles and SSM Agent.
- Keep Grafana protected by SSH tunnelling or an approved private-access method.
