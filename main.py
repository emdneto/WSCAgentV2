#!/usr/bin/env python3.7
"""Start WanSliceController Agent Stack"""

from core import WSCAgentAPI

api = WSCAgentAPI.WSCAgentRestfulAPI()
api.run()