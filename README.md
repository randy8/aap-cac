1. Create Git project access token - maintainer with read rights

2. Fill out vars file, adding the previous step's Git token to `gitlab_credentials.inputs.token` and any `vaulted_credentials.inputs.*path*`
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
