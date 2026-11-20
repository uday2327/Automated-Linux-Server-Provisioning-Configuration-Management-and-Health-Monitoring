# Troubleshooting

## Terraform

- Authentication: run `aws sts get-caller-identity`.
- Backend: verify S3 bucket, region and lock configuration.
- Public key: verify `ssh_public_key_path` exists and ends in `.pub`.
- AMI: verify the selected Ubuntu AMI exists in the region.

## Ansible

- Connectivity: test `ssh ubuntu@SERVER_IP`.
- Inventory: replace all example placeholder addresses.
- Syntax: run `ansible-playbook --syntax-check`.

## Docker

- Logs: `docker compose logs --tail=100 app`.
- Health: `docker inspect --format '{{.State.Health.Status}}' aws-health-app`.
- Verify loopback publishing: `127.0.0.1:3000:3000`.

## Nginx

- Validate: `sudo nginx -t`.
- Status: `sudo systemctl status nginx --no-pager`.
- Health: `curl http://127.0.0.1/nginx-health`.

## Monitoring

- Node Exporter: `curl http://127.0.0.1:9100/metrics`.
- Prometheus: `promtool check config /etc/prometheus/prometheus.yml`.
- Grafana: inspect `/var/log/grafana/grafana.log`.
- Nagios: `sudo nagios4 -v /etc/nagios4/nagios.cfg`.
