#!/bin/bash
####################################################################
# rdocker - Remote Docker CLI
####################################################################
# set -xe
RDOCKER_LOGPREFIX="[rdocker] "

# get the directory of the script
script_dir=$(dirname $(readlink -f $0))
# load the utils
source $script_dir/../lib/util.inc.sh
# check the required binaries
source $script_dir/../lib/config.inc.sh
# load the environment variables
source $script_dir/../lib/env.inc.sh

# check the context and setup the environment
if [ -z "$RDOCKER_CONTEXT" ]; then
  echoerr "RDOCKER_CONTEXT not set. Exiting"
  exit 1
fi
# set the log prefix to the context
RDOCKER_LOGPREFIX="[${RDOCKER_CONTEXT}] "
# the docker socket on the remote host
RDOCKER_REMOTE_SOCKET=${RDOCKER_REMOTE_SOCKET:-/var/run/docker.sock}
# the tmp directory on the local host
RDOCKER_LOCAL_TMPDIR=${RDOCKER_LOCAL_TMPDIR:-/tmp}
# the docker socket on the local host
RDOCKER_LOCAL_SOCKET=${RDOCKER_LOCAL_SOCKET:-}
if [ -z "$RDOCKER_LOCAL_SOCKET" ]; then
  RDOCKER_LOCAL_SOCKET=${RDOCKER_LOCAL_TMPDIR}/rdocker-docker.${RDOCKER_CONTEXT}.sock
fi
# the (R)DOCKER_HOST value used to connect to the remote host via the tunnel
RDOCKER_HOST=unix://${RDOCKER_LOCAL_SOCKET}
# the (Auto)SSH tunnel PID file
RDOCKER_TUNNEL_PID_FILE=${RDOCKER_LOCAL_TMPDIR}/rdocker-ssh-tunnel.${RDOCKER_CONTEXT}.pid
RDOCKER_SOCAT_PID_FILE=${RDOCKER_LOCAL_TMPDIR}/rdocker-socat.${RDOCKER_CONTEXT}.pid
# local variable to skip auto-cleanup of the tunnel
skip_cleanup=0

RDOCKER_REMOTE_SSH_KEY=${RDOCKER_REMOTE_SSH_KEY:-}
if [ -z "$RDOCKER_REMOTE_SSH_KEY" ]; then
  if [ -f "${RDOCKER_HOME}/${RDOCKER_CONTEXT}.key" ]; then
    RDOCKER_REMOTE_SSH_KEY="${RDOCKER_HOME}/${RDOCKER_CONTEXT}.key"
  fi
fi

# ssh arguments
SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ExitOnForwardFailure=yes"
AUTOSSH_ARGS=""
# check if the SSH key is set
if [ -n "$RDOCKER_REMOTE_SSH_KEY" ]; then
  if [ -f "$RDOCKER_REMOTE_SSH_KEY" ]; then
    SSH_ARGS="$SSH_ARGS -i $RDOCKER_REMOTE_SSH_KEY"
    #AUTOSSH_ARGS="$AUTOSSH_ARGS -i $RDOCKER_REMOTE_SSH_KEY"
  else
    echoerr "SSH key file not found: $RDOCKER_REMOTE_SSH_KEY"
    #exit 1
  fi
fi
#echolog "SSH_ARGS: $SSH_ARGS"
#echolog "SSH_AUTH_SOCK: $SSH_AUTH_SOCK"

# runtime
mkdir -p $RDOCKER_LOCAL_TMPDIR
SSH_PID=
SOCAT_PID=


function setup_autossh_tunnel() {
  if [ -z "$RDOCKER_REMOTE_HOST" ]; then
    echoerr "RDOCKER_REMOTE_HOST not defined. Exiting"
    exit 1
  fi

  if [ -z "$RDOCKER_REMOTE_USER" ]; then
    echoerr "RDOCKER_REMOTE_USER not defined. Exiting"
    exit 1
  fi

  # check if a tunnel is already running
  if [ -f $RDOCKER_TUNNEL_PID_FILE ]; then
    SSH_PID=$(cat $RDOCKER_TUNNEL_PID_FILE)
    if kill -0 "$SSH_PID" 2>/dev/null; then
      echoerr "SSH tunnel already up. PID: $SSH_PID"
      skip_cleanup=1
      #return 0
      exit 0
    fi
  fi

  echolog "Setting up autossh tunnel to ${RDOCKER_REMOTE_HOST}"
  #export AUTOSSH_PIDFILE=${RDOCKER_TUNNEL_PID_FILE}
  $AUTOSSH_BIN -M 0 -N \
    -L "${RDOCKER_LOCAL_SOCKET}:${RDOCKER_REMOTE_SOCKET}" \
    $SSH_ARGS \
    "${RDOCKER_REMOTE_USER}@${RDOCKER_REMOTE_HOST}" &

  SSH_PID=$!
  echolog "SSH PID: $SSH_PID"

  # check if the autossh process is running
  if ! kill -0 "$SSH_PID" 2>/dev/null; then
    echoerr "SSH tunnel failed to start. Exiting"
    exit 1
  fi
  echo $SSH_PID > "$RDOCKER_TUNNEL_PID_FILE"
  echolog "Tunnel started. PID: $(cat $RDOCKER_TUNNEL_PID_FILE)"
}

function setup_tunnel() {
  if [ -z "$RDOCKER_REMOTE_HOST" ]; then
    echoerr "RDOCKER_REMOTE_HOST not defined. Exiting"
    exit 1
  fi

  if [ -z "$RDOCKER_REMOTE_USER" ]; then
    echoerr "RDOCKER_REMOTE_USER not defined. Exiting"
    exit 1
  fi

  # check if a tunnel is already running
  if [ -f $RDOCKER_TUNNEL_PID_FILE ]; then
    SSH_PID=$(cat $RDOCKER_TUNNEL_PID_FILE)
    if kill -0 "$SSH_PID" 2>/dev/null; then
      echolog "SSH tunnel already up. PID: $SSH_PID"
      skip_cleanup=1
      exit 0
    fi
  fi

  echolog "Setting up tunnel to ${RDOCKER_REMOTE_HOST}"
  $SSH_BIN -N \
    -L "${RDOCKER_LOCAL_SOCKET}:${RDOCKER_REMOTE_SOCKET}" \
    $SSH_ARGS \
    "${RDOCKER_REMOTE_USER}@${RDOCKER_REMOTE_HOST}" &

  SSH_PID=$!
  echolog "SSH PID: $SSH_PID"

  # make sure the SSH tunnel is running
  if ! kill -0 "$SSH_PID" 2>/dev/null; then
    echoerr "SSH tunnel failed to start. Exiting"
    exit 1
  fi
  echo $SSH_PID > "$RDOCKER_TUNNEL_PID_FILE"
  echolog "Tunnel started. PID: $(cat $RDOCKER_TUNNEL_PID_FILE)"
}

function cleanup_tunnel() {
  echolog "Cleaning up tunnel"

  echolog "Killing socat PID: $SOCAT_PID"
  if [ -n "$SOCAT_PID" ]; then
    kill_process $SOCAT_PID
  fi

  if [ -f $RDOCKER_TUNNEL_PID_FILE ]; then
    SSH_PID=$(cat $RDOCKER_TUNNEL_PID_FILE)
    echolog "Killing SSH PID: $SSH_PID"
    kill_process $SSH_PID

    rm -f $RDOCKER_TUNNEL_PID_FILE
    rm -f $RDOCKER_SOCAT_PID_FILE
    rm -f $RDOCKER_LOCAL_SOCKET
    echolog "Tunnel cleanup complete"
  fi
}

function setup_docker_context() {
  local context_name=$1
  local host=$2

  echolog "Setting up docker context for ${context_name} with host ${host}"
  if [ -z "${context_name}" ]; then
    echoerr "context_name not defined. Exiting"
    return 1
  fi
  if [ -z "$host" ]; then
    echoerr "host not defined. Exiting"
    return 1
  fi

  # remove existing context, if any
  $DOCKER_BIN context rm ${context_name} 2>/dev/null

  # create the docker context
  $DOCKER_BIN context create ${context_name} \
    --docker "host=${host}" \
    --description "Rdocker context for ${context_name}" > /dev/null

  echolog "Created docker context: ${context_name}"
}

function cleanup_docker_context() {
  local context_name=$1
  echolog "Cleaning up docker context ${context_name}"
  if [ -n "${context_name}" ]; then
    $DOCKER_BIN context rm ${context_name} >/dev/null
    if [ $? -ne 0 ]; then
      echoerr "Failed to remove docker context: ${context_name}. Trying harder ..."
      $DOCKER_BIN context rm ${context_name} --force >/dev/null
    fi
  fi
}

function cleanup() {
  echolog "Rdocker is exiting gracefully."

  if [ $skip_cleanup -eq 1 ]; then
    echolog "Skipping cleanup"
    return
  fi

  cleanup_tunnel

  echolog "Reset docker context to default"
  $DOCKER_BIN context use default > /dev/null
  echolog "Cleaning up docker context"
  cleanup_docker_context "${RDOCKER_CONTEXT}"
  cleanup_docker_context "${RDOCKER_CONTEXT}-tcp"
}

function print_context() {
  echo "-----------------------"
  echo "* RDOCKER_CONTEXT: $RDOCKER_CONTEXT"
  echo "* RDOCKER_REMOTE_HOST: $RDOCKER_REMOTE_HOST"
  echo "* RDOCKER_REMOTE_USER: $RDOCKER_REMOTE_USER"
  echo "* RDOCKER_REMOTE_SOCKET: $RDOCKER_REMOTE_SOCKET"
  echo "* RDOCKER_LOCAL_SOCKET: $RDOCKER_LOCAL_SOCKET"
  echo "* RDOCKER_HOST: $RDOCKER_HOST"
  echo "-----------------------"
}

function setup_socat_proxy() {
    # now we use socat to forward the local TCP port to the tunneled docker socket
    # this enabled us to access the tunneled remote docker socket via TCP
    RDOCKER_TCP_PORT=${RDOCKER_TCP_PORT:-12345}
    RDOCKER_SOCAT_DEBUG=${RDOCKER_SOCAT_DEBUG:-0}
    echolog "Starting socat to forward tcp:${RDOCKER_TCP_PORT} to ${RDOCKER_LOCAL_SOCKET}"
    SOCAT_ARGS=""
    if [ $RDOCKER_SOCAT_DEBUG -eq 1 ]; then
      SOCAT_ARGS="-v -d -d"
    fi
    $SOCAT_BIN $SOCAT_ARGS \
      TCP-LISTEN:${RDOCKER_TCP_PORT},reuseaddr,fork \
      UNIX-CONNECT:${RDOCKER_LOCAL_SOCKET} &
    SOCAT_PID=$!
    echolog "SOCAT_PID: $SOCAT_PID"
    echolog $SOCAT_PID > "${RDOCKER_SOCAT_PID_FILE}"
    echo "-> DOCKER_HOST=tcp://localhost:${RDOCKER_TCP_PORT}"
}

function get_docker_info() {
  # get the docker info
  $DOCKER_BIN info
  if [ $? -ne 0 ]; then
    echoerr "Failed to get docker info"
    return 1
  fi
}

function get_docker_version() {
  # get the docker version
  $DOCKER_BIN version
  if [ $? -ne 0 ]; then
    echoerr "Failed to get docker version"
    return 1
  fi
}


# cleanup on exit
trap cleanup EXIT

# process the command line arguments
CMD=$1
echolog "CMD: $CMD"
case $CMD in
  "rdocker")
    skip_cleanup=1
    print_context
    exit 0
  ;;

  "ssh-probe")
    skip_cleanup=1
    if [ -z "$RDOCKER_REMOTE_HOST" ]; then
      echoerr "RDOCKER_REMOTE_HOST not defined. Exiting"
      exit 1
    fi

    if [ -z "$RDOCKER_REMOTE_USER" ]; then
      echoerr "RDOCKER_REMOTE_USER not defined. Exiting"
      exit 1
    fi
    set -xe
    ssh $SSH_ARGS -t $RDOCKER_REMOTE_USER@$RDOCKER_REMOTE_HOST "whoami"
    if [ $? -ne 0 ]; then
      echoerr "SSH tunnel failed. Exiting"
      exit 1
    fi

    ssh -t $RDOCKER_REMOTE_USER@$RDOCKER_REMOTE_HOST << EOF
      set -xe
      echo "Hello from the remote server"
      XID=\$(id)
      echo "XID: \$XID"
      XDOCKER_BIN=\$(which docker)
      echo "The remote docker binary is: \$XDOCKER_BIN"
EOF
    if [ $? -ne 0 ]; then
      echoerr "SSH tunnel failed. Exiting"
      exit 1
    fi
    exit 0
  ;;

  "tunnel-up")
    print_context
    #setup_tunnel
    setup_autossh_tunnel
    setup_docker_context "${RDOCKER_CONTEXT}" "unix://${RDOCKER_LOCAL_SOCKET}"

    echo "🔐 SSH tunnel established to ${RDOCKER_REMOTE_HOST}"
    echo "🚀️ Local socket: ${RDOCKER_LOCAL_SOCKET}"
    echo "-> DOCKER_HOST=${RDOCKER_HOST}"

    setup_socat_proxy
    setup_docker_context "${RDOCKER_CONTEXT}-tcp" "tcp://localhost:${RDOCKER_TCP_PORT}"

    # set the docker context to the new context
    #$DOCKER_BIN context use "${RDOCKER_CONTEXT}"
    export DOCKER_HOST=$RDOCKER_HOST
    echo "Probing connection ..."
    sleep 1
    if $DOCKER_BIN version ; then
      echo "✅ Docker connection is working"
    else
      echoerr "❌ Docker connection probe failed"
      #exit 1
    fi

    # loop forever until someone kills the script
    sleep 1
    echo "Press Ctrl+C to close tunnel and exit."
    while true; do
      sleep 3
      if [ -f $RDOCKER_TUNNEL_PID_FILE ]; then
        SSH_PID=$(cat $RDOCKER_TUNNEL_PID_FILE)
        if ! kill -0 "$SSH_PID" 2>/dev/null; then
          echoerr "SSH tunnel process with PID $PID vanished. Exiting"
          exit 91
        fi
      else
        echoerr "SSH tunnel PID file vanished. Exiting"
        exit 92
      fi

      #clear
      #$DOCKER_BIN ps
      #echo "Press Ctrl+C to exit."
    done
    exit 0
  ;;

  "tunnel-down")
    cleanup_tunnel
    echo "✅ SSH tunnel closed"
    skip_cleanup=1 # already cleaned up
    exit 0
  ;;

  *)
    # By default, we assume the command is a docker command
    # and we need to setup the tunnel first.
    # The trap will cleanup the tunnel on exit.

    #setup_tunnel
    setup_autossh_tunnel

    export DOCKER_HOST=${RDOCKER_HOST}
    echolog "DOCKER_HOST=$DOCKER_HOST"

    DOCKER_CMD="$@"
    echolog "DOCKER_CMD: $DOCKER_CMD"

    # we explicitly do NOT use 'exec' 'here, because we want to catch the exit code
    # and cleanup the tunnel
    # NO: exec $DOCKER_BIN $DOCKER_CMD

    $DOCKER_BIN $DOCKER_CMD
    RC=$?
    if [ $RC -ne 0 ]; then
      echoerr "Docker command failed with exit code: $RC"
    fi
    exit $RC
  ;;

esac
