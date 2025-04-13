# This script sets up the environment for the RDOCKER project.
# - It loads the environment variables from the specified context.
# - It checks if the required environment variables are set.
# -- RDOCKER_CONTEXT is the context name.
# -- RDOCKER_HOME is the home directory of the RDOCKER project.

RDOCKER_LOGPREFIX="[env] "
#RDOCKER_CONTEXT=$1
if [ -z "$RDOCKER_CONTEXT" ]; then
  echoerr "RDOCKER_CONTEXT not set. Exiting"
  exit 1
fi
if [ -z "$RDOCKER_HOME" ]; then
  echoerr "RDOCKER_HOME not set. Exiting"
  exit 1
fi

# Load env variables from the specified environment file
if [ -f ${RDOCKER_HOME}/hosts/${RDOCKER_CONTEXT}/env ]; then
  source ${RDOCKER_HOME}/hosts/${RDOCKER_CONTEXT}/env
else
  echoerr "WARN: File ${RDOCKER_HOME}/hosts/${RDOCKER_CONTEXT}/env does not exist."
  #exit 1
fi

# Check if the required environment variables are set
#if [ -z "$RDOCKER_HOST" ]; then
#  echo "RDOCKER_HOST not defined. Exiting"
#  exit 1
#fi

if [ -z "$RDOCKER_REMOTE_HOST" ]; then
  echoerr "RDOCKER_REMOTE_HOST not defined. Exiting"
  exit 1
fi

if [ -z "$RDOCKER_REMOTE_USER" ]; then
  echoerr "RDOCKER_REMOTE_USER not defined. Exiting"
  exit 1
fi
