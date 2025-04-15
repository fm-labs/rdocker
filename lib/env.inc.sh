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
