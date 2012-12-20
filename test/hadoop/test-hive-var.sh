#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-hive-var.sh - Tests of the hive-var script.

TEST_DIR=$STAMPEDE_HOME/test
. $STAMPEDE_HOME/test/setup.sh

HIVE_VAR=$STAMPEDE_HOME/bin/hadoop/hive-var

echo "  specific strings tests:"

msg=$($HIVE_VAR --print-keys metastore.warehouse.dir)
[[ $msg =~ hive\.metastore\.warehouse\.dir ]] || die "Missing hive.metastore.warehouse.dir? msg = <$msg>"

msg=$($HIVE_VAR --print-values system:user.name)
[[ $msg = $USER ]] || die "Missing hive.metastore.warehouse.dir? msg = <$msg>"

echo "  options tests:"

$HIVE_VAR 2>&1 | ( read line
[[ $line =~ ERROR:.Must.specify.one.or.more.names.or.--all ]] || die "Expected error message: msg = <$line>" )

$HIVE_VAR -v warehouse 2>&1 | ( read line
[[ $line =~ Using.hive.CLI ]] || die "Expected verbose message about which Hive CLI: msg = <$line>" )

$HIVE_VAR -x 2>&1 | ( read line
[[ $line =~ ERROR:.Unrecognized.argument.\"-x\" ]] || die "Expected bad argument message: msg = <$line>" )

$HIVE_VAR -x > /dev/null
[ $? -eq 0 ] && die "Failed to return error status for invalid -x option!"

msg=$($HIVE_VAR --all)
[ -n "$msg" ] || die "No output for --all!"
