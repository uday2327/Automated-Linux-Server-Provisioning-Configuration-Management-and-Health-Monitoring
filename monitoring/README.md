# Monitoring

This directory contains Nagios host/service definitions, Prometheus scrape and alert rules, and Grafana data-source/dashboard provisioning. Ansible installs/configures these components on the monitoring EC2 host. Targets are templated from Ansible variables; actual target reachability and monitoring data remain unverified.
