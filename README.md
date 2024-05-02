# Commands to run:

## Install necessary collections (from top level directory)
ansible-galaxy install -r collections/requirements.yml

## Export AAP configs and flatten output from source cluster
```
ansible-playbook export.yml -e controller_configuration_filetree_read_secure_logging=false -e @../vars/export_credentials.yml --ask-vault-pass
ansible-playbook clean_export.yml -e controller_configuration_secure_logging=false -e @../vars/export_credentials.yml --ask-vault-pass
```

## Import AAP configs into destination cluster (source can also be the destination to create new objects)
```
ansible-playbook import.yml -e controller_configuration_filetree_read_secure_logging=false -e @../vars/import_credentials.yml --ask-vault-pass
```

## Creating resources via playbook
```
---
- name: Create a job template
  hosts: localhost
  connection: local
  gather_facts: false
  vars:
    controller_username: "{{ vault_controller_username | default(lookup('env', 'CONTROLLER_USERNAME')) }}"
    controller_password: "{{ vault_controller_password | default(lookup('env', 'CONTROLLER_PASSWORD')) }}"
    controller_hostname: "{{ vault_controller_hostname | default(lookup('env', 'CONTROLLER_HOST')) }}"
    controller_validate_certs: "{{ vault_controller_validate_certs | default(lookup('env', 'CONTROLLER_VERIFY_SSL')) }}" 
  tasks:
    - name: Create a job template
      ansible.controller.job_template:
        controller_host: "{{ controller_hostname }}"
        controller_username: "{{ controller_username }}"
        controller_password: "{{ controller_password }}"
        validate_certs: "{{ controller_validate_certs }}"
```
The following variables must be set in order for the module to communicate with the API. This pattern will be consistent with other object types.
Any future changes can be made in `filetree_output_flatten/`.

## From the playbooks/ directory
```
ansible-playbook ./example_playbooks/create_job_template.yml -e @../vars/export_credentials.yml --ask-vault-pass
```