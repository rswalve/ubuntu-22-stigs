sudo mkdir -p /etc/ansible
sudo touch /etc/ansible/ansible.cfg
sudo touch /etc/ansible/hosts
sudo chmod 644 /etc/ansible/ansible.cfg /etc/ansible/hosts


/etc/ansible/ansible.cfg

[defaults]
# Points to the global inventory file
inventory       = /etc/ansible/hosts

# The default user Ansible will use to log into app servers
#remote_user     = sudo-user

# Disables the "Are you sure you want to connect" prompt for new servers
# Useful for automation, but use with caution in high-security environments
host_key_checking = False

# Sets the default path for collections and roles
roles_path      = /etc/ansible/roles

[privilege_escalation]
# Automatically attempt to use sudo
become          = True
become_method   = sudo
become_user     = root
# This ensures it doesn't ask for a sudo password
become_ask_pass = False

[ssh_connection]
# Optimizes speed by reusing SSH connections
pipelining      = True


/etc/ansible/hosts

[app_servers]
stapp01 ansible_host=172.16.238.10
stapp02 ansible_host=172.16.238.11
stapp03 ansible_host=172.16.238.12

[all:vars]
# Ensure it uses Python 3 on CentOS 9
ansible_python_interpreter=/usr/bin/python3