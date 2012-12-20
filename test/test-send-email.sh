#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-send-email - Tests the send-email script.

TEST_DIR=$(dirname ${BASH_SOURCE[0]})
. $TEST_DIR/setup.sh

function dotest {
  MAIL=$TEST_DIR/mail-mock.sh $STAMPEDE_HOME/bin/send-email alert deanwampler "test1" <<EOF
one
two
EOF
}

echo "  error email tests:"

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