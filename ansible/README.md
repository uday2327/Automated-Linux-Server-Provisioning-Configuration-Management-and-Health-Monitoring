# Ansible

This directory configures the web and monitoring EC2 hosts. `playbooks/site.yml` sequences web setup, application deployment, and Nagios setup.

## Configure the hosts

From this directory, copy the examples to local files:

```bash
cp inventory/hosts.ini.example inventory/hosts.ini
cp group_vars/all.yml.example group_vars/all.yml
```

Set the public IP addresses in `inventory/hosts.ini` for SSH access from your workstation. Set the private IP addresses in `group_vars/all.yml` for Nagios checks between the EC2 instances. The shared variables configure the Ubuntu user, SSH private key, and Python 3 interpreter. These local files are ignored by Git.

## Validate and deploy

Install the required collection and validate the playbooks:

```bash
export ANSIBLE_CONFIG="$PWD/ansible.cfg"
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbooks/site.yml --syntax-check
ansible all -m ping
```

Set `ANSIBLE_CONFIG` explicitly when working from a WSL-mounted Windows directory; Ansible may otherwise ignore the project configuration because the mounted directory is world-writable.

After confirming both hosts are reachable, apply the configuration:

```bash
ansible-playbook playbooks/site.yml
```

The web host receives Docker, Nginx, and the application container. The monitoring host receives Nagios. This does not create or modify AWS infrastructure.
