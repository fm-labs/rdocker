# Context

`rdocker` required a 'context' to be set up before it can be used.
It should not be confused with the Docker context, but rather a context for `rdocker` itself.
A Docker context (with the same context name) is automatically managed by `rdocker` for you.

The rdocker context is a set of parameters that define the connection to the remote Docker daemon.
Each context refers to a remote Docker daemon and is identified by a unique name.
The parameters are stored in a dotenv file in the `~/.rdocker` directory.

**Example context file:**

```
# Example context file
# ~/.rdocker/remote0.env
RDOCKER_CONTEXT=remote0
RDOCKER_REMOTE_HOST=remote0.example.com
RDOCKER_REMOTE_USER=ubuntu
RDOCKER_REMOTE_SSH_KEY=~/.ssh/remote0_rsa
RDOCKER_REMOTE_SSH_KEY_PASS_FILE=~/password-file-remote0.txt
RDOCKER_REMOTE_DOCKER_SOCKET=/var/run/docker.sock
RDOCKER_TCP_ENABLE=0
RDOCKER_TCP_PORT=12345
```


## Using rdocker with context

With the context file in place, you can now use `rdocker` to connect to the remote Docker daemon.
Just set the `RDOCKER_CONTEXT` environment variable to the name of the context you want to use.

For example, to start a tunnel to the remote Docker daemon defined in the `remote0` context,
run the following command:


```bash
RDOCKER_CONTEXT=remote0
rdocker tunnel-up
```

this can also be written as a one-liner:

```bash
RDOCKER_CONTEXT=remote0 rdocker tunnel-up
```
