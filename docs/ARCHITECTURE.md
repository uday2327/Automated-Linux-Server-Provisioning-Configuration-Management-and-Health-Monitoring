# Architecture

## Current design

The intended deployment uses a single VPC with a public subnet and two Ubuntu 24.04 LTS EC2 instances. Terraform creates the network, key pair, security groups, and instances. Ansible configures the web and monitoring hosts from separate inventory groups.

```text
Git push -> GitHub -> GitHub Actions
                         | Terraform format/init/validate (no AWS credentials)
                         | app test + image build/publish to GHCR
                         ` gated SSH deployment (requires protected environment)

Terraform -> Web EC2: Docker/Compose, app container, Nginx, Node Exporter
          -> Monitor EC2: Nagios, Prometheus, Grafana, Node Exporter
Prometheus scrapes both Node Exporters; Grafana queries Prometheus.
Nagios checks host reachability and web/Nginx HTTP endpoints.
```

## Network flows in configuration

| Source | Destination | Port | Purpose | Configured restriction |
|---|---|---:|---|---|
| Public clients | Web EC2 | 80 | Nginx and application | Public IPv4 |
| Admin CIDR | Both EC2 | 22 | SSH | `var.admin_cidr` |
| Admin CIDR | Monitor EC2 | 9090, 3000, 80, 443 | Prometheus, Grafana, Nagios UI | `var.admin_cidr` |
| VPC CIDR | Both EC2 | 9100 | Node Exporter | VPC-wide CIDR |
| Nginx on web EC2 | App container | 3000 | Reverse proxy | Host port bound to loopback |

## Integration status

Terraform outputs provide instance public/private addresses, but there is no automatic inventory generation. The operator must copy private addresses into `ansible/inventory/hosts.ini` and `ansible/group_vars/all.yml`. Prometheus and Nagios files are Ansible templates and consume those group variables. Grafana uses a local Prometheus URL because both run on the monitoring host.

Ansible's `site.yml` runs the web configuration, app deployment, then monitoring configuration. These playbooks have not been run against live servers. The monitoring UI packages and default web authentication still require on-host review.

## Limits

There is one public subnet, no high availability, no TLS termination, no managed database, and no automated Terraform apply. The configured S3 backend is only a stub; its bucket and lock configuration must be prepared separately. Do not apply Terraform until cost, IAM permissions, and a plan are reviewed.
