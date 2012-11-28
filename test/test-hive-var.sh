#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-hive-var.sh - Tests of the hive-var script.

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

echo "  specific strings tests:"

msg=$(hive-var --print-keys metastore.warehouse.dir)
[[ $msg =~ hive\.metastore\.warehouse\.dir ]] || die "Missing hive.metastore.warehouse.dir? msg = <$msg>"

msg=$(hive-var --p metastore.warehouse.dir)
[[ $msg =~ hive\.metastore\.warehouse\.dir ]] || die "Missing hive.metastore.warehouse.dir? msg = <$msg>"

echo "  options tests:"

hive-var 2>&1 | ( read line
[[ $line =~ ERROR:.Must.specify.names.or.--all ]] || die "Expected error message: msg = <$line>" )

hive-var -x 2>&1 | ( read line
[[ $line =~ ERROR:.Unrecognized.argument.\"-x\" ]] || die "Expected bad argument message: msg = <$line>" )

msg=$(hive-var --all)
[ -n "$msg" ] || die "No output for --all!"
