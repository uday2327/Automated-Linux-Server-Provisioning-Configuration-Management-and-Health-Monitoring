# Scripts

`health_check.sh` checks the application and Nginx endpoints, Nginx service, container health when Docker exists, and disk use. `recover_service.sh` retries application or Nginx recovery up to three times. `simulate_failure.sh` stops the app container or Nginx for a controlled exercise. Prometheus-related checks are reserved for a later phase. Operational scripts have not been run on deployed hosts.
