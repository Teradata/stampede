#!/usr/bin/env bash
#---------------------------------
# test-log.sh - Tests of the log.sh file

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

echo "  to_log_level test:"
save_die=$DIE
DIE=fake_die
for i in -1 0 6
do
  msg=$(to_log_level $i 2>&1)
  if [ "$msg" != "Unrecognized log level $i!" ]
  then
    DIE=$save_die
    die "to_log_level failed for $i: $msg"
  fi
done
names=(DEBUG INFO WARN ERROR FATAL)
for i in {0..4}
do 
  let ii=i+1
  msg=$(to_log_level $ii)
  if [ "$msg" != "${names[$i]}" ]
  then
    DIE=$save_die
    die "to_log_level failed for $ii. Expected ${names[$i]} (msg = $msg)" 
  fi
done
DIE=$save_die

echo "  debug, info, warn, error, and fatal tests:"
save_log_level=$STAMPEDE_LOG_LEVEL
STAMPEDE_LOG_LEVEL=1
DATE=fake_date
# First, test that expected messages are logged
for n in DEBUG INFO WARN ERROR FATAL
do
  name=$(echo $n | tr "[:upper:]" "[:lower:]")
  msg=$(eval $name "$name message" 2>&1)
  case $msg in
    2012-11-20?01:02:03?$n*test-log.sh:?$name?message)
      ;;
    *)
      die "message was \"$msg\""
      ;;
  esac
done

# Now test when the threshold is greater than the log call.
let STAMPEDE_LOG_LEVEL=$STAMPEDE_LOG_LEVEL+1
for n in DEBUG INFO WARN ERROR FATAL
do
  name=$(echo $n | tr "[:upper:]" "[:lower:]")
  let STAMPEDE_LOG_LEVEL=$STAMPEDE_LOG_LEVEL+1
  msg=$(echo $(eval \$$name "$name message"))
  [ -n "$msg" ] && die "No message expected! (msg = $msg)"
done
let STAMPEDE_LOG_LEVEL=$save_log_level
DATE=date

