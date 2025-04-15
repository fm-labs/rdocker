# Project: RDOCKER
# File: lib/config.inc.sh
# This include script sets up the environment for the RDOCKER project.
# It checks if the required binaries are installed and sets up the environment variables.
RDOCKER_LOGPREFIX="[config] "


DOCKER_BIN=${DOCKER_BIN:-$(which docker)}
if [ -z "$DOCKER_BIN" ]; then
  echoerr "Docker is not installed. Exiting"
  exit 1
fi

SSH_BIN=${SSH_BIN:-$(which ssh)}
if [ -z "$SSH_BIN" ]; then
  echoerr "SSH is not installed. Exiting"
  exit 1
fi
# todo check if openssh version is >6.7

AUTOSSH_BIN=${AUTOSSH_BIN:-$(which autossh)}
if [ -z "$AUTOSSH_BIN" ]; then
  echoerr "Autossh is not installed. Exiting"
  exit 1
fi

SOCAT_BIN=${SOCAT_BIN:-$(which socat)}
if [ -z "$SOCAT_BIN" ]; then
  echoerr "Socat is not installed. Exiting"
  exit 1
fi

OPENSSL_BIN=${OPENSSL_BIN:-$(which openssl)}
#if [ -z "$OPENSSL_BIN" ]; then
#  echoerr "OpenSSL is not installed. Exiting"
#  exit 1
#fi

RSYNC_BIN=${RSYNC_BIN:-$(which rsync)}
#if [ -z "$RSYNC_BIN" ]; then
#  echoerr "Rsync is not installed. Exiting"
#  exit 1
#fi

echolog "SSH_BIN=$SSH_BIN"
echolog "AUTOSSH_BIN=$AUTOSSH_BIN"
echolog "DOCKER_BIN=$DOCKER_BIN"
echolog "SOCAT_BIN=$SOCAT_BIN"
echolog "OPENSSL_BIN=$OPENSSL_BIN"
echolog "RSYNC_BIN=$RSYNC_BIN"
echolog "All required binaries are installed"


