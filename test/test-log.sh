#!/usr/bin/env bash
#---------------------------------
# test-log.sh - Tests of the logging functionality.

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

echo "  to_log_level test:"
let min1=${STAMPEDE_LOG_LEVEL_NAMES[0]}-1
let max1=${#STAMPEDE_LOG_LEVEL_NAMES[@]}+1
for i in $min1 $max1
do
  msg=$(DIE=$TEST_DIR/fake_die to_log_level $i 2>&1)
  case $msg in
    Unrecognized*log*level*number*$i!*)
      ;;
    *)
      die "to_log_level failed for $i (min=$min1, max=$max1): $msg"
      ;;
  esac
done

for i in ${STAMPEDE_LOG_LEVELS[@]}
do 
  msg=$(DIE=$TEST_DIR/fake_die to_log_level $i)
  if [ "$msg" != "${STAMPEDE_LOG_LEVEL_NAMES[$i]}" ]
  then
    die "to_log_level failed for $i. Expected ${STAMPEDE_LOG_LEVEL_NAMES[$i]} (msg = $msg)" 
  fi
done

echo "  from_log_level test:"
msg=$(DIE=$TEST_DIR/fake_die from_log_level foobar 2>&1)
if [ "$msg" != "Unrecognized log level \"foobar\"!" ]
then
  die "from_log_level failed for \"foobar\": $msg"
fi

function _from_log_level_test {
  names="$@"
  let i=0
  for n in $names
  do 
    msg=$(DIE=$TEST_DIR/fake_die from_log_level $n)
    if [ "$msg" != "${STAMPEDE_LOG_LEVELS[$i]}" ]
    then
      die "from_log_level failed for \"$n\". Expected ${STAMPEDE_LOG_LEVELS[$i]} (msg = $msg)" 
    fi
    let i=$i+1
  done
}
_from_log_level_test ${STAMPEDE_LOG_LEVEL_NAMES[@]} 
lower_names=$(echo ${STAMPEDE_LOG_LEVEL_NAMES[@]} | tr "[:upper:]" "[:lower:]")
_from_log_level_test $lower_names

echo "  emergency, alert, ..., function tests:"
save_log_level=$STAMPEDE_LOG_LEVEL
STAMPEDE_LOG_LEVEL=${#STAMPEDE_LOG_LEVEL_NAMES[@]}
# First, test that expected messages are logged
for n in ${STAMPEDE_LOG_LEVEL_NAMES[@]}
do
  name=$(echo $n | tr "[:upper:]" "[:lower:]")
  msg=$(DATE=$TEST_DIR/fake_date eval $name "$name message" 2>&1)
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
  msg=$(DATE=$TEST_DIR/fake_date eval \$$name "$name message" 2>&1)
  [ -n "$msg" ] && die "No message expected! (msg = $msg)"
done
let STAMPEDE_LOG_LEVEL=$save_log_level


