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
# set -x

# Script to retrieve info from the server
# and make them available in within the
# infrastructure

# Select the network interface
if [ ! -z $1 ]; then
	ETH=$1
else
	ETH=eth0
fi

# Select hostname suffix
if [ ! -z $2 ]; then
        SUFF=-${2}
else
        SUFF=""
fi

# Get the IPV4 address for eth0
ADDRESS=$(ip addr show $ETH | grep "inet " | cut -d" " -f6 | cut -d"/" -f 1)
# Composing the Hostname
SERVERNAME=$(echo "$(hostname)${SUFF}") 

# check credentials file
if [ ! -f .mysql_cred ] ; then
	echo "unable to read mysql credentials, please refer to the manual"
	exit 1
else
	source .mysql_cred
fi

# check for already existent records
TEST=$(echo "select * from server_list where name = \"$SERVERNAME\";" |mysql -h $DBHOST -u $USER -p${PASSWORD} $DB)
if [ ! -z "$TEST" ]; then
	 echo "update server_list set ip=\"${ADDRESS}\" ,updated_at=NOW() where name = \"$SERVERNAME\" limit 1 ;" |mysql -h $DBHOST -u $USER -p${PASSWORD} $DB && exit 0
else
	echo "insert into server_list (ip,name,updated_at) values(\"$ADDRESS\",\"$SERVERNAME\",now());" |mysql -h $DBHOST -u $USER -p${PASSWORD} $DB
fi
