import os
import yaml
import shutil
import logging
from pprint import pprint
from core.helpers.remote_ssh import RemoteConnections

class pCPEAgent(object):
    
    def __init__(self, req):
        self.data = req
        self.targetIP = req['pcpe_ip_address']
        self.tmpDir = '/tmp'
        self.filePath = None
        self.ssidsToDeploy = []
        self.log = logging.getLogger()
        
    def startAgent(self):
        operation = self.data['operation']
        user = 'root'
        self.buildYAMLFile()
        agent = self.pCPEAgentSSH(user, operation)
        return agent
        
        
    
    def pCPEAgentSSH(self, user, op):
        agentName = 'WSCAgentAN'
        agentMap = {
            'deploy': 
                {'code': 1, 'agent': agentName}, 
            'update': 
                {'code': 2, 'agent': agentName}, 
            'list': 
                {}, 
            'delete': 
                {'code': 3, 'agent': agentName}
            }
        
        opCode = agentMap[op]['code']
        agent = agentMap[op]['agent']

        rconnection = RemoteConnections()
        ssh = rconnection.ssh_connect(self.targetIP, user)
        scp = rconnection.scp_connect(ssh)
        rconnection.scp_transfer_file(self.filePath, scp)
        
        for ssid in self.ssidsToDeploy:
            
            execution = rconnection.ssh_run_command(ssh, agent, opCode, ssid)
            
            if execution is not True:
                self.log.error('Error de execução! Interrompendo...')
                rconnection.remove_tmp_files(ssh, self.filePath)
                rconnection.close_connections(scp, ssh)
                del rconnection
        
                try:
                    shutil.rmtree(self.filePath)
                except OSError as e:
                    self.log.error("Error: %s : %s" % (self.filePath, e.strerror))
                
                return execution
            else:
                continue
        
        self.log.info(f'Finalizando a criação das ssids. Limpando arquivos do diretório {self.filePath} em {self.targetIP}')
        rconnection.remove_tmp_files(ssh, self.filePath)
        self.log.info(f'Fechando conexão ssh com ${self.targetIP}')
        rconnection.close_connections(scp, ssh)
        del rconnection
        
        self.log.info('Limpando diretório local de arquivos YAML')
        try:
            shutil.rmtree(self.filePath)
        except OSError as e:
            self.log.error("Error: %s : %s" % (self.filePath, e.strerror))
        
        return True
        
        #run_agent(user, agentName, agentMap[])
        
        
    def buildYAMLFile(self):
        slice_id = self.data['slice_id']
        ssids = self.data['ssids']
        operation = self.data['operation']
        
        fileDir = f'slice_{slice_id}_yamldir'
        fileDirPath = os.path.join(self.tmpDir, fileDir)    
          
        try:
            if not os.path.exists(fileDirPath):
                os.mkdir(fileDirPath)
                self.filePath = fileDirPath
            else:
                self.log.info("Diretório já existe! Skipping")
        except OSError:
            self.log.error("Creation of the directory %s failed" % fileDir)
        else:
            self.log.info("Successfully created the directory %s " % fileDir)
            self.filePath = fileDirPath
                
        for ssid in ssids:
            ssid_name = ssid['ssid_name']        
            tmpFileName = f'{slice_id}-{ssid_name}_{operation}.yml'
            filePath = os.path.join(self.tmpDir,fileDir,tmpFileName)
            self.ssidsToDeploy.append(filePath)
            self.log.info(f'Building YAML file for {ssid_name}')
            self.writeYML(filePath, ssid)
                    
    
    def writeYML(self, filePath, data):
        
        try:
            ymlFile = open(filePath, "w")
            yaml.dump(data, ymlFile, default_flow_style=False)
            ymlFile.close()
            self.log.info(f'Successfully creted the YAML file at {filePath}')
        except IOError as err:
            self.log.error(err)
            

        