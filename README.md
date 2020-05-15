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

## Running
```bash
$ (WSCAgent) python3.7 main.py
``` 






