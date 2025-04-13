# rdocker

Simple, fast, and secure way to connect to your remote Docker daemon.

## Features

- **Secure**: Uses SSH to connect to remote Docker daemon.
- **Fast**: Uses `docker` CLI to interact with the remote Docker daemon.
- **Simple**: Just run `rdocker` and it will automatically connect to the remote Docker daemon.
- **Lightweight**: No need to install any additional software on the remote server.
- **Cross-platform**: Works on Linux, macOS, and Windows.
- **Easy to use**: Just use `rdocker` command instead of `docker` to interact with remote Docker daemon.



## Quick Start

To create a rdocker tunnel to a remote Docker daemon, 
run the following command:

(of course, you need to add your server IP address and username, and you need to have SSH access to the server)

```bash
docker run -it --rm \
  -v ~/.ssh:/home/rdocker/.ssh \
  -e RDOCKER_REMOTE_HOST=remote0.example.com \
  -e RDOCKER_REMOTE_USER=ubuntu \
  fmlabs/rdocker:latest
```


## Environment Variables

- `RDOCKER_HOME`: Base directory for `rdocker` configuration. Default is `~/.rdocker`.
- `RDOCKER_DEBUG`: Enable debug mode. Default is `0`.
