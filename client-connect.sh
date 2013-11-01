#!/bin/bash
# script to connect machine to BackupPC server
# first argument is the URL to obtain the public key
# for the backuppc user
# url must include HTTP authorization credentials if necessary
# http://[user]:[pass]@[fqdn]/id_rsa.pub
url=$1
backuppc_key=$( curl -s $url )

[[ ! -d /root/.ssh ]] && mkdir /root/.ssh

keys_file='/root/.ssh/authorized_keys'
touch $keys_file
grep -q "$backuppc_key" $keys_file || echo $backuppc_key >> $keys_file
