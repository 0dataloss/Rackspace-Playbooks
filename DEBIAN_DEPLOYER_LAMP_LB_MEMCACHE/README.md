# Use of this infrastructure

This infrastructure is a "two way" code publishing.
Is good for all the websites/blog where the code and files
are uploaded and managed from 2 different sources:
- the Deployer server which you canuse as an SFTP server
- the web interface which is offering uploads functionality

# How to use this template

This template is comprehensive of:

- A presentation Layer : Cloud Load Balancer
- An application layer : Cloud Servers (WEB+Memcache)
- A Database Layer : Cloud Database instance
- A code distribution Layer: Deployer2Web - Web2Deployer (every 20 sec)

Type of file and content:

- Architecture.ascii
    A visual representation of the architecture this template will create for you
  
- DB_instance.yaml
    This Playbook is responsible for creating:
    - 1 instance with 512MB RAM + 1GB storage,
      you can change DBINSTANCENAME, RAMDBINSTANCENAME, DISKDBINSTANCENAME in the generate_infrastructure.sh file
    - 2 databases with pre defined credentials, but you HAVE to define them the first time in the generate_infrastructure.sh file
    - 2 users, predefined username and password, one for each DB
    
- NET_Cloud.yaml
    This Playbook will create a private network, you can change the default parameters directly in the file
    - Label mem
    - network 172.16.0.0/24

- SRV_instances.yaml
    This Playbook is responsible for creating:
    - A Public to S-net Cloud Load Balancer
    - A number of Web servers, assign them to the web group and connect them to the Cloud Load Balancer previously created
    - 1 Memcache server and assign it to the memcache group
    - 1 Deployer server used as a repository to distribute code to the web nodes
    - Additionally, if the webserver's number will change in time, the Playbook is able to adjust the CLB settings in realtime (delete or add nodes)
    
- SW_config.yaml
    This Playbook is responsible for installing software for all the machines in the infrastructure
    
- env.sh
    This script is used on the remote machines in pair with the .mysql_cred file to keep the name-ip_address updated in the service DB
    
- generate_infrastructure.sh
    The initial script which will orchestrate the Playbooks and tune the configuration files for all the servers.
    It contains most of the variables which will determine your infrastructure and by default you will need to use a number as a parameter
    to define the numbers of web servers you want as initial configuration (keep in mind you will be able to add and remove servers later on)

- maintain infrastructure.sh
    Basically the same as the generate_infrastructure.sh but stripped out from the actions which does not need to be taken
    every time we want to scale up pr down the Web layer or rebuild a single server
    
- rax.py
    This file represent the dynamic inventory of Ansible, please see http://docs.ansible.com/guide_rax.html

- repo
    repo file contains the necessary information for the authentication of rax.py
    
- server_files
    Template which will be copied on the servers
    
- sqlschema.sql
    The SQL shema for the Service Database
    
- template
    Templates for specific configuration files
