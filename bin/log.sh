# Common functions related to logging
# Source this file as part of common.sh

function log_file {
  echo "$STAMPEDE_LOG_DIR/$STAMPEDE_LOG_FILE"
}

export STAMPEDE_LOG_LEVEL_NAMES=(DEBUG INFO WARN ERROR FATAL)
export STAMPEDE_LOG_LEVELS=(1 2 3 4 5)

function to_log_level {
  let n=$1-1
  if [ $n -lt 0 -o $n -gt 4 ]
  then
    $DIE "Unrecognized log level $1!"
  else
    echo ${STAMPEDE_LOG_LEVEL_NAMES[$n]}
  fi
}

function init_log_file {
  mkdir -p $STAMPEDE_LOG_DIR
  touch $(log_file)
}

# Log a message. Pass ${FUNCNAME[0]} and $LINENO as part of the arguments
# to get the name and line number of the function you're logging from.
function log {
  let level=$1
  shift
  if [ $level -ge $STAMPEDE_LOG_LEVEL ]
  then
    level_str=$(to_log_level $level)
    if [ -z "$STAMPEDE_LOG_TIME_FORMAT" ]
    then
      d=$(eval $DATE)
    else
      d=$(eval $DATE "$STAMPEDE_LOG_TIME_FORMAT")
    fi
    init_log_file
    args="$@"  # treat as a single string
    printf "%s %-5s %-10s: %s\n" "$d" "$level_str" "$(basename $0)" "$args" | tee -a $(log_file) 1>&2
  fi
}

function debug {
  log 1 "$@"
}
function info {
  log 2 "$@"
}
function warn {
  log 3 "$@"
}
function warning {  # alias for warn
  warn "$@"
}
# It doesn't exit the program. Call die for that.
function error {
  log 4 "$@"
}
# It doesn't exit the program. Call die for that.
function fatal {
  log 5 "$@"
}


