import os
import yaml
from pprint import pprint

class pCPEAgent(object):
    
    def __init__(self, req):
        self.data = req
        self.targetIP = req['pcpe_ip_address']
        self.dir = '/tmp'
        self.filePath = None
        self.startAgent()
        
    
    
    def startAgent(self):
        operation = self.data['operation']
        user = 'root'
        
        self.buildYAMLFile()
        self.pCPEAgentSSH(user, operation)
        
    
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
        #print(opCode)
        (user, agentName, opCode)
        
        
    def buildYAMLFile(self):
        slice_id = self.data['slice_id']
        ssids = self.data['ssids']
        operation = self.data['operation']
               
        for ssid in ssids:
            ssid_name = ssid['ssid_name']        
            tmpFileName = f'{slice_id}-{ssid_name}_{operation}.yml'
            self.filePath = os.path.join(self.dir, tmpFileName)
            self.writeYML(self.filePath, ssid)
            
    @staticmethod
    def writeYML(filePath, data):
        
        try:
            ymlFile = open(filePath, "w")
            yaml.dump(data, ymlFile, default_flow_style=False)
            ymlFile.close()
            
        except IOError as err:
            print('Error')
            

        