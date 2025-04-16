**THE DOCUMENTATION IS UNDER CONSTRUCTION**

# Introduction to rdocker

`rdocker` is a simple, fast, stable and secure way to connect to remote Docker daemons.

## Features

- 🔐 **Secure**: Uses SSH to connect to remote Docker daemon.
- 🚀 **Fast**: Uses a permanent tunnel and the `docker` CLI to interact with the remote Docker daemon.
- 💪 **Resilient**: Automatically reconnects to the remote Docker daemon if the connection is lost.
- 🍳 **Simple**: Spin up a tunnel to the remote Docker daemon with a single command.
- 🪶 **Lightweight**: No need to install any additional software on the remote server.
- 📦 **Compact**: Only a few hundred lines of code. Docker image is less than 50MB.
- 💻 **Portable**: Can be run from any machine with SSH access to the remote server.
- ✅ **Easy to use**: Just use `rdocker` command instead of `docker` to interact with remote Docker daemon.


## How it works

Under the hood `rdocker` wraps `ssh`, `autossh`, `socat` and `docker` commands 
 to create a secure and stable tunnel to a remote Docker daemon.

`rdocker` forwards the remote docker daemon socket to a local socket via `ssh`
and (optionally) exposes the socket via a TCP proxy to the controlling host (localhost) via `socat`.
`autossh` is used to automatically reconnect to the remote Docker daemon if the connection is lost.

Additionally, `rdocker` automatically manages the corresponding `docker context` for you.

This allows you to use the `docker` CLI as if you were running it locally,
while actually running it on the remote machine.

