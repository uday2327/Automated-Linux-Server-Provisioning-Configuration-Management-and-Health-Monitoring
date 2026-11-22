# Final CI/CD Guide

GitHub Actions is split across application, image publication, Terraform, Ansible and protected deployment workflows.

## GHCR

Application publication uses the commit SHA as the immutable image tag. `latest` is convenience-only.

## AWS authentication

The deployment workflow uses GitHub OIDC and a GitHub repository variable named `AWS_ROLE_ARN`. AWS key secrets must not be created.

## Deployment transport

The protected workflow verifies OIDC and SSM Agent registration. Live SSM deployment remains blocked until:

1. A least-privilege EC2 instance profile exists.
2. The SSM Agent is registered on both instances.
3. Both instances have required outbound network connectivity.
4. The OIDC role can call the required SSM APIs.
5. An approved Ansible-over-SSM method is implemented and tested.
