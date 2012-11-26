#!/usr/bin/env bash
#---------------------------------
# test-to-log-level.sh 

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

echo "  invalid input numbers and names test:"
let min1=${STAMPEDE_LOG_LEVEL_NAMES[0]}-1
let max1=${#STAMPEDE_LOG_LEVEL_NAMES[@]}+1
for i in $min1 $max1 foobar
do
  msg=$(to-log-level $i 2>&1)
  case $msg in
    *Unrecognized*log*level*number*or*name*"$i"*given!*)
      ;;
    *)
      die "to-log-level failed for $i (min-1=$min1, max+1=$max1): $msg"
      ;;
  esac

  msg=$(to-log-level $i FOOBAR 2>&1)
  case $msg in
    FOOBAR)
      ;;
    *)
      die "to-log-level failed for $i FOOBAR (min-1=$min1, max+1=$max1): $msg"
      ;;
  esac
done

echo "  valid input numbers test:"
for i in ${STAMPEDE_LOG_LEVELS[@]}
do 
  msg=$(to-log-level $i)
  if [ "$msg" != "${STAMPEDE_LOG_LEVEL_NAMES[$i]}" ]
  then
    die "to-log-level failed for $i. Expected ${STAMPEDE_LOG_LEVEL_NAMES[$i]} (msg = $msg)" 
  fi
done

echo "  valid input names test:"
for i in ${STAMPEDE_LOG_LEVELS[@]}
do 
  # If you pass in the name, you should get it back!
  msg=$(to-log-level ${STAMPEDE_LOG_LEVEL_NAMES[$i]})
  if [ "$msg" != "${STAMPEDE_LOG_LEVEL_NAMES[$i]}" ]
  then
    die "to-log-level failed for $i. Expected ${STAMPEDE_LOG_LEVEL_NAMES[$i]} (msg = $msg)" 
  fi
  # If you pass in the name in lower case, you should get it back in upper case!
  msg=$(to-log-level $(echo ${STAMPEDE_LOG_LEVEL_NAMES[$i]} | tr "[:upper:]" "[:lower:]"))
  if [ "$msg" != "${STAMPEDE_LOG_LEVEL_NAMES[$i]}" ]
  then
    die "to-log-level failed for $i. Expected ${STAMPEDE_LOG_LEVEL_NAMES[$i]} (msg = $msg)" 
  fi
done

