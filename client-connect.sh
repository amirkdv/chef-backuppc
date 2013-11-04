#!/bin/bash
# script to connect machine to BackupPC server
# first argument is the URL to obtain the public key
# for the backuppc user
# url must include HTTP authorization credentials if necessary
# http://[user]:[pass]@[fqdn]/id_rsa.pub
url=$1
[[ -z $url ]] && echo 'you must specify a URL' && exit 1
echo 'downloading public key from $url/id_rsa.pub ...'
backuppc_key=$( curl -s $url/id_rsa.pub )
[[ ! -d /root/.ssh ]] && mkdir /root/.ssh

keys_file='/root/.ssh/authorized_keys'
touch $keys_file
echo 'copying key to authorized_keys file ...'
grep -q "$backuppc_key" $keys_file || echo $backuppc_key >> $keys_file
