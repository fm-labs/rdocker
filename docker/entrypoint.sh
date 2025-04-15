#!/bin/bash
set -xe

echo "Entrypoint script for RDOCKER"

export RDOCKER_CONTEXT=${RDOCKER_CONTEXT:-}
export RDOCKER_HOME=${RDOCKER_HOME:-/.rdocker}
export RDOCKER_LOCAL_SOCKET=${RDOCKER_LOCAL_SOCKET:-/rdocker/run/rdocker.sock}
export RDOCKER_TCP_ENABLE=${RDOCKER_TCP_ENABLE:-1}
export RDOCKER_TCP_PORT=${RDOCKER_TCP_PORT:-12345}

CMD=$1

case $CMD in
  "rdocker")
    shift
    #exec /usr/local/bin/rdocker "$@"
    exec /rdocker/bin/rdocker.sh "$@"
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

