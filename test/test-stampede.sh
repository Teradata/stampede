#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-stampede.sh - Tests the stampede driver script itself, mostly the 
# command-line options.

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

function dotest {
  if [ $# -gt 0 ]
  then
    target=$1
    shift
  fi
  stampede "$@" $TEST_DIR/Makefile $target 2>&1 | grep 'test-stampede output:'
}

echo2 "  timestamp settings tests:"

let tscount=1
msg=$(dotest timestamp)
expected="2012-11-20 01:02:03"
[[ $msg =~ $expected ]] || die "Unexpected message timestamp #$tscount: $msg"
let tscount=$tscount+1

msg=$(dotest timestamp --year=2010 --month=01 --day=02)
expected="2010-01-02 01:02:03"
[[ $msg =~ $expected ]] || die "Unexpected message timestamp #$tscount: $msg"
let tscount=$tscount+1

msg=$(dotest timestamp --year 2010 --month 01 --day 02)
expected="2010-01-02 01:02:03"
[[ $msg =~ $expected ]] || die "Unexpected message timestamp #$tscount: $msg"
let tscount=$tscount+1

msg=$(dotest timestamp --year=2010 --mon=01 --day=02)
expected="2010-01-02 01:02:03"
[[ $msg =~ $expected ]] || die "Unexpected message timestamp #$tscount: $msg"
let tscount=$tscount+1

msg=$(dotest timestamp --hour=05 --minute=06 --second=07)
expected="2012-11-20 05:06:07"
[[ $msg =~ $expected ]] || die "Unexpected message timestamp #$tscount: $msg"
let tscount=$tscount+1

msg=$(dotest timestamp --hour 05 --minute 06 --second 07)
expected="2012-11-20 05:06:07"
[[ $msg =~ $expected ]] || die "Unexpected message timestamp #$tscount: $msg"
let tscount=$tscount+1

msg=$(dotest timestamp --hour=05 --min=06 --sec=07)
expected="2012-11-20 05:06:07"
[[ $msg =~ $expected ]] || die "Unexpected message timestamp #$tscount: $msg"
let tscount=$tscount+1

msg=$(dotest timestamp --epoch=1319000462)
expected="2011-10-19 00:01:02"
[[ $msg =~ $expected ]] || die "Unexpected message timestamp #$tscount: $msg"
let tscount=$tscount+1

msg=$(dotest timestamp --epoch 1319000462)
expected="2011-10-19 00:01:02"
[[ $msg =~ $expected ]] || die "Unexpected message timestamp #$tscount: $msg"
let tscount=$tscount+1

msg=$(stampede --help 2>&1 | grep Usage)
expected="Usage:.*stampede.*"
[[ $msg =~ $expected ]] || die "Unexpected message for help argument: $msg"
let tscount=$tscount+1

echo2 "  invalid arguments tests:"

msg=$(EXIT=: stampede --xyz 2011 2>&1 | grep Unrecognized)
expected="Unrecognized option \"--xyz\"."
[ "$msg" = "$expected" ] || die "Unexpected message for bad argument: $msg"

units=(year month day hour minute second)
args=(1 11111 abcdef)
for i in {0..5}
do
  unit=${units[$i]}
  let size=2
  [ $unit = year ] && let size=4
  for j in {0..2}
  do
    arg=${args[$j]}
    msg=$(EXIT=: stampede --$unit=$arg 2>&1 | grep 'not a number')
    expected="$arg is not a number or isn't $size digits."
    [[ $msg =~ $expected ]] || die "Unexpected message for bad $unit argument $arg: $msg ?= $expected"
    msg=$(EXIT=: stampede --$unit=-$arg 2>&1 | grep 'Negative numbers')
    expected="Negative numbers not allowed: -$arg."
    [[ $msg =~ $expected ]] || die "Unexpected message for bad $unit argument -$arg: $msg ?= $expected"
  done
done

echo2 "  --force-rerun test:"

msg=$(dotest force-rerun --force-rerun | grep 'remaking')
expected="remaking $STAMPEDE_HOME/test/Makefile"
[[ $msg =~ $expected ]] || die "Unexpected message for --force-rerun option: $msg ?= $expected"

msg=$(dotest force-rerun | grep 'remaking')
[ -z "$msg" ] || die "Unexpected message for no --force-rerun option: <$msg> (should be empty)"

stampede --tries=2  $TEST_DIR/Makefile tries
echo2 "  --tries test:"
msg=$(dotest tries --tries=2 | grep 'remaking')
expected=""
[[ $msg =~ $expected ]] || die "Unexpected message for no --force-rerun option: <$msg> ?= <$expected>"
