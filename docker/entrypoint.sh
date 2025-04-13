#!/bin/bash
set -xe

echo "Entrypoint script for RDOCKER"

export RDOCKER_CONTEXT=${RDOCKER_CONTEXT:-default}
export RDOCKER_LOCAL_SOCKET=${RDOCKER_LOCAL_SOCKET:-/rdocker/run/rdocker.sock}
export RDOCKER_TCP_ENABLE=${RDOCKER_TCP_ENABLE:-1}
export RDOCKER_TCP_PORT=${RDOCKER_TCP_PORT:-12345}

exec "$@"
