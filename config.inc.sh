#!/bin/bash

source ./util.inc.sh

if [ -z "$RDOCKER_HOME" ]; then
  RDOCKER_HOME=$(dirname $(readlink -f $0))
fi
echolog "[config] RDOCKER_HOME: $RDOCKER_HOME"

mkdir -p $RDOCKER_HOME/hosts
echolog "[config] Setup directory $RDOCKER_HOME/hosts"

DOCKER_BIN=$(which docker)
if [ -z "$DOCKER_BIN" ]; then
  echoerr "[config] Docker is not installed. Exiting"
  exit 1
fi

SSH_BIN=$(which ssh)
if [ -z "$SSH_BIN" ]; then
  echoerr "SSH is not installed. Exiting"
  exit 1
fi
# todo check if openssh version is >6.7


#OPENSSL_BIN=$(which openssl)
#if [ -z "$OPENSSL_BIN" ]; then
#  echoerr "[config] OpenSSL is not installed. Exiting"
#  exit 1
#fi

#RSYNC_BIN=$(which rsync)
#if [ -z "$RSYNC_BIN" ]; then
#  echoerr "[config] Rsync is not installed. Exiting"
#  exit 1
#fi

#echolog "[config] SSH_BIN=$SSH_BIN"
#echolog "[config] DOCKER_BIN=$DOCKER_BIN"
#echolog "[config] OPENSSL_BIN=$OPENSSL_BIN"
#echolog "[config] RSYNC_BIN=$RSYNC_BIN"
echolog "[config] All required binaries are installed"


