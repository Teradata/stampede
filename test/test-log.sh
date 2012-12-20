#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-log.sh - Tests of the logging functionality.

TEST_DIR=$(dirname ${BASH_SOURCE[0]})
. $TEST_DIR/setup.sh

echo "  emergency, alert, ..., function tests:"
save_log_level=$STAMPEDE_LOG_LEVEL
STAMPEDE_LOG_LEVEL=${#STAMPEDE_LOG_LEVEL_NAMES[@]}
# First, test that expected messages are logged
for n in ${STAMPEDE_LOG_LEVEL_NAMES[@]}
do
  name=$(echo $n | tr "[:upper:]" "[:lower:]")
  msg=$(DATE=$TEST_DIR/fake-date eval $name "$name message" 2>&1)
  case $msg in
    2012-11-20?01:02:03-[0-9]*?$n*\(test-log.sh\):?$name?message)
      ;;
    *)
      die "message was \"$msg\""
      ;;
  esac
done

# Now test when the threshold is less than the log call.
let STAMPEDE_LOG_LEVEL=0
for n in ${STAMPEDE_LOG_LEVEL_NAMES[@]}
do
  name=$(echo $n | tr "[:upper:]" "[:lower:]")
  let STAMPEDE_LOG_LEVEL=$STAMPEDE_LOG_LEVEL-1
  msg=$(DATE=$TEST_DIR/fake-date eval \$$name "$name message" 2>&1)
  [ -n "$msg" ] && die "No message expected! (msg = $msg)"
done
let STAMPEDE_LOG_LEVEL=$save_log_level


