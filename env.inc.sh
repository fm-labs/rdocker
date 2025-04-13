# This script sets up the environment for the RDOCKER project.
# - It loads the environment variables from the specified context.
# - It checks if the required environment variables are set.
# -- RDOCKER_CONTEXT is the context name.
# -- RDOCKER_HOME is the home directory of the RDOCKER project.


#RDOCKER_CONTEXT=$1
if [ -z "$RDOCKER_CONTEXT" ]; then
  echo "[env] RDOCKER_CONTEXT not set. Exiting"
  exit 1
fi
if [ -z "$RDOCKER_HOME" ]; then
  echo "[env] RDOCKER_HOME not set. Exiting"
  exit 1
fi

# Load env variables from the specified environment file
if [ ! -f ${RDOCKER_HOME}/hosts/${RDOCKER_CONTEXT}/env ]; then
  echo "[env] File ${RDOCKER_HOME}/hosts/${RDOCKER_CONTEXT}/env does not exist. Exiting"
  exit 1
fi
source ${RDOCKER_HOME}/hosts/${RDOCKER_CONTEXT}/env

# Check if the required environment variables are set
#if [ -z "$RDOCKER_HOST" ]; then
#  echo "[env] RDOCKER_HOST not defined. Exiting"
#  exit 1
#fi

if [ -z "$RDOCKER_REMOTE_HOST" ]; then
  echo "[env] RDOCKER_REMOTE_HOST not defined. Exiting"
  exit 1
fi

if [ -z "$RDOCKER_REMOTE_USER" ]; then
  echo "[env] RDOCKER_REMOTE_USER not defined. Exiting"
  exit 1
fi
