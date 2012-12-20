#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-hive-prop.sh - Tests of the hive-prop script.

TEST_DIR="$STAMPEDE_HOME/test"
. "$STAMPEDE_HOME/test/setup.sh"

HIVE_PROP="$STAMPEDE_HOME/bin/hadoop/hive-prop"

echo "  specific strings tests:"

msg=$("$HIVE_PROP" --print-keys metastore.warehouse.dir)
[[ $msg =~ hive\.metastore\.warehouse\.dir ]] || die "Missing hive.metastore.warehouse.dir? msg = <$msg>"

msg=$("$HIVE_PROP" --print-values system:user.name)
[[ $msg = $USER ]] || die "Missing hive.metastore.warehouse.dir? msg = <$msg>"

echo "  options tests:"

"$HIVE_PROP" 2>&1 | ( read line
[[ $line =~ ERROR:.Must.specify.one.or.more.names.or.--all ]] || die "Expected error message: msg = <$line>" )

"$HIVE_PROP" -v warehouse 2>&1 | ( read line
[[ $line =~ Using.hive.CLI ]] || die "Expected verbose message about which Hive CLI: msg = <$line>" )

"$HIVE_PROP" -x 2>&1 | ( read line
[[ $line =~ ERROR:.Unrecognized.argument.\"-x\" ]] || die "Expected bad argument message: msg = <$line>" )

"$HIVE_PROP" -x > /dev/null
[ $? -eq 0 ] && die "Failed to return error status for invalid -x option!"

msg=$("$HIVE_PROP" --all)
[ -n "$msg" ] || die "No output for --all!"
