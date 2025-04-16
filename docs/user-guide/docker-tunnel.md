# Docker Tunneling


## Probing the SSH Connection

To check if the SSH connection to the remote Docker daemon is working, run the following command:

```bash
#RDOCKER_CONTEXT=remote0
rdocker ssh-probe
```


## Starting the Tunnel

When starting a tunnel, the 

```bash
#RDOCKER_CONTEXT=remote0
rdocker tunnel-up
```


### Stopping the Tunnel

```bash
#RDOCKER_CONTEXT=remote0
rdocker tunnel-down
```