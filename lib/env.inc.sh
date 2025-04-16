#!/bin/bash
# Project: RDOCKER
# File: lib/env.inc.sh
# This script sets up the environment for the RDOCKER project.
# - It loads the environment variables from the specified context.
# - It checks if the required environment variables are set.
# -- RDOCKER_CONTEXT is the context name.
# -- RDOCKER_HOME is the home directory of the RDOCKER configurations. Default is ~/.rdocker.
# -- RDOCKER_REMOTE_HOST is the remote host.
# -- RDOCKER_REMOTE_USER is the remote user.
# -- RDOCKER_REMOTE_SSH_KEY is the SSH key for the remote host.
# -- RDOCKER_LOCAL_SOCKET is the local socket. Automatically created if not set.
# -- RDOCKER_TCP_ENABLE is the TCP enable flag. Default is 1.
# -- RDOCKER_TCP_PORT is the TCP port. Default is 12345.
# -- RDOCKER_DEBUG is the debug flag. Default is 0.

RDOCKER_LOGPREFIX="[env] "

# check that RDOCKER_CONTEXT is set,
# and is not "default" or starts with "desktop-"
# to avoid conflicts with Docker Desktop contexts
if [ -z "$RDOCKER_CONTEXT" ]; then
  echoerr "RDOCKER_CONTEXT not set. Exiting"
  exit 1
elif [ "$RDOCKER_CONTEXT" = "default" ]; then
  echoerr "RDOCKER_CONTEXT cannot be 'default'. Exiting"
  exit 1
elif [[ "$RDOCKER_CONTEXT" == desktop-* ]]; then
  echoerr "RDOCKER_CONTEXT cannot start with 'desktop-'. Exiting"
  exit 1
fi
echolog "RDOCKER_CONTEXT: $RDOCKER_CONTEXT"

if [ -z "$RDOCKER_HOME" ]; then
  #echoerr "RDOCKER_HOME not set. Exiting"
  #exit 1
  RDOCKER_HOME="$HOME/.rdocker"
fi
echolog "RDOCKER_HOME: $RDOCKER_HOME"
mkdir -p $RDOCKER_HOME

# Load env variables from the specified environment file
RDOCKER_CONTEXTFILE="${RDOCKER_HOME}/${RDOCKER_CONTEXT}.env"
if [ -f ${RDOCKER_CONTEXTFILE} ]; then
  source ${RDOCKER_CONTEXTFILE}
else
  echoerr "WARN: File ${RDOCKER_CONTEXTFILE} not found."
  source ${RDOCKER_CONTEXTFILE}
  #exit 1
fi

# Check if the required environment variables are set
if [ -z "$RDOCKER_REMOTE_HOST" ]; then
  echoerr "RDOCKER_REMOTE_HOST not defined. Exiting"
  exit 1
fi
if [ -z "$RDOCKER_REMOTE_USER" ]; then
  echoerr "RDOCKER_REMOTE_USER not defined. Exiting"
  exit 1
fi

###############################################################

# INTERNAL VARIABLES
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


# SSH
RDOCKER_REMOTE_SSH_KEY=${RDOCKER_REMOTE_SSH_KEY:-}
RDOCKER_REMOTE_SSH_KEY_PASS=${RDOCKER_REMOTE_SSH_KEY_PASS:-}
RDOCKER_REMOTE_SSH_KEY_PASS_FILE=${RDOCKER_REMOTE_SSH_KEY_PASS_FILE:-}
if [ -z "$RDOCKER_REMOTE_SSH_KEY" ]; then
  if [ -f "${RDOCKER_HOME}/${RDOCKER_CONTEXT}.key" ]; then
    RDOCKER_REMOTE_SSH_KEY="${RDOCKER_HOME}/${RDOCKER_CONTEXT}.key"

    # check corresponding passphrase file
    if [ -f "${RDOCKER_HOME}/${RDOCKER_CONTEXT}.key.pass" ]; then
      RDOCKER_REMOTE_SSH_KEY_PASS_FILE="${RDOCKER_HOME}/${RDOCKER_CONTEXT}.key.pass"
    fi
  fi
fi

# read the passphrase from the file, if set
if [ -n "$RDOCKER_REMOTE_SSH_KEY_PASS_FILE" ]; then
  if [ -f "$RDOCKER_REMOTE_SSH_KEY_PASS_FILE" ]; then
    RDOCKER_REMOTE_SSH_KEY_PASS=$(cat $RDOCKER_REMOTE_SSH_KEY_PASS_FILE)
  else
    echoerr "SSH key passphrase file not found: $RDOCKER_REMOTE_SSH_KEY_PASS_FILE"
    exit 1
  fi
fi
echolog "RDOCKER_REMOTE_SSH_KEY: $RDOCKER_REMOTE_SSH_KEY"
echolog "RDOCKER_REMOTE_SSH_KEY_PASS_FILE: $RDOCKER_REMOTE_SSH_KEY_PASS_FILE"
#echolog "RDOCKER_REMOTE_SSH_KEY_PASS: $RDOCKER_REMOTE_SSH_KEY_PASS"

# TCP Proxy
RDOCKER_TCP_ENABLE=${RDOCKER_TCP_ENABLE:-0}
RDOCKER_TCP_PORT=${RDOCKER_TCP_PORT:-12345}
