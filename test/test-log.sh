#!/usr/bin/env bash
#---------------------------------
# test-log.sh - Tests of the logging functionality.

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

echo "  to-log-level test:"
let min1=${STAMPEDE_LOG_LEVEL_NAMES[0]}-1
let max1=${#STAMPEDE_LOG_LEVEL_NAMES[@]}+1
for i in $min1 $max1 foobar
do
  msg=$(DIE=$TEST_DIR/fake-die to-log-level $i 2>&1)
  case $msg in
    *Unrecognized*log*level*number*or*name*"$i"*given!*)
      ;;
    *)
      die "to-log-level failed for $i (min-1=$min1, max+1=$max1): $msg"
      ;;
  esac
done

for i in ${STAMPEDE_LOG_LEVELS[@]}
do 
  msg=$(DIE=$TEST_DIR/fake-die to-log-level $i)
  if [ "$msg" != "${STAMPEDE_LOG_LEVEL_NAMES[$i]}" ]
  then
    die "to-log-level failed for $i. Expected ${STAMPEDE_LOG_LEVEL_NAMES[$i]} (msg = $msg)" 
  fi
  # If you pass in the name, you should get it back!
  msg=$(DIE=$TEST_DIR/fake-die to-log-level ${STAMPEDE_LOG_LEVEL_NAMES[$i]})
  if [ "$msg" != "${STAMPEDE_LOG_LEVEL_NAMES[$i]}" ]
  then
    die "to-log-level failed for $i. Expected ${STAMPEDE_LOG_LEVEL_NAMES[$i]} (msg = $msg)" 
  fi
  # If you pass in the name in lower case, you should get it back in upper case!
  msg=$(DIE=$TEST_DIR/fake-die to-log-level $(echo ${STAMPEDE_LOG_LEVEL_NAMES[$i]} | tr "[:upper:]" "[:lower:]"))
  if [ "$msg" != "${STAMPEDE_LOG_LEVEL_NAMES[$i]}" ]
  then
    die "to-log-level failed for $i. Expected ${STAMPEDE_LOG_LEVEL_NAMES[$i]} (msg = $msg)" 
  fi
done

echo "  from-log-level test:"
msg=$(DIE=$TEST_DIR/fake-die from-log-level foobar 2>&1)
case $msg in
  *Unrecognized*log*level*name*or*number*"foobar"*given!*)
    ;;
  *)
    die "from-log-level failed for \"foobar\": $msg"
    ;;
esac

function _from_log_level_test {
  names="$@"
  let i=0
  for n in $names
  do 
    msg=$(DIE=$TEST_DIR/fake-die from-log-level $n)
    if [ "$msg" != "${STAMPEDE_LOG_LEVELS[$i]}" ]
    then
      die "from-log-level failed for \"$n\". Expected ${STAMPEDE_LOG_LEVELS[$i]} (msg = $msg)" 
    fi
    let i=$i+1
  done
}
_from_log_level_test ${STAMPEDE_LOG_LEVEL_NAMES[@]} 
lower_names=$(echo ${STAMPEDE_LOG_LEVEL_NAMES[@]} | tr "[:upper:]" "[:lower:]")
_from_log_level_test $lower_names
# If you pass in the actual levels, you should get them back!
_from_log_level_test ${STAMPEDE_LOG_LEVELS[@]} 

echo "  emergency, alert, ..., function tests:"
save_log_level=$STAMPEDE_LOG_LEVEL
STAMPEDE_LOG_LEVEL=${#STAMPEDE_LOG_LEVEL_NAMES[@]}
# First, test that expected messages are logged
for n in ${STAMPEDE_LOG_LEVEL_NAMES[@]}
do
  name=$(echo $n | tr "[:upper:]" "[:lower:]")
  msg=$(DATE=$TEST_DIR/fake-date eval $name "$name message" 2>&1)
  case $msg in
    2012-11-20?01:02:03?$n*test-log.sh:?$name?message)
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


