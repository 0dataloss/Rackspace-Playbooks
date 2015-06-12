#!/bin/bash
#   Copyright 2015 Matteo Castellani <matteo@t-hoster.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# define numbers, names, and passwords
DBINSTANCENAME=instance_name
RAMDBINSTANCENAME=1
DISKDBINSTANCENAME=1
APPDBNAME=web_db
USERAPPDBNAME=username
PASSUSERAPPDBNAME=test123 # Generate your password using "cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1"
BEDBNAME=back-end_DB
USERBEDBNAME=username
PASSUSERBEDBNAME=testtest # Generate your password using "cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1"
WEBSRVN=2
MEMCACHESRVN=1 # for this infrastructure there will be only one memcache server
MEMCACHEPORT=11211
MEMCACHEADDR=eth2

# Run paybook for db generation

DBHOST=$(ansible-playbook  DB_instance.yaml -e "dbinstancename=$DBINSTANCENAME ramdbinstancename=$RAMDBINSTANCENAME diskdbinstancename=$DISKDBINSTANCENAME appdbname=$APPDBNAME userappdbname=$USERAPPDBNAME passuserappdbname=$PASSUSERAPPDBNAME BEdbname=$BEDBNAME userBEdbname=$USERBEDBNAME passuserBEdbname=$PASSUSERBEDBNAME"| grep msg | tail -n1 | cut -d\" -f4 ) 

# Compile app-db conf file
echo "DBHOST=$DBHOST
DB=$APPDBNAME
USER=$USERAPPDBNAME
PASSWORD=$PASSUSERAPPDBNAME" > .mysql_cred_app

# Compile be-db conf file
echo "DBHOST=$DBHOST
DB=$BEDBNAME
USER=$USERBEDBNAME
PASSWORD=$PASSUSERBEDBNAME" > .mysql_cred

# Create service DB
echo "select * from server_list limit 1;" |mysql -h $DBHOST -u $USERBEDBNAME -p$PASSUSERBEDBNAME $BEDBNAME || mysql -h $DBHOST -u $USERBEDBNAME -p$PASSUSERBEDBNAME $BEDBNAME < ./sqlschema.sql

# Run playbook for servers, networks, and LB generation

RAX_ACCESS_NETWORK=private ansible-playbook  NET_Cloud.yaml
RAX_ACCESS_NETWORK=private ansible-playbook  SRV_instances.yaml -e "websrvn=$WEBSRVN memcachesrvn=$MEMCACHESRVN"

# Generate memcache config files from templates
LIST=$(echo "select ip from server_list where name like \"memcache%-${MEMCACHEADDR}\";" |mysql --skip-column-names -h $DBHOST -u $USERBEDBNAME -p$PASSUSERBEDBNAME $BEDBNAME )
echo $LIST
HOWMANY=$(a=0; for i in $(echo $LIST); do a=$(($a+1)); done ; echo $a)
cp -ad  ./template/memcache.ini ./server_files/web/etc/php5/mods-available/memcache.ini
cp -ad ./template/php.ini ./server_files/web/etc/php5/apache2/php.ini
LINE=$(echo "${LIST}:${MEMCACHEPORT}")
$(echo "sed -i  -e s/MEMCACHESERVERSHERE/\'${LINE}\'/g  ./server_files/web/etc/php5/apache2/php.ini ")
$(echo "sed -i  -e s/SERVERNUMBERHERE/${HOWMANY}/g ./server_files/web/etc/php5/mods-available/memcache.ini ")

# Run playbook for software configuration
RAX_CREDS_FILE=./repo RAX_ACCESS_NETWORK=private ansible-playbook -i rax.py SW_config.yaml
