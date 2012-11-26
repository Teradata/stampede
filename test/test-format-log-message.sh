#!/usr/bin/env bash
#---------------------------------
# test-format-log-message.sh - Tests log message formatting.

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

msg=$(format-log-message 1234 ERROR my_app this is a message 2>&1)
[[ $msg =~ 1234.ERROR.*\(stampede:my_app\):.this.is.a.message ]] || error "Unexpected message 1: $msg"

msg=$(format-log-message 1234 ERROR my_app "this is a message" 2>&1)
[[ "$msg" =~ 1234.ERROR.*\(stampede:my_app\):.this.is.a.message ]] || error "Unexpected message 2: $msg"
