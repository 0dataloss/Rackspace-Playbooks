# Rackspace-Playbooks

Playbooks for building scalable solutions in Rackspace Cloud

A sub-directory for every project will contain:
- Ansible Playbook (txt.yaml)
- Bash scripts (txt.sh)
- The architecture of the infrastructure (txt.ascii)
- Documentation for every file (txt.txt)

In order to use the templates you need to have an Ansible console.
I usually suggest to have it in within Rackspace Cloud in order to use Service-net 
for all the code push or configuration actions; all the traffic on Service-net
is for free. 
To install a consolle spin-up a Debian 8 Cloud Server, 1GB will be good enough as a start.

To make your server an Ansible console, log into the server and execute:

     apt-get update && apt-get upgrade -y && reboot
     apt-get install python-dev python-pip mysql-client vim -y
     pip install pyrax
     pip install ansible
     apt-get install ansible

In /etc/ssh/ssh_config change the StrictHostKeyChecking line from:

     #  StrictHostKeyChecking ask
to

     StrictHostKeyChecking no

In /etc/ansible/hosts at the end of the file add:

     [localhost]
     localhost ansible_connection=local

Create an ssh using the command ssh-keygen anc then issue the command
cat /root/.ssh/id_rsa.pub

Copy the output, log in in your control panel in Rackspace Cloud and
create a key with name start_key and past the output of the previous command
in the space for the public key.

Select your template, compile the relevanf file as per README.md and enjoy



Every file in this repository is intended to be released under the Apache License, Version 2.0
and as per documentation http://opensource.org/licenses/Apache-2.0 if not differently specified
in the file itself.

   Copyright 2015 Matteo Castellani <matteo@t-hoster.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
