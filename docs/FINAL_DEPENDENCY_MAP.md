# Final Dependency Map

- Terraform `compute.tf` -> `network.tf`, `security.tf`, `variables.tf`, AMI and EC2 key pair.
- Terraform `security.tf` -> `network.tf` VPC/subnet and monitoring/web resource references.
- Ansible `site.yml` -> web, deploy-app, monitoring, metrics and Grafana playbooks.
- Web play -> common, Docker, Nginx and recovery roles.
- Monitoring play -> common, Nagios, recovery, Node Exporter, Prometheus and Grafana roles.
- Docker Compose -> `app_image` group variable.
- Nginx -> loopback application port `app_port`.
- Prometheus -> private web/monitoring IP variables and Node Exporter port 9100.
- Grafana -> local Prometheus datasource and repository dashboard JSON.
- Nagios -> private IP host definitions and health endpoints.
- Application workflow -> `app/package-lock.json`, Dockerfile and tests.
- Deployment workflow -> OIDC role variables and SSM instance variables.
