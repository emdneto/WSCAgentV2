#!/usr/bin/python3
# 
# This file keeps the classes and methods responsible for contact and activate the WSC Agents 
# in the testbed devices of the WISE Demonstration
#

from os import system
from flask import request
from paramiko import SSHClient, AutoAddPolicy
from scp import SCPClient
import logging
import yaml


# Class responsible for the ssh and scp connections
class RemoteConnections:
    def __init__(self):
        self.YAML_DIR = "/tmp"
        self.AGENTS_DIR = "/usr/share/wise/"
        self.log = logging.getLogger()

	# Establish SSH connection 
    def ssh_connect(self, hostname, username):
        ssh = SSHClient()
        ssh.load_system_host_keys()
        ssh.set_missing_host_key_policy(AutoAddPolicy())
        ssh.connect(hostname=hostname, username=username)
        return ssh

	# Create SCP variable through SSH connection   
    def scp_connect(self, ssh):
        scp = SCPClient(ssh.get_transport())
        return scp

	# Transfer file through SCP
    def scp_transfer_file(self, file, scp):
        scp.put(file, recursive=True, remote_path=self.YAML_DIR)
  
	# Send SSH command to run the agent script
    def ssh_run_command(self, ssh, agent, operation, yaml_file):
        agent_file = "{0}{1}.sh".format(self.AGENTS_DIR, agent)
        stdin,stdout,stderr = ssh.exec_command("{0} {1} {2}".format(agent_file, operation, yaml_file))
        
		# Verify and show the exit_status
        
        if stderr.channel.recv_exit_status() != 0:
            for line in stderr.read().splitlines():
                self.log.error(line.decode('utf-8'))
            return False
        else:
            for line in stdout.read().splitlines():
                self.log.info(line.decode('utf-8'))
            return True
    
    def remove_tmp_files(self, ssh, filePath):
        #agent_file = "{0}{1}.sh".format(self.AGENTS_DIR, agent)
        #stdin,stdout,stderr = ssh.exec_command("{0} {1} {2}".format(agent_file, operation, yaml_file))
        
        stdint,stdout,stderr = ssh.exec_command(f'rm -rf {filePath}')
		# Verify and show the exit_status
        if stderr.channel.recv_exit_status() != 0:
            for line in stderr.read().splitlines():
                print(line.decode('utf-8'))
            return False
        else:
            for line in stdout.read().splitlines():
                print(line.decode('utf-8'))
            return True

	# Close ssh and scp connections
    def close_connections(self, scp, ssh):
	    scp.close()
	    ssh.close()
