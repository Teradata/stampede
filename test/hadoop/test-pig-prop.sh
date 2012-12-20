#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-pig-prop.sh - Tests of the pig-prop script.

TEST_DIR=$STAMPEDE_HOME/test
. $STAMPEDE_HOME/test/setup.sh

PIG_PROP=$STAMPEDE_HOME/bin/hadoop/pig-prop

echo "  specific strings tests:"

msg=$($PIG_PROP --print-keys --props-file=$TEST_DIR/hadoop/pig.properties log4jconf)
[[ $msg =~ log4jconf ]] || die "Missing log4jconf? msg = <$msg>"

msg=$($PIG_PROP --print-values --props-file=$TEST_DIR/hadoop/pig.properties log4jconf)
[[ $msg =~ \./conf/log4j\.properties ]] || die "Missing ./conf/log4j.properties? msg = <$msg>"

echo "  options tests:"

$PIG_PROP 2>&1 | ( read line
[[ $line =~ ERROR:.Must.specify.one.or.more.names.or.--all ]] || die "Expected error message: msg = <$line>" )

$PIG_PROP -v -f $TEST_DIR/hadoop/pig.properties --all 2>&1 | ( read line
[[ $line =~ Using.pig.properties ]] || die "Expected verbose message about which Pig properties file: msg = <$line>" )

$PIG_PROP -v -f $TEST_DIR/hadoop/pig.properties --all 2>&1 | ( read line
[[ $line =~ Using.pig.properties ]] || die "Expected verbose message about which Pig properties file: msg = <$line>" )

$PIG_PROP -x 2>&1 | ( read line
[[ $line =~ ERROR:.Unrecognized.argument.\"-x\" ]] || die "Expected bad argument message: msg = <$line>" )

$PIG_PROP -x > /dev/null
[ $? -eq 0 ] && die "Failed to return error status for invalid -x option!"

msg=$($PIG_PROP -f $TEST_DIR/hadoop/pig.properties --all)
[ -n "$msg" ] || die "No output for --all!"
