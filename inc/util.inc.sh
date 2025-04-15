# Project: RDOCKER
# File: inc/util.inc.sh
# This include script includes utility functions for the RDOCKER project.

function echolog() {
  local message="${1}"
  #local log_file="${2}"
  #echo "${message}" | tee -a "${log_file}"
  #echo "[rdocker] ${message}"

  #RDOCKER_DEBUG=1
  if [[ "${RDOCKER_DEBUG}" -eq 1 ]]; then
    echo "${RDOCKER_LOGPREFIX}${message}"
  fi
}

function echoerr() {
  local message="${1}"
  #local log_file="${2}"
  #echo "${message}" | tee -a "${log_file}" >&2
  echo "ERROR! ${RDOCKER_LOGPREFIX}${message}" >&2
}


function kill_process() {
  local pid=$1
  if [ -n "$pid" ]; then
    echolog "Killing process with PID: $pid"

    # check if the process is running
    if ! kill -0 "$pid" 2>/dev/null; then
      echolog "Process with PID $pid is not running. Exiting"
      return 0
    fi

    # kill the process
    kill $pid 2>/dev/null
    if [ $? -ne 0 ]; then
      echoerr "Failed to kill process. PID: $pid. Trying harder ..."
      kill -9 $pid
    fi
  fi
}

#function load_host_vars() {
#  local host_vars_file_path="${1}"
#  if [ -f "${host_vars_file_path}" ]; then
#    source "${host_vars_file_path}"
#  fi
#}
