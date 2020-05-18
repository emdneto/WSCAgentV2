from os import system, path
import logging
from paramiko import SSHClient, AutoAddPolicy, RSAKey
from paramiko.auth_handler import AuthenticationException, SSHException
from scp import SCPClient, SCPException


class RemoteSSHClient(object):
    
    def __init__(self, target, username):
        self.target = target
        self.user = username
        self.ssh_key_file = path.join(path.expanduser('~'), '.ssh', 'WSCAgentKey')
        self.verifySSHKey()
        
        
    def verifySSHKey(self):
        """
        Fetch locally stored SSH key.
        """
        logger = logging.getLogger(__name__ + '.verifySSHKey')
        try:
            ssh_key = RSAKey.from_private_key_file(self.ssh_key_file)
            logger.info(f'Found {self.ssh_key_file}')
            return True
        except Exception as error:
            logger.error(error)
            return False
            
            
        return self.ssh_key
    
    def connect(self):
        print(self.ssh_key)
        

#teste = RemoteSSHClient('192.168.56.250', 'ws')
#teste.connect()