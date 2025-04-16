#!/bin/bash
set -eux

echo "Entrypoint script for RDOCKER"

WHOAMI=$(whoami)
echo "Running as user: $WHOAMI"

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

