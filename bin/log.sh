#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# Common functions related to logging.
# Source this file as part of common.sh
# We use the same logging levels supported by SYSLOG,
# and you have the option of using syslog or the local
# option, which is the default. See the settings in
# bin/env.sh.

thisdir=$(dirname ${BASH_SOURCE[0]})

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
  [ "$STAMPEDE_LOG_USE_SYSLOG" -eq 0 ] && return 0
  if [ -z "$STAMPEDE_LOG_DIR" ]
  then
    echo "WARNING: STAMPEDE_LOG_DIR not defined. Using \".logs\"." 1>&2
    STAMPEDE_LOG_DIR=.logs
  fi
  [ -d $STAMPEDE_LOG_DIR ] || mkdir -p $STAMPEDE_LOG_DIR
}

# Cache the following for faster access...
export APP_NAME=$(basename $0)

# Log a message.
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
      # The funky quoting is required to handle possible embedded spaces in the format.
      d=$(eval $DATE "\"$STAMPEDE_LOG_TIME_FORMAT\"")
    fi

    msg=$(format-log-message "$d" "$level_str" "$APP_NAME" "$@")
    if [ "$STAMPEDE_LOG_USE_SYSLOG" -eq 0 ]
    then
      logger $STAMPEDE_LOG_SYSLOG_OPTIONS -p $level "($APP_NAME): $@"
    else
      echo "$msg" >> "$STAMPEDE_LOG_FILE"
    fi
    echo2 "$msg"
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
