# IAC


 Infrastructure / Configuration as code is defined as the practice of managing configuration files in a repository. In the case of Ansible Automation Platform, these configuration files establish the settings we wish to apply across our Ansible Automation Platform environments.

By storing and managing Ansible Automation Platform configuration files as code, we can:

- standardize the settings being applied to all our Ansible Automation Platform environments
- inherit the benefits of version control of our configurations
- easily scale additional Ansible Automation Platform deployments to use the same configuration settings
- easily track changes of the configuration settings making fixing issues easier 


**Links for more details on the subject**:

- [RedHat CoP Controller Configuration Collection](https://github.com/redhat-cop/controller_configuration/tree/devel)
- [Reference Architecture](https://access.redhat.com/documentation/en-us/reference_architectures/2021/html-single/deploying_ansible_automation_platform_2.1/index#config_as_code_using_webhooks)


---
## Repo structure

- **playbook/backup.yml**: Playbook for exporting AAP resources using `filetree_create` ansible role.
- **playbook/restore_prep.yml**: Playbook for creating folder structure expected by the restore / filetree_read role 
- **playbook/restore.yml**: Playbook for reading AAP resources from filesystem and apply them on the target instance using both `filetree_read` and `dispatch` ansible roles

- **vars/backup_credentials.yml**: Variables (AAP controller credentials & more) for `playbook/backup.yml` 
- **vars/restore_credentials.yml**:  Variables (AAP controller credentials & more) for `playbook/backup.yml`

```sh
tree -L 2
.
├── ansible.cfg
├── collections
│   ├── ansible_collections
│   ├── ansible-controller-4.4.0.tar.gz
│   └── requirements.yml
├── inventory.yml
├── playbooks
│   ├── backup.yml
│   ├── copy_aap_resources_tasks.yml
│   ├── restore_prep.yml
│   └── restore.yml
├── README.md
├── vars
│   ├── backup_credentials.yml
│   └── restore_credentials.yml
└── vault_pass.txt
```

## redhat-cop/controller_configuration Collection Roles

- [filetree_create](https://github.com/redhat-cop/controller_configuration/tree/devel/roles/filetree_create)
  Exports AAP Controller resources from a running instance on the filesystem.

- [filetree_read](https://github.com/redhat-cop/controller_configuration/tree/devel/roles/filetree_read)
  Reads AAP Controllers resources from filesystem into ansible variables ready to be used by dispatch role.

- [dispatch](https://github.com/redhat-cop/controller_configuration/tree/devel/roles/dispatch)
  Applies the resources on an AAP Controller instance


---

## Setup

```sh
### 1. Install collections required
cd .../iac
ansible-galaxy collection install -r collections/requirements.yml

### 2. Test
ansible-galaxy collection list | grep -i ansible.controller || echo NOTINSTALLED

### 3. Create ./vault_pass.txt file
echo "password" >> ./vault_pass.txt

### 4. Create vars/backup_credentials.yml
cat << EOF > vars/backup_credentials.yml
---
vault_controller_username: 'admin'
vault_controller_password: 'password'
vault_controller_hostname: '192.168.1.23'
vault_controller_validate_certs: false
EOF

### 5. Encrypt vars/backup_credentials.yml
ansible-vault --vault-password-file ./vault_pass.txt encrypt vars/backup_credentials.yml

### 6. Create restore_credentials.yml #TODO
cat << EOF > vars/backup_credentials.yml
---
vault_controller_username: 'admin'
vault_controller_password: 'password'
vault_controller_hostname: '192.168.1.23'
vault_controller_validate_certs: false
EOF

### 7. Encrypt backup_credentials.yml #TODO
ansible-vault --vault-password-file ./vault_pass.txt encrypt vars/restore_credentials.yml

### View vault encrypted file
# ansible-vault view --vault-pass-file vault_pass.txt vars/backup_credentials.yml
```

---
## Export / Backup AAP Resources


```sh
cd .../iac

ansible-playbook playbooks/backup.yml \
  --vault-password-file ./vault_pass.txt \
  -e @./vars/backup_credentials.yml \
  -e output_path=/tmp/rhapp_filetree_output
 

# ### Export organizations and projects only
# ansible-playbook playbooks/backup.yml \
#   -e output_path=/tmp/rhapp_filetree_output \
#   -e '{input_tag: [organizations, projects]}' \
#   --vault-password-file ./vault_pass.txt

### Check ToDo
grep -R 'ToDo: ' '/tmp/rhapp_filetree_output'
```

**filetree_create role variables**

- `controller_api_plugin`: 
  Full path for the controller_api_plugin to be used.
  awx.awx.controller_api | ansible.controller.controller_api.
  Default: ansible.controller

- `organization_filter`:
  Exports only the objects belonging to the specified organization.

- `output_path`: 
  The path to the output directory where all the generated yaml files will be stored.
  Default: /tmp/filetree_output

- `input_tag`:
  The tags which are applied to the sub-roles.


---

## Import / Restore AAP resources

Note: **APP Resources generated in step #1 below need to be cleaned up before invoking `playbooks/restore.yml` in step #2.** See details below.


```sh
cd .../iac

### 1. Create filesystem expected by filetree_read role
ansible-playbook playbooks/restore_prep.yml \
  -e filletree_output_path=/tmp/rhapp_filetree_output \
  -e dir_orgs_vars=/tmp/rhapp_filetree_read_input \
  -e orgs=hm \
  -e env=nonprod

### 2. Restore
ansible-playbook playbooks/restore.yml \
  --vault-password-file ./vault_pass.txt \
  -e dir_orgs_vars=/tmp/rhapp_filetree_read_input \
  -e orgs=hm \
  -e env=nonprod \
  -e @./vars/restore_credentials.yml \
  -e controller_configuration_credentials_secure_logging=false
```


### AAP Resources cleaning up before restoring

**Notes**
- Project sync failure can cause restore playbook to fail but it seems to work on subsequent run.

#### **controller_settings.d/all_settings.yml**

The following may need to be commented out
- DEFAULT_EXECUTION_ENVIRONMENT: '2'  # THIS USED PK which is problematic. Can be handler after in UI
- SUBSCRIPTIONS_PASSWORD: ''
- SUBSCRIPTIONS_USERNAME: ''
- TOWER_URL_BASE: https://rhaap.lan
- REDHAT_PASSWORD: ''
- REDHAT_USERNAME: ''

#### **controller_users.d/all_users.yml**

- Comment out admin user since already set during install
- Update user passwords

#### **controller_instance_groups.d/all_instance_groups.yml**

The whole file can be commented out and handle the setup in the controller UI.

#### **controller_credentials.d/all_credentials.yml**

- password/token are not exported and will need to be provided
- credentials with same name and already available in the target instance can be commented out. For example:
  - Default Execution Environment Registry Credential
  - Demo Credential
- Handle credentials where `organization: ORGANIZATIONLESS` e.g. changed to `Default`

Resources provided by default and **all their reference** can be removed. Example
- Demo Inventory (controller_inventories.d/all_inventories.yml)
- Demo Project (controller_projects.d/all_projects.yml)
- Demo Job Template (controller_job_templates.d/all_job_templates.yml)
- Host provided by `Demo Inventory` (controller_hosts.d/all_hosts.yml)
- Default Execution Environment (controller_execution_environments.d/all_execution_environments.yml)
- Minimal Execution environment (controller_execution_environments.d/all_execution_environments.yml)
- Control Plane Execution environment (controller_execution_environments.d/all_execution_environments.yml)

#### **Handles all ToDo**

```sh
grep -R 'ToDo: ' /tmp/rhapp_filetree_read_input/

all_workflow_job_templates.yml:   organization: 'ToDo: The WF ''TF httpd demo workflow'' must belong to an organization'
all_workflow_job_templates.yml:   organization: 'ToDo: The WF ''TF httpd demo workflow'' must belong to an organization'
all_workflow_job_templates.yml:   organization: 'ToDo: The WF ''TF httpd demo workflow'' must belong to an organization'
all_workflow_job_templates.yml:   organization: 'ToDo: The WF ''TF httpd demo workflow'' must belong to an organization'
```


## Example: Simple playbook to apply AAP resources

**Playbook**

```yaml
---
- name: Playbook to configure ansible Controller post installation
  hosts: localhost
  connection: local
  vars:
    controller_validate_certs: false
  collections:
    - awx.awx
    - redhat_cop.controller_configuration

  roles:
    - {role: settings, when: controller_settings is defined, tags: settings}
    - {role: organizations, when: controller_organizations is defined, tags: organizations}
    - {role: labels, when: controller_labels is defined, tags: labels}
    - {role: users, when: controller_user_accounts is defined, tags: users}
    - {role: teams, when: controller_teams is defined, tags: teams}
    - {role: credential_types, when: controller_credential_types is defined, tags: credential_types}
    - {role: credentials, when: controller_credentials is defined, tags: credentials}
    - {role: credential_input_sources, when: controller_credential_input_sources is defined, tags: credential_input_sources}
    - {role: notification_templates, when: controller_notifications is defined, tags: notification_templates}
    - {role: projects, when: controller_projects is defined, tags: projects}
    - {role: execution_environments, when: controller_execution_environments is defined, tags: execution_environments}
    - {role: applications, when: controller_applications is defined, tags: applications}
    - {role: inventories, when: controller_inventories is defined, tags: inventories}
    - {role: instance_groups, when: controller_instance_groups is defined, tags: instance_groups}
    - {role: project_update, when: controller_projects is defined, tags: projects}
    - {role: inventory_sources, when: controller_inventory_sources is defined, tags: inventory_sources}
    - {role: inventory_source_update, when: controller_inventory_sources is defined, tags: inventory_sources}
    - {role: hosts, when: controller_hosts is defined, tags: hosts}
    - {role: groups, when: controller_groups is defined, tags: inventories}
    - {role: job_templates, when: controller_templates is defined, tags: job_templates}
    - {role: workflow_job_templates, when: controller_workflows is defined, tags: workflow_job_templates}
    - {role: schedules, when: controller_schedules is defined, tags: schedules}
    - {role: roles, when: controller_roles is defined, tags: roles}
```

**group_vars/all.yml**

```yaml
# group_vars/all.yml
---
controller_user_accounts:
  - user: "colin"
    is_superuser: false
    password: "redhat"
```