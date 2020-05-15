#!/bin/bash

for ip in `cat inventory`; do
    echo "------- Deploying WSCAgentKey.pub to root@${ip} -------"
    sshpass -p 'pass_here' ssh -o StrictHostKeyChecking=no root@$ip "tee -a /etc/dropbear/authorized_keys" < ~/.ssh/WSCAgentKey.pub 
done