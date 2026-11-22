# Final Architecture

```text
Developer -> GitHub Actions
  -> Application tests -> GHCR immutable SHA tag
  -> Terraform validation/plan
  -> Protected approval
  -> AWS OIDC
  -> SSM deployment transport
  -> Ansible site.yml
       -> Web EC2: Docker, Nginx, application
       -> Monitoring EC2: Nagios, Prometheus, Grafana

Prometheus -> private Node Exporter targets
Nagios -> private web and monitoring targets
Grafana -> localhost Prometheus datasource
```

Web HTTP is public on port 80. SSH is restricted to `admin_cidr`. Node Exporter port 9100 is restricted to monitoring sources. Prometheus 9090 and Grafana 3000 are not public.
