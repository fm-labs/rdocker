#!/bin/bash

# set -xe

source ./util.inc.sh
source ./config.inc.sh
source ./env.inc.sh

echolog "SSH_BIN=$SSH_BIN"
echolog "DOCKER_BIN=$DOCKER_BIN"
echolog "OPENSSL_BIN=$OPENSSL_BIN"
echolog "RSYNC_BIN=$RSYNC_BIN"


if [ -z "$RDOCKER_CONTEXT" ]; then
  echoerr "RDOCKER_CONTEXT not set. Exiting"
  exit 1
fi

#RDOCKER_LOCAL_TMPDIR=$(mktemp -d /tmp/rdocker.${RDOCKER_CONTEXT}.XXXXXX)
#RDOCKER_LOCAL_TMPDIR="/tmp/rdocker.${RDOCKER_CONTEXT}"
#RDOCKER_LOCAL_SOCKET=${RDOCKER_LOCAL_TMPDIR}/rdocker-docker.sock
#RDOCKER_TUNNEL_PID_FILE=${RDOCKER_LOCAL_TMPDIR}/rdocker-ssh-tunnel.pid

RDOCKER_LOCAL_TMPDIR=${RDOCKER_LOCAL_TMPDIR:-/tmp}
RDOCKER_LOCAL_SOCKET=${RDOCKER_LOCAL_TMPDIR}/rdocker-docker.${RDOCKER_CONTEXT}.sock
RDOCKER_TUNNEL_PID_FILE=${RDOCKER_LOCAL_TMPDIR}/rdocker-ssh-tunnel.${RDOCKER_CONTEXT}.pid

RDOCKER_HOST=unix://${RDOCKER_LOCAL_SOCKET}
RDOCKER_REMOTE_SOCKET=${RDOCKER_REMOTE_SOCKET:-/var/run/docker.sock}

skip_cleanup=0

function setup_autossh_tunnel() {
  if [ -z "$RDOCKER_REMOTE_HOST" ]; then
    echoerr "RDOCKER_REMOTE_HOST not defined. Exiting"
    exit 1
  fi

  if [ -z "$RDOCKER_REMOTE_USER" ]; then
    echoerr "RDOCKER_REMOTE_USER not defined. Exiting"
    exit 1
  fi

  mkdir -p $RDOCKER_LOCAL_TMPDIR

  if [ -f $RDOCKER_TUNNEL_PID_FILE ]; then
    SSH_PID=$(cat $RDOCKER_TUNNEL_PID_FILE)
    if ps -p $SSH_PID > /dev/null; then
      echolog "SSH tunnel already up. PID: $SSH_PID"
      skip_cleanup=1
      return 0
    fi
  fi

  echolog "Setting up autossh tunnel to ${RDOCKER_REMOTE_HOST}"

  #export AUTOSSH_PIDFILE=${RDOCKER_TUNNEL_PID_FILE}
  autossh $SSH_ARGS -M 0 -N \
    -L "${RDOCKER_LOCAL_SOCKET}:${RDOCKER_REMOTE_SOCKET}" \
    -o ExitOnForwardFailure=yes \
    "${RDOCKER_REMOTE_USER}@${RDOCKER_REMOTE_HOST}" &

  SSH_PID=$!
  echolog "SSH PID: $SSH_PID"
  # check if SSH_PID is running
  if ! ps -p $SSH_PID > /dev/null; then
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

  mkdir -p $RDOCKER_LOCAL_TMPDIR

  if [ -f $RDOCKER_TUNNEL_PID_FILE ]; then
    SSH_PID=$(cat $RDOCKER_TUNNEL_PID_FILE)
    if ps -p $SSH_PID > /dev/null; then
      echolog "SSH tunnel already up. PID: $SSH_PID"
      skip_cleanup=1
      exit 0
    fi
  fi

  echolog "Setting up tunnel to ${RDOCKER_REMOTE_HOST}"

  ssh $SSH_ARGS -N \
    -L "${RDOCKER_LOCAL_SOCKET}:${RDOCKER_REMOTE_SOCKET}" \
    -o ExitOnForwardFailure=yes \
    "${RDOCKER_REMOTE_USER}@${RDOCKER_REMOTE_HOST}" &

  SSH_PID=$!
  echolog "SSH PID: $SSH_PID"
  # check if SSH_PID is running
  #if ! ps -p $SSH_PID > /dev/null; then
  if ! kill -0 "$SSH_PID" 2>/dev/null; then
    echoerr "SSH tunnel failed to start. Exiting"
    exit 1
  fi
  echo $SSH_PID > "$RDOCKER_TUNNEL_PID_FILE"
  echolog "Tunnel started. PID: $(cat $RDOCKER_TUNNEL_PID_FILE)"
}

function cleanup_tunnel() {
  echolog "Cleaning up tunnel"
  if [ -f $RDOCKER_TUNNEL_PID_FILE ]; then
    SSH_PID=$(cat $RDOCKER_TUNNEL_PID_FILE)
    echolog "Killing SSH PID: $SSH_PID"
    kill $SSH_PID # > /dev/null # &
    if [ $? -ne 0 ]; then
      echoerr "Failed to kill SSH tunnel. PID: $SSH_PID. Trying harder ..."
      kill -9 $SSH_PID
    fi
    rm -f $RDOCKER_TUNNEL_PID_FILE
    rm -f $RDOCKER_LOCAL_SOCKET
    echolog "Tunnel cleanup complete"
  fi
}

function cleanup() {
  echolog "Rdocker is exiting gracefully."

  if [ $skip_cleanup -eq 1 ]; then
    echolog "Skipping cleanup"
    return
  fi
  cleanup_tunnel
}

function print_context() {
  echolog "RDOCKER_CONTEXT: $RDOCKER_CONTEXT"
  echolog "RDOCKER_HOST: $RDOCKER_HOST"
  echolog "RDOCKER_TUNNEL $RDOCKER_TUNNEL"
  echolog "RDOCKER_REMOTE_HOST: $RDOCKER_REMOTE_HOST"
  echolog "RDOCKER_REMOTE_USER: $RDOCKER_REMOTE_USER"
}

# cleanup on exit
trap cleanup EXIT


CMD=$1
echolog "CMD: $CMD"

case $CMD in
  "info")
    print_context
    exit 0
  ;;

  "ssh-probe")
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

    echo "[${RDOCKER_CONTEXT}] 🚀 SSH tunnel established"
    echo "[${RDOCKER_CONTEXT}] 🔥 Use ${RDOCKER_HOST} as your DOCKER_HOST"
    #echo ""
    #echo "Example:"
    #echo "DOCKER_HOST=${RDOCKER_HOST} docker ps"
    #echo ""
    echo "Press Ctrl+C to exit."

    # loop forever until someone kills the script
    while true; do
      sleep 1
      if [ -f $RDOCKER_TUNNEL_PID_FILE ]; then
        SSH_PID=$(cat $RDOCKER_TUNNEL_PID_FILE)
        if ! ps -p $SSH_PID > /dev/null; then
          echoerr "SSH tunnel process with PID $PID vanished. Exiting"
          exit 91
        fi
      else
        echoerr "SSH tunnel PID file vanished. Exiting"
        exit 92
      fi
    done

    exit 0
  ;;

  "tunnel-down")
    cleanup_tunnel
    echo "[${RDOCKER_CONTEXT}] 🚀 SSH tunnel closed"
    exit 0
  ;;

  *)
    # By default, we assume the command is a docker command
    # and we need to setup the tunnel first.

    #setup_tunnel
    setup_autossh_tunnel

    export DOCKER_HOST=$RDOCKER_HOST
    echolog "DOCKER_HOST=$DOCKER_HOST"

    DOCKER_CMD="$@"
    echolog "DOCKER_CMD: $DOCKER_CMD"
    sleep 1

    $DOCKER_BIN $DOCKER_CMD
    RC=$?
    if [ $RC -ne 0 ]; then
      echoerr "Docker command failed. Exiting"
      exit 1
    fi
    exit $RC
  ;;

esac
