from flask_restful import Resource, reqparse
from flask import jsonify
import logging

from core.WSCAgent import pCPEAgent

class DeploySSID(Resource):
    
    def post(self):
        parser = reqparse.RequestParser()
        parser.add_argument('slice_id', type=int, help='Missing Slice Identification. Provide a Int Value', required=True)
        parser.add_argument('pcpe_ip_address', type=str, help='Missing PCPE IP', required=True)
        parser.add_argument('ssids', type=dict, action='split')
        args = parser.parse_args()
        args['operation'] = 'deploy'
        pCPE = pCPEAgent(args)
        return args
