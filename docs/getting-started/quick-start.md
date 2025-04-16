# Quick Start

## Prerequisites

- 💻 Local machine
    - ✅ Docker CLI installed on your local machine.
    - ✅ SSH client installed on your local machine.
    - ✅ SSH access to the remote server.
- 🌐 Remote server
    - ✅ Docker Engine installed on the remote server.
    - ✅ SSH server installed on the remote server.

## Create a rdocker configuration

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

## Start rdocker tunnel

To start a `rdocker` tunnel to a remote Docker daemon, run the following command:

```bash
RDOCKER_CONTEXT=remote0 ./rdocker tunnel-up

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

## Access the remote Docker daemon

From another terminal, you can now access the remote Docker daemon using either the `rdocker` or `docker` cli command:

## Using rdocker

```bash
RDOCKER_CONTEXT=remote0 ./rdocker ps
```

## Using docker

```bash
DOCKER_HOST=unix:///tmp/rdocker-docker.remote0.sock docker ps
```

## Using docker context

```bash
docker context use remote0
docker ps
```