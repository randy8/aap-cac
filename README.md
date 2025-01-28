# tenant-template
1. Clone repo
git clone https://gitlab.onefiserv.net/zeng/aap/tenant-template.git

2. Create GitLab project access token - maintainer with read rights

3. Fill out vars file, adding the previous step's Git token to `gitlab_credentials.inputs.token` and any `vaulted_credentials.inputs.*path*`
```
# Set project name
# Check to see that the execution environment exists within your target AAP instance
$ MY_PROJECT_NAME=""
$ cd vars
$ cp project_name_vars.yml ${MY_PROJECT_NAME}_vars.yml
 
# Update the values
$ vim ${MY_PROJECT_NAME}_vars.yml
 
# Vault the vars file
$ ansible-vault encrypt ${MY_PROJECT_NAME}_vars.yml
New Vault password: [enter password]
 
# Add the line to GitLab CI script to onboard the project into AAP
$ cd ..
$ echo "ansible-playbook playbooks/create_new_aap_resources.yml --vault-password-file=\$1 -e @vars/${MY_PROJECT_NAME}_vars.yml -e @vars/aap_admin_vars.yml" >> onboard_projects.sh
```

4. Push changes to kick off the GitLab CI that creates projects and exports the resources to this repo
