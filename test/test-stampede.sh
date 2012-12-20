#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-stampede.sh - Tests the stampede driver script itself, mostly the 
# command-line options.

TEST_DIR=$(dirname ${BASH_SOURCE[0]})
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

msg=$(dotest timestamp)
expected="2012-11-20 01:02:03"
[[ $msg =~ $expected ]] || die "Unexpected message for timestamp and no arguments: $msg"

for sep in ' ' '='
do
  for mon in mon month
  do
    args="--year${sep}2010 --${mon}${sep}01 --day${sep}02"
    msg=$(dotest timestamp $args)
    expected="2010-01-02 01:02:03"
    [[ $msg =~ $expected ]] || die "Unexpected message for args \"$args\": $msg"
  done

  for min in min minute
  do
    for sec in sec second
    do
      args="--hour${sep}05 --${min}${sep}06 --${sec}${sep}07"
      msg=$(dotest timestamp $args)
      expected="2012-11-20 05:06:07"
      [[ $msg =~ $expected ]] || die "Unexpected message for args \"$args\": $msg"
    done
  done

  args="--epoch${sep}1319000462"
  msg=$(dotest timestamp $args)
  # Due to timezones, the date and hour can vary.
  expected="2011-10-.. ..:01:02"
  [[ $msg =~ $expected ]] || die "Unexpected message for \"$args\": $msg"
  let tscount=$tscount+1
done

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

echo2 "  --force-rerun tests:"

msg=$(dotest force-rerun --force-rerun | grep 'remaking')
expected="remaking $STAMPEDE_HOME/test/Makefile"
[[ $msg =~ $expected ]] || die "Unexpected message for \"$args\": $msg ?= $expected"

msg=$(dotest force-rerun | grep 'remaking')
[ -z "$msg" ] || die "Unexpected message for \"$args\": <$msg> (should be empty)"

echo2 "  --tries and --between-tries tests:"

for sep in ' ' '='
do
  args="--tries${sep}2 --between-tries${sep}2s"
  expected="Failed after 2 attempts"
  msg=$(EXIT=: stampede $args $TEST_DIR/Makefile tries 2>&1 | grep "$expected")
  [[ $msg =~ $expected ]] || die "Unexpected message for \"$args\": <$msg> ?= <$expected>"
done

echo2 "  --log-level tests:"

for sep in ' ' '='
do
  for ll in log logging
  do
    for level in DEBUG 7 EMERGENCY 0
    do
      args="--${ll}-level${sep}${level}"
      msg=$(EXIT=: stampede $args $TEST_DIR/Makefile timestamp 2>&1 | grep $(to-log-level $level))
      if [ "$level" = "EMERGENCY" -o "$level" = "0" ]
      then
        [ -z "$msg" ] || die "Unexpected message for \"$args\": <$msg> (should be empty)"
      else
        [[ $msg =~ DEBUG ]] || die "Unexpected message for \"$args\": <$msg> ?=~ <DEBUG>"
      fi
    done
  done
done

echo2 "  --no-exec tests:"

for n in -n --no --no-exec
do
  args="$n --tries=1 --log-level=NOTICE"
  stampede $args $TEST_DIR/Makefile tries 2>&1 | while read line
  do
    [[ $line =~ failed ]] && die "Unexpected message for \"$args\" (make --dry-run not called?): <$line>"
  done
done

echo2 "  create tests:"

args="--no-exec create --log-level=NOTICE"
msg=$(stampede $args 2>&1 | grep -i 'create')
[[ $msg =~ create-project ]] || die "Unexpected message for \"$args\": <$line>"
