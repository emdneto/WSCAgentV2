#!/usr/bin/env python3.7
from flask import Flask
from flask_restful import Resource, Api
import logging
from core.resources import DeploySSID, UpdateSSID, DeleteSSID
import logging
import sys

root = logging.getLogger()
root.setLevel(logging.INFO)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - [%(name)s] - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
root.addHandler(handler)

class WSCAgentRestfulAPI(object):
    
    app = None
    
    def __init__(self):
        super().__init__()
        self.app = Flask(__name__)
        self.api = Api(self.app)
        self._addResources()
        
    def _addResources(self):
        self.api.add_resource(DeploySSID, '/necos/wscagent/ssid')
        self.api.add_resource(UpdateSSID, '/necos/wscagent/ssid')
        self.api.add_resource(DeleteSSID, '/necos/wscagent/ssid')
        
    def run(self):
        self.app.run(host='0.0.0.0', port='8089', debug=True)
