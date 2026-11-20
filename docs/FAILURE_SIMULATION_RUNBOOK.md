# Failure Simulation Runbook

Only run these tests after EC2 resources and recovery scripts are installed.

## Application container failure

1. Record the incident start time.
2. Run `scripts/simulate_failure.sh app`.
3. Confirm Nginx reports an unavailable application.
4. Run `scripts/recover_service.sh --service app`.
5. Record retries and final exit code.
6. Verify `curl http://127.0.0.1/health`.

## Nginx failure

1. Record the incident start time.
2. Run `scripts/simulate_failure.sh nginx`.
3. Verify the public HTTP endpoint fails.
4. Run `scripts/recover_service.sh --service nginx`.
5. Verify `curl http://127.0.0.1/nginx-health`.

The scripts make at most three recovery attempts and never reboot the host.
