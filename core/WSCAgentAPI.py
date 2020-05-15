#!/usr/bin/env python3.7
from flask import Flask
from flask_restful import Resource, Api
import logging
from core.resources import DeploySSID
import logging
import sys

root = logging.getLogger()
root.setLevel(logging.DEBUG)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
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
        self.api.add_resource(DeploySSID, '/necos/wscagent/ssid/deploy')
        
    def run(self):
        self.app.run(host='0.0.0.0', port='8080', debug=True)