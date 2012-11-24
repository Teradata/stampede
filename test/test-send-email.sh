#!/usr/bin/env bash
#----------------------------------------------------
# test-send-email.sh - Tests the send-email.sh script
# by mocking the mail program.
# usage:
#   test-send-email.sh

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

function dotest {
  MAIL=$TEST_DIR/mail-mock.sh $STAMPEDE_HOME/bin/send-email.sh alert deanwampler "test1" <<EOF
one
two
EOF
}

expected=("alert: Stampede failure: test1 deanwampler" "one" "two")
let count=0
function doloop {
  dotest | while read line
  do
    [ "$line" != "${expected[$count]}" ] && die "$0: ($count) $line != ${expected[$count]}."
    let count=$count+1
    # hack to get the final count out of the nested process!
    echo -n $count   
  done
}
count_str=$(doloop)
[ "$count_str" != "123" ] && die "$0: Number of output lines ($count_str) not equal to expected ${#expected[@]}."
exit 0