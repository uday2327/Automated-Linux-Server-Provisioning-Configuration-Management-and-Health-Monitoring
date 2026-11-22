# AWS OIDC and SSM Setup

## GitHub OIDC

Create a bootstrap IAM OIDC provider for `https://token.actions.githubusercontent.com` with audience `sts.amazonaws.com`.

Create a deployment role whose trust policy restricts:

- Repository and organization.
- Audience `sts.amazonaws.com`.
- Protected `production` environment or `refs/heads/main`, as chosen.

The repository variables are:

- `AWS_ROLE_ARN`
- `WEB_INSTANCE_ID`
- `MONITORING_INSTANCE_ID`
- `TF_STATE_BUCKET`
- `TF_STATE_KEY`
- `TF_ADMIN_CIDR`
- `TF_SSH_PUBLIC_KEY`

No AWS access-key secrets are required.

## EC2 SSM prerequisites

Attach an instance profile with Amazon SSM managed-instance permissions to both EC2 instances. Verify:

- SSM Agent is running and registered.
- Instances have outbound HTTPS connectivity to AWS endpoints.
- The deployment role can call `ssm:DescribeInstanceInformation`, `ssm:SendCommand`, and required session APIs.

The protected deployment workflow supports Ansible through the `community.aws.aws_ssm` connection. Live execution is not claimed until the SSM plugin and instance registration are tested.
