#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-waiting-try.sh - Tests of waiting and the try-* scripts.

TEST_DIR=$(dirname ${BASH_SOURCE[0]})
. $TEST_DIR/setup.sh

echo "  waiting test:"
for i in {1..2}
do
  let seconds=$i*2
  # extract just what we want to check:
  msg=$(STAMPEDE_LOG_LEVEL=$(from-log-level INFO) waiting $i 2 "waiting test" 2>&1 | cut -d \( -f 3 | sed -e 's/)//')
  [ "$msg" = "waiting $seconds seconds so far" ] || die "waiting test failed! (msg = $msg)"
done

echo "  try-for test:"
for s in "" s m h
do
  msg=$(eval try-for 2 1$s "ls $0") 
  [ $? -eq 0 ] || die "try-for failed for arguments "2 1$s"! (msg = $msg)"
done

try-for 2 1 "ls foobar &> /dev/null"
[ $? -ne 0 ] || die "try-for returned 0 even though it should have failed."

let end=$(dates --format="%s" 1:1 5 S)
echo "  try-until test:"
msg=$(eval try-until $end 2s "ls $0 &> /dev/null")
[ $? -eq 0 ] || die "try-until failed for arguments \"$end 1s\"! (msg = $msg)"
try-until $end 1 "ls foobar &> /dev/null"
[ $? -ne 0 ] || die "try-until returned 0 even though it should have failed."


