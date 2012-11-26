#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# Setup the tests, such as overriding variables...

export PROJECT_DIR=$TEST_DIR
let    STAMPEDE_DISABLE_ALERT_EMAILS=1
export STAMPEDE_DISABLE_ALERT_EMAILS
export STAMPEDE_LOG_DIR=$TEST_DIR/logs

export TIMEZONE=$(date +%z)
export TIMEZONE_NAME=$(date +%Z)
export STAMPEDE_START_TIME="Tue Nov 20 01:02:03 $TIMEZONE_NAME 2012"
export FAKE_STAMPEDE_LOG_START_TIME="2012-11-20 01:02:03$TIMEZONE"

. $STAMPEDE_HOME/bin/common.sh

