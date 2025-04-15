# rdocker

Simple, fast, and secure way to connect to remote Docker daemons.


## How it works

Under the hood `ssh`, `autossh`, `socat` and `docker` commands 
are wrapped to create a secure and stable tunnel to a remote Docker daemon.

The `rdocker` script creates tunnels the remote docker daemon socket to a local socket 
and (optionally) exposes the socket via a TCP proxy to the controlling host (localhost),
which allows you to run docker commands on the remote machine as if they were running locally.


## Features

- 🔐 **Secure**: Uses SSH to connect to remote Docker daemon.
- 🚀 **Fast**: Uses a permanent tunnel and the `docker` CLI to interact with the remote Docker daemon.
- 💪 **Resilient**: Automatically reconnects to the remote Docker daemon if the connection is lost.
- 🍳 **Simple**: Spin up a tunnel to the remote Docker daemon with a single command.
- 🪶 **Lightweight**: No need to install any additional software on the remote server.
- 📦 **Compact**: Only a few hundred lines of code. Docker image is less than 50MB.
- 💻 **Portable**: Can be run from any machine with SSH access to the remote server.
- ✅ **Easy to use**: Just use `rdocker` command instead of `docker` to interact with remote Docker daemon.



## Getting Started

### Prerequisites

- 💻 Local machine
  - ✅ Docker CLI installed on your local machine.
  - ✅ SSH client installed on your local machine.
  - ✅ SSH access to the remote server.
- 🌐 Remote server
  - ✅ Docker Engine installed on the remote server.
  - ✅ SSH server installed on the remote server.


### Create a rdocker configuration

To create a `rdocker` configuration, run the following command:

```bash
mkdir -p ~/.rdocker

cat <<EOF > ~/.rdocker/remote0.env
RDOCKER_REMOTE_HOST=remote0.example.com
RDOCKER_REMOTE_USER=ubuntu
RDOCKER_REMOTE_SSH_KEY=~/.ssh/id_rsa
RDOCKER_TCP_ENABLE=1
RDOCKER_TCP_PORT=12345
EOF
```

### Start rdocker tunnel

To start a `rdocker` tunnel to a remote Docker daemon, run the following command:

```bash
RDOCKER_CONTEXT=remote0 ./rdocker.sh tunnel-up

# Outputs:
#-----------------------
#* RDOCKER_CONTEXT: remote0
#* RDOCKER_REMOTE_HOST: remote0.example.com
#* RDOCKER_REMOTE_USER: ubuntu
#* RDOCKER_REMOTE_SOCKET: /var/run/docker.sock
#* RDOCKER_LOCAL_SOCKET: /tmp/rdocker-docker.remote0.sock
#* RDOCKER_HOST: unix:///tmp/rdocker-docker.remote0.sock
#-----------------------
#🔐 SSH tunnel established to remote0.example.com
#🛰️ Local socket: /tmp/rdocker-docker.remote0.sock
#🛰️ Local tcp proxy: localhost:12345
#🚀 -> DOCKER_HOST=unix:///tmp/rdocker-docker.remote0.sock
#🚀 -> DOCKER_HOST=tcp://localhost:12345
#Successfully created context "remote0"
#Successfully created context "remote0-tcp"
#🔥️ -> docker context use remote0
#🔥️ -> docker context use remote0-tcp
#Probing connection ...
#CONTAINER ID   IMAGE                 COMMAND                  CREATED       STATUS                 PORTS                                       NAMES
#Docker connection is working
#Press Ctrl+C to close tunnel and exit.

```

### Access the remote Docker daemon

From another terminal, you can now access the remote Docker daemon using either the `rdocker` or `docker` cli command:

#### Using rdocker

```bash
RDOCKER_CONTEXT=remote0 ./rdocker.sh ps
```

#### Using docker

```bash
DOCKER_HOST=unix:///tmp/rdocker-docker.remote0.sock docker ps
```

#### Using docker context

```bash
docker context use remote0
docker ps
```


### Start rdocker tunnel using Docker

The docker instances will expose the remote docker socket to the local machine via TCP. 
This allows you to run docker commands on the remote machine as if they were running locally.

```bash
docker run -it --rm \
  -v ~/.ssh:/home/rdocker/.ssh \
  -e RDOCKER_REMOTE_HOST=remote0.example.com \
  -e RDOCKER_REMOTE_USER=ubuntu \
  -p 12345:12345 \
  fmlabs/rdocker:latest
  
```


## Environment Variables

- `RDOCKER_CONTEXT`: Rdocker context. Required.
- `RDOCKER_REMOTE_HOST`: Remote host to connect to. Required.
- `RDOCKER_REMOTE_USER`: Remote user to connect to. Required.
- `RDOCKER_HOME`: Base directory for `rdocker` configurations. Default is `~/.rdocker`.
- `RDOCKER_DEBUG`: Enable debug mode. Default is `0`.
- `RDOCKER_TCP_ENABLE`: Enable TCP proxy for the tunneled docker socket. Default is `0`.
- `RDOCKER_TCP_PORT`: TCP port. Default is `12345`.




## Caveats

### Limited docker compose support

The `rdocker` script does not fully support `docker-compose` commands (yet).

Especially the `docker-compose up` command is tricky, when using 
file mounts, as the `docker-compose` command will try to mount the files
from the local machine to the remote machine, which will not work.

