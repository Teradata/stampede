#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-format-log-message.sh - Tests log message formatting.

TEST_DIR=$(dirname ${BASH_SOURCE[0]})
. $TEST_DIR/setup.sh

echo "  error message format tests:"

msg=$(format-log-message 1234 ERROR my_app this is a message 2>&1)
[[ $msg =~ 1234.ERROR.*\(my_app\):.this.is.a.message ]] || die "Unexpected message 1: $msg"

msg=$(format-log-message 1234 ERROR my_app "this is a message" 2>&1)
[[ "$msg" =~ 1234.ERROR.*\(my_app\):.this.is.a.message ]] || die "Unexpected message 2: $msg"
