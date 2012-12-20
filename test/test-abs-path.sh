#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-abs-path.sh - Tests of bin/dates.

ABS_PATH=../bin/abs-path
TEST_DIR=$(dirname $($ABS_PATH ${BASH_SOURCE[0]}))
. $TEST_DIR/setup.sh

echo "  relative path tests:"

results=$($ABS_PATH $ABS_PATH)
[[ $results = $STAMPEDE_HOME/bin/abs-path ]] || die "Failed to resolve relative path of $ABS_PATH! returned <$results>"

results=$($ABS_PATH foo/bar/baz)
[ $? -ne 0 ] || die "Failed to return an error status for non-existent relative path!"
[[ $results = foo/bar/baz ]] || die "Failed to return the input non-existent relative path! returned <$results>"

echo "  absolute path tests:"

results=$($ABS_PATH $STAMPEDE_HOME/bin/abs-path)
[[ $results = $STAMPEDE_HOME/bin/abs-path ]] || die "Failed to resolve absolute path of $ABS_PATH! returned <$results>"

results=$($ABS_PATH $STAMPEDE_HOME/foo/bar/baz)
[ $? -ne 0 ] || die "Failed to return an error status for non-existent absolute path!"
[[ $results = $STAMPEDE_HOME/foo/bar/baz ]] || die "Failed to return the input non-existent absolute path! returned <$results>"

echo "  argument tests:"

$ABS_PATH -h > /dev/null
[ $? -eq 0 ] || die "Failed to treat -h as the help option!"
$ABS_PATH --help > /dev/null
[ $? -eq 0 ] || die "Failed to treat --help as the help option!"

$ABS_PATH -x 2>&1 | ( read line
[[ $line =~ ERROR:.Unrecognized.argument.\"-x\" ]] || die "Expected bad argument message: msg = <$line>" )

$ABS_PATH -x > /dev/null
[ $? -eq 0 ] && die "Failed to return error status for invalid -x option!"

exit 0