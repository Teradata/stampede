#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-hive-prop.sh - Tests of the hive-prop script.

TEST_DIR="$STAMPEDE_HOME/test"
. "$STAMPEDE_HOME/test/setup.sh"

HIVE_PROP="$STAMPEDE_HOME/bin/hadoop/hive-prop"

echo "  strings tests:"

msg=$("$HIVE_PROP" --print-keys hive.metastore.warehouse.dir)
[[ $msg =~ hive\.metastore\.warehouse\.dir ]] || die "Missing hive.metastore.warehouse.dir? msg = <$msg>"

msg=$("$HIVE_PROP" --print-values system:user.name)
[[ $msg = $USER ]] || die "Missing system:user.name? actual = <$msg>, expected <$USER>"

# Note that if you use Hive's "--define x=y" feature, the actual key is "hivevar:x".
msg=$("$HIVE_PROP" --define foo.bar=baz --print-values hivevar:foo.bar)
[[ $msg = baz ]] || die "Missing hivevar:foo.bar? actual = <$msg>, expected baz"

echo "  regular expressions tests"

msg=$("$HIVE_PROP" --print-keys --regex=.*\.metastore\.warehouse)
[[ $msg =~ hive\.metastore\.warehouse\.dir ]] || die "Missing --regex=.*\.metastore\.warehouse? msg = <$msg>"

msg=$("$HIVE_PROP" --print-values --regex='s.*:user\.name')
[[ $msg = $USER ]] || die "Missing --regex='s.*:user\.name'? actual = <$msg>, expected <$USER>"

msg=$("$HIVE_PROP" --define foo.bar=baz --print-values --regex=foo)
[[ $msg = baz ]] || die "Missing --regex=foo? actual = <$msg>, expected baz"

echo "  options tests:"

"$HIVE_PROP" --print-keys --all | grep metastore.warehouse.dir | ( read line 
[[ $line =~ hive\.metastore\.warehouse\.dir ]] || die "Missing hive.metastore.warehouse.dir? msg = <$msg>" )

"$HIVE_PROP" 2>&1 | ( read line
[[ $line =~ ERROR:.Must.specify.one.or.more.names,.--regex=re,.or.--all ]] || die "Expected error message: msg = <$line>" )

"$HIVE_PROP" -v warehouse 2>&1 | ( read line
[[ $line =~ Using.hive.CLI ]] || die "Expected verbose message about which Hive CLI: msg = <$line>" )

"$HIVE_PROP" -x 2>&1 | ( read line
[[ $line =~ ERROR:.Unrecognized.argument.\"-x\" ]] || die "Expected bad argument message: msg = <$line>" )

"$HIVE_PROP" -x > /dev/null
[ $? -eq 0 ] && die "Failed to return error status for invalid -x option!"

msg=$("$HIVE_PROP" --all)
[ -n "$msg" ] || die "No output for --all!"
