# Final File Inventory

## Infrastructure

- `terraform/*.tf`: provider, backend, network, security, compute, variables and outputs.
- `terraform/terraform.tfvars.example`: safe Terraform input template.
- `terraform/.terraform.lock.hcl`: pinned provider dependencies.

## Configuration

- `ansible/playbooks/site.yml`: complete orchestration entry point.
- `ansible/playbooks/*.yml`: web, application, monitoring, metrics and Grafana playbooks.
- `ansible/roles/*`: implementation roles.
- `ansible/inventory/hosts.ini.example`: non-secret inventory example.
- `ansible/group_vars/all.yml.example`: non-secret variable example.

## Application

- `app/server.js`: Express service.
- `app/test/server.test.js`: endpoint tests.
- `app/package.json` and `app/package-lock.json`: reproducible Node dependencies.
- `docker/Dockerfile`: multi-stage container build.
- `docker/docker-compose.yml`: loopback-only application container.
- `docker/.dockerignore`: Docker build context exclusions.

## Monitoring

- `monitoring/nagios/*`: host, service and command definitions.
- `monitoring/prometheus/*`: scrape configuration and alert rules.
- `monitoring/grafana/*`: datasource, provider and dashboard definitions.

## Automation and documentation

- `.github/workflows/*`: validation and protected deployment workflows.
- `scripts/*`: health and controlled recovery helpers.
- `docs/FINAL_*.md`: final architecture and operations documentation.
