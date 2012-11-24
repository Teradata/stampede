# Common functions related to logging.
# Source this file as part of common.sh
# We use the same logging levels supported by syslog(1),
# and you have the option of using syslog or the local
# option, which is the default. See the settings in
# bin/env.sh.

thisdir=$(dirname $BASH_SOURCE)

function format_log_message {
  date=$1
  shift
  level_str=$1
  shift
  app_name=$1
  shift
  args="$@"  # Treat as a single string.

  printf "$STAMPEDE_LOG_MESSAGE_FORMAT_STRING\n" "$date" "$level_str" "$app_name" "$args"
}

function init_log_file {
  if [ $STAMPEDE_LOG_USE_SYSLOG -ne 0 ]
  then
    if [ -z "$STAMPEDE_LOG_DIR" ]
    then
      echo "WARNING: STAMPEDE_LOG_DIR not defined. Using \".logs\"."
      STAMPEDE_LOG_DIR=.logs
    fi
    [ -d $STAMPEDE_LOG_DIR ] || mkdir -p $STAMPEDE_LOG_DIR
  fi
}

# Log a message. Pass ${FUNCNAME[0]} and $LINENO as part of the arguments
# to get the name and line number of the function you're logging from.
function log {
  let level=$1
  shift
  if [ $level -le $STAMPEDE_LOG_LEVEL ]
  then
    level_str=$($thisdir/to-log-level $level)
    if [ -z "$STAMPEDE_LOG_TIME_FORMAT" ]
    then
      d=$(eval $DATE)
    else
      d=$(eval $DATE "$STAMPEDE_LOG_TIME_FORMAT")
    fi
    msg=$($STAMPEDE_LOG_MESSAGE_FORMAT_FUNCTION "$d" "$level_str" "$(basename $0)" "$@")
    if [ "$STAMPEDE_LOG_USE_SYSLOG" -eq 0 ]
    then
      syslog -s -r $STAMPEDE_LOG_SYSLOG_HOST -l $level "$@"
      echo "$msg" 1>&2
    else
      init_log_file
      echo "$msg" | tee -a $(log-file) 1>&2
    fi
  fi
}

function emergency { log 0 "$@"; }
function alert     { log 1 "$@"; }
function critical  { log 2 "$@"; }
function error     { log 3 "$@"; }
function warning   { log 4 "$@"; }
function warn      { log 4 "$@"; }
function notice    { log 5 "$@"; }
function info      { log 6 "$@"; }
function debug     { log 7 "$@"; }

