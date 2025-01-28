#!/bin/bash

cd $(dirname $0)

git checkout main
git pull https://${CI_ACCESS_TOKEN_NAME}:${CI_ACCESS_TOKEN}@gitlab.onefiserv.net/zeng/aap/tenant-template.git

# Creates filetree_output/
ansible-playbook playbooks/export.yml -e controller_configuration_filetree_read_secure_logging=false -e @vars/aap_admin_vars.yml --vault-password-file=$1

# Creates filetree_output_flatten/
ansible-playbook playbooks/clean_export.yml -e controller_configuration_secure_logging=false -e @vars/aap_admin_vars.yml --vault-password-file=$1

git add . 
git commit -m "Export AAP controller resources"
git push https://${CI_ACCESS_TOKEN_NAME}:${CI_ACCESS_TOKEN}@gitlab.onefiserv.net/zeng/aap/tenant-template.git
