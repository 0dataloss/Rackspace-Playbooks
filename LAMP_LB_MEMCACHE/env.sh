#!/bin/bash
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
