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


#function load_host_vars() {
#  local host_vars_file_path="${1}"
#  if [ -f "${host_vars_file_path}" ]; then
#    source "${host_vars_file_path}"
#  fi
#}
