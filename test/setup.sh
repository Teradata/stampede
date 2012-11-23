# Setup the tests, such as overriding variables...

export PROJECT_DIR=$TEST_DIR
export STAMPEDE_DISABLE_ALERT_EMAILS=true
export STAMPEDE_LOG_DIR=$TEST_DIR/logs
mkdir -p STAMPEDE_LOG_DIR

# 2012-11-20 01:02:03
let EPOCH_SECOND=1353394923
export EPOCH_SECOND

. $STAMPEDE_HOME/bin/common.sh

function fake_date {
  echo $(start_time)
}

function fake_die {
  echo "$@" 1>&2
  return 1
}

function fake_exit {
  echo "$@" 1>&2
  return 1
}
