#!/bin/bash

cd $(dirname $0)

# Replace "MY_PROJECT_NAME" accordingly
# ansible-playbook playbooks/create_new_aap_resources.yml --vault-password-file=$1 -e @vars/${MY_PROJECT_NAME}_vars.yml -e @vars/aap_admin_vars.yml

# Comment out the previously onboarded repos
# ansible-playbook playbooks/create_new_aap_resources.yml --vault-password-file=$1 -e @vars/fts_zeng_ansible_vars.yml -e @vars/aap_admin_vars.yml
# ansible-playbook playbooks/create_new_aap_resources.yml --vault-password-file=$1 -e @vars/fs_optis_ansible_vars.yml -e @vars/aap_admin_vars.yml
# ansible-playbook playbooks/create_new_aap_resources.yml --vault-password-file=$1 -e @vars/zos-automation_vars.yml -e @vars/aap_admin_vars.yml
# ansible-playbook playbooks/create_new_aap_resources.yml --vault-password-file=$1 -e @vars/zeng_ocp_healthcheck_vars.yml -e @vars/aap_admin_vars.yml
# ansible-playbook playbooks/create_new_aap_resources.yml --vault-password-file=$1 -e @vars/zeng_ocp_update_vars.yml -e @vars/aap_admin_vars.yml
# ansible-playbook playbooks/create_new_aap_resources.yml --vault-password-file=$1 -e @vars/zeng-ocs-ansible_vars.yml -e @vars/aap_admin_vars.yml
ansible-playbook playbooks/create_new_aap_resources.yml --vault-password-file=$1 -e @vars/zeng_aap_zvmrestart_vars.yml -e @vars/aap_admin_vars.yml
