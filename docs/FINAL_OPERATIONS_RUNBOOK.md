# Final Operations Runbook

## Safe preflight

```bash
terraform fmt -check -recursive
terraform validate
npm ci
npm test
```

## Safe deployment rule

Deploy only through the protected GitHub environment after AWS OIDC and SSM prerequisites are confirmed.

Do not run failure simulation or recovery scripts automatically.

## Health checks

- Application: `curl --fail http://127.0.0.1/health`
- Nginx: `curl --fail http://127.0.0.1/nginx-health`
- Node Exporter: `curl --fail http://127.0.0.1:9100/metrics`
- Prometheus: use the private management route or approved SSH tunnel
- Grafana: use an SSH tunnel rather than public ingress
