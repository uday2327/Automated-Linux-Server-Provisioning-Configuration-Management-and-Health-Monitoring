# Nagios

Host and service definitions cover both Linux hosts with ping checks, the web application's `/health` endpoint, the Nginx `/nginx-health` endpoint, and the Nagios process on the monitoring host. Ansible templates addresses from group variables and validates the complete configuration before restarting Nagios. Prometheus, Grafana, and Node Exporter are reserved for a later phase. Nagios configuration and live status must still be verified on deployed hosts.
