#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-format-log-message.sh - Tests log message formatting.

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

msg=$(format-log-message 1234 ERROR my_app this is a message 2>&1)
[[ $msg =~ 1234.ERROR.*\(stampede:my_app\):.this.is.a.message ]] || die "Unexpected message 1: $msg"

msg=$(format-log-message 1234 ERROR my_app "this is a message" 2>&1)
[[ "$msg" =~ 1234.ERROR.*\(stampede:my_app\):.this.is.a.message ]] || die "Unexpected message 2: $msg"
