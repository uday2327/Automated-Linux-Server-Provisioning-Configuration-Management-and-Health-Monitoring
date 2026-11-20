# Prometheus

`prometheus.yml` scrapes Node Exporter on the web and monitoring hosts every 15 seconds. Target IPs are Ansible template variables populated from local group variables. `alert_rules.yml` defines CPU, memory, disk, and target-down alerts. Configuration validation with `promtool` was not run because the validator is unavailable.
