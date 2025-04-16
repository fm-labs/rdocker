#!/bin/bash
set -e

echo "Entrypoint script for RDOCKER"

WHOAMI=$(whoami)
echo "Running as user: $WHOAMI"

#export RDOCKER_CONTEXT=${RDOCKER_CONTEXT:-}
#export RDOCKER_HOME=${RDOCKER_HOME:-/rdocker/.rdocker}
#export RDOCKER_LOCAL_SOCKET=${RDOCKER_LOCAL_SOCKET:-/tmp/rdocker.sock}
#export RDOCKER_TCP_ENABLE=${RDOCKER_TCP_ENABLE:-1}
#export RDOCKER_TCP_PORT=${RDOCKER_TCP_PORT:-12345}

CMD=$1

case $CMD in
  "rdocker")
    shift
    #exec /usr/local/bin/rdocker "$@"
    exec /rdocker/bin/rdocker "$@"
    ;;
  #"rdocker-socket-proxy")
  #  shift
  #  exec /usr/local/bin/rdocker-socket-proxy "$@"
  #  ;;
  #"rdocker-tcp-proxy")
  #  shift
  #  exec /usr/local/bin/rdocker-tcp-proxy "$@"
  #  ;;
  *)
    # All other commands
    exec "$@"
    ;;
esac

