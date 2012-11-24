# Setup the tests, such as overriding variables...

export PROJECT_DIR=$TEST_DIR
let    STAMPEDE_DISABLE_ALERT_EMAILS=1
export STAMPEDE_DISABLE_ALERT_EMAILS
export STAMPEDE_LOG_DIR=$TEST_DIR/logs

# 2012-11-20 01:02:03
let EPOCH_SECOND=1353394923
export EPOCH_SECOND

. $STAMPEDE_HOME/bin/common.sh

