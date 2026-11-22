# Final Setup Guide

Run commands from WSL Ubuntu.

```bash
cd "/mnt/c/Users/dixit/OneDrive/Desktop/aws automated server provision and health services"
git status
cd app
npm ci
npm test
cd ../terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Do not run `terraform apply` or `terraform destroy` unless a separate explicit approval is given.

For Ansible syntax:

```bash
cd ../ansible
export ANSIBLE_CONFIG="$PWD/ansible.cfg"
ansible-galaxy collection install -r requirements.yml
ansible-inventory -i inventory/hosts.ini.example --list
for playbook in playbooks/*.yml; do
  ansible-playbook -i inventory/hosts.ini.example "$playbook" --syntax-check
done
```
