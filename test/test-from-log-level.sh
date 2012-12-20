#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-from-log-level.sh 

TEST_DIR=$(dirname ${BASH_SOURCE[0]})
. $TEST_DIR/setup.sh

echo "  invalid input numbers and names test:"
let min1=${STAMPEDE_LOG_LEVEL_NAMES[0]}-1
let max1=${#STAMPEDE_LOG_LEVEL_NAMES[@]}+1
for i in $min1 $max1 foobar
do
  msg=$(from-log-level $i 2>&1)
  case $msg in
  *Unrecognized*log*level*name*or*number*"$i"*given!*)
    ;;
  *)
    die "from-log-level failed for \"$i\": $msg"
    ;;
  esac

  msg=$(from-log-level $i -1 2>&1)
  case $msg in
  -1)
    ;;
  *)
    die "from-log-level failed for \"$i\" -1: $msg"
    ;;
  esac
done

function _from_log_level_test {
  names="$@"
  let i=0
  for n in $names
  do 
    msg=$(from-log-level $n)
    if [ "$msg" != "${STAMPEDE_LOG_LEVELS[$i]}" ]
    then
      die "from-log-level failed for \"$n\". Expected ${STAMPEDE_LOG_LEVELS[$i]} (msg = $msg)" 
    fi
    let i=$i+1
  done
}

echo "  valid input names test:"

_from_log_level_test ${STAMPEDE_LOG_LEVEL_NAMES[@]} 
lower_names=$(echo ${STAMPEDE_LOG_LEVEL_NAMES[@]} | tr "[:upper:]" "[:lower:]")
_from_log_level_test $lower_names

echo "  valid input numbers test:"

# If you pass in the actual levels, you should get them back!
_from_log_level_test ${STAMPEDE_LOG_LEVELS[@]} 

