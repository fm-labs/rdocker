#!/bin/bash

exec /rdocker/bin/rdocker tunnel-check "$@"

#RDOCKER_DEBUG=${RDOCKER_DEBUG:-0}
#if [ $RDOCKER_DEBUG -eq 2 ]; then
#  set -x
#fi
#
#source /rdocker/lib/util.inc.sh
#source /rdocker/lib/config.inc.sh
#source /rdocker/lib/env.inc.sh
#
#
## Function to check if the SSH tunnel is up
#check_ssh_tunnel() {
#  echo "Checking SSH tunnel..."
#
#  if [ -z "$RDOCKER_TUNNEL_PID_FILE" ]; then
#    echo "SSH tunnel PID file not set. Exiting"
#    return 1
#  fi
#
#  if check_process_by_pidfile $RDOCKER_TUNNEL_PID_FILE ; then
#    echo "SSH tunnel is up (PID file exists and process found)"
#    return 0
#  else
#    echo "SSH tunnel is down (PID file not found)"
#    return 1
#  fi
#}
#
#check_docker_tcpproxy() {
#  echo "Checking docker TCP proxy..."
#
#  if [ "$RDOCKER_TCP_ENABLE" != "1" ]; then
#    echo "TCP proxy is disabled. Skipping check."
#    return 0
#  fi
#
#  if [ -z "$RDOCKER_SOCAT_PID_FILE" ]; then
#    echo "Tcp proxy PID file not set. Exiting"
#    return 1
#  fi
#
#  if check_process_by_pidfile $RDOCKER_SOCAT_PID_FILE ; then
#    echo "Tcp proxy is up (PID file exists and process found)"
#    return 0
#  else
#    echo "Tcp proxy is down (PID file not found)"
#    return 1
#  fi
#}
#
## Function to check if the Docker socket is accessible
#check_docker_socket() {
#  if [ -z "$RDOCKER_LOCAL_SOCKET" ]; then
#    echo "RDOCKER_LOCAL_SOCKET not set."
#    return 1
#  fi
#  #if [ -z "$RDOCKER_HOST" ]; then
#  #  echo "RDOCKER_HOST not set."
#  #  return 1
#  #fi
#
#  if curl -v --unix-socket "$RDOCKER_LOCAL_SOCKET" "http://localhost/version" ; then
#    echo "Docker socket is accessible."
#    return 0
#  else
#    echo "Docker socket is not accessible."
#    #return 1
#  fi
#}
#
#if ! check_ssh_tunnel ; then
#  exit 1
#fi
#echo "- check_ssh_tunnel: PASS"
#
#if ! check_docker_socket ; then
#  exit 2
#fi
#echo "- check_docker_socket: PASS"
#
#if ! check_docker_tcpproxy ; then
#  exit 3
#fi
#echo "- check_docker_tcpproxy: PASS"
#
#echo "✅ All checks passed."
#exit 0