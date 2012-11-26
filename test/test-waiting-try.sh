#!/usr/bin/env bash
#---------------------------------
# test-waiting-try.sh - Tests of waiting and the try-* scripts.

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

echo "  waiting test:"
for i in {1..2}
do
  let seconds=$i*2
  # extract just what we want to check:
  msg=$(STAMPEDE_LOG_LEVEL=$(from-log-level INFO) waiting $i 2 "waiting test" 2>&1 | cut -d \( -f 3 | sed -e 's/)//')
  [ "$msg" = "waiting $seconds seconds so far" ] || die "waiting test failed! (msg = $msg)"
done

for cmd in "try-for" "try-for-or-die"
do
  echo "  $cmd test:"
  for s in "" s m h
  do
    msg=$(eval $cmd 2 1$s "ls $0") 
    [ $? -eq 0 ] || die "$cmd failed for arguments "2 1$s"! (msg = $msg)"
  done
done
try-for 2 1 "ls foobar &> /dev/null"
[ $? -ne 0 ] || die "try-for returned 0 even though it should have failed."
DIE=fake-die try-for-or-die 2 1 "ls foobar &> /dev/null" &> /dev/null
[ $? -ne 0 ] || die "try-for-or-die returned 0 even though it should have failed."

let end=$(dates --format="%s" 1:1 5 S)
for cmd in "try-until" "try-until-or-die"
do
  echo "  $cmd test:"
  msg=$(eval $cmd $end 2s "ls $0 &> /dev/null")
  [ $? -eq 0 ] || die "$cmd failed for arguments \"$end 1s\"! (msg = $msg)"
done
try-until $end 1 "ls foobar &> /dev/null"
[ $? -ne 0 ] || die "try-until returned 0 even though it should have failed."
DIE=fake-die try-until-or-die $end 1 "ls foobar &> /dev/null" &> /dev/null
[ $? -ne 0 ] || die "try-until-or-die returned 0 even though it should have failed."


