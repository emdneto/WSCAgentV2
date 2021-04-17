# WanSliceControllerAgent

## Deploying

WSCAgent uses Python 3.7, so you will have to install it:

```bash
$ apt install python3.7
```

#### Clone this repo
```bash
$ git clone <git@github.com:Zowder/WanSliceControllerAgent.git>
```

#### Gitlab EWG: 

```bash
$ https://gitlab.com/necos-ufrn/ewg 

$ git checkout code-refactoring
```
#### Configure virtualenv
```bash
$ apt install python3-pip
$ pip3 install virtualenv
$ virtualenv .venv/WSCAgent
$ source .venv/WSCAgent/bin/activate
```

#### Install requirements
```bash
$ (WSCAgent) pip install -r requirements.txt
```


## Before running

Before running WanSliceControllerAgent, check if there is a key pair (public and private) on the server to access the remote devices (pCPEs and etc.)
```shell
$ apt install sshpass

$ ls $HOME/.ssh
...
WSCAgentKey
WSCAgentKey.pub
```
### If you do not have a key configured do the following steps:

**1. Generate RSA key pair:**
```shell
$ ssh-keygen -t rsa -b 4096 -C "WSCAgent@WSCMaster" -f $HOME/.ssh/WSCAgentKey -q -N ""
$ eval "$(ssh-agent -s)"
$ ssh-add ~/.ssh/WSCAgentKey
```

**2. Copy the public key to the remote devices:**

- 2.1. Add the servers to the `inventory` file

    ```shell
    $ cat inventory
    10.7.227.130
    10.7.227.131
    ```

- 2.2. Run this script in the project directory to copy the keys (Only works for OpenWRT Devices):
    ```bash
    
    for ip in `cat inventory`; do
        echo "------- Deploying WSCAgentKey.pub to root@${ip} -------"
        sshpass -p 'pass_here' ssh -o StrictHostKeyChecking=no root@$ip "tee -a /etc/dropbear/authorized_keys" < ~/.ssh/WSCAgentKey.pub 
    done
    ```

- 2.3 Test connection:
    ```bash
    $ ssh 10.7.227.130

    ```
- 2.4 Setup WSC shell scripts:
    ```bash
        for ip in `cat inventory`; do
            scp -r -o StrictHostKeyChecking=no core/wise/  root@$ip/usr/share/
        done
    ```
    

## Running
```bash
$ (WSCAgent) python3.7 main.py
``` 

## WSCAgent API

This is a simple documentation of the WSCAgent REST API. Its endpoints can be found in `.core.resources`.

To add a method to the WSCAgent API, first include the `flask_restful.Resource` subclass in `.core.resources` then add the endpoint in `_add_resources` function.

The API is available on `0.0.0.0:8089`.

### Deploy a new SSID Pair (Pub and Private)

This method deploys a pair of ssids at once.

| Method |      URI       |
| ------ | -------------- |
| POST    | `/necos/wscagent/ssid` |

Below is an example of request parameters received by the API in JSON

```json
{
  "pcpe_ip_address": "172.17.0.2",
  "slice_id": 1,
  "ssids": [
    {
      "bw_burst": 1.2,
      "bw_rate": 1,
      "ctrl_bridge_name": "pCPE#1",
      "ctrl_port_name": "pt_CLFQFQUCKGJI",
      "gateway_ip_address": "41.89.26.1",
      "gateway_ip_range": {
        "lease": "1h",
        "start": 2,
        "stop": 114
      },
      "gateway_mac_address": "02:00:00:b0:6b:b7",
      "of_port": 20,
      "ssid_bridge_name": "br_RIL0M1DM5FZ3",
      "ssid_name": "pub-ssid",
      "ssid_port_name": "pt_Y0IYZYPI32HU"
    },
    {
      "bw_burst": 1.2,
      "bw_rate": 1,
      "ctrl_bridge_name": "pCPE#1",
      "ctrl_port_name": "pt_OK0EQ4Z878YZ",
      "gateway_ip_address": "188.52.152.1",
      "gateway_ip_range": {
        "lease": "1h",
        "start": 2,
        "stop": 114
      },
      "gateway_mac_address": "02:00:00:a3:1a:67",
      "of_port": 21,
      "ssid_bridge_name": "br_Y9CFFUI533TB",
      "ssid_name": "pvt-ssid",
      "ssid_port_name": "pt_2WXOXQYDOLOR"
    }
  ]
}
```

### Update a SSID Pair (Pub and Private)

This method updates the pair of ssids in a given pCPE.

| Method |      URI       |
| ------ | -------------- |
| PUT    | `/necos/wscagent/ssid` |

Below is an example of request parameters received by the API in JSON

```json
{
	"slice_id": 1,
	"pcpe_ip_address": "172.17.0.2",
	"ssids": [
		{
			"ssid_name": "pCPE1Pub",
			"ctrl_port_name": "pcpe_pt_ssid_1",
			"bw_burst": 5,
			"bw_rate": 6
			
		},
		{
			"ssid_name": "pCPE1Priv",
			"ctrl_port_name": "pcpe_pt_ssid_2",
			"bw_burst": 5,
			"bw_burst": 6
		}
	]
}
```
### Delete a SSID Pair (Pub and Private)

This method deletes the pair of ssids in a given pCPE.

| Method |      URI       |
| ------ | -------------- |
| DELETE    | `/necos/wscagent/ssid` |

Below is an example of request parameters received by the API in JSON

```json
{
	"slice_id": 1,
	"pcpe_ip_address": "172.17.0.2",
	"ssids": [
		{
			"ssid_name": "pCPE1Pub",
			"ssid_bridge_name": "ssid_bridge_pub",
			"ctrl_bridge_name": "PCPE#1",
			"ctrl_port_name": "pcpe_pt_ssid_1"
		},
		{
			"ssid_name": "pCPE1Priv",
			"ssid_bridge_name": "ssid_bridge_priv",
			"ctrl_bridge_name": "PCPE#1",
			"ctrl_port_name": "pcpe_pt_ssid_2"
		}
	]
}
```



