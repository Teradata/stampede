#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-mapreduce-prop.sh - Tests of the mapreduce-prop script.

TEST_DIR="$STAMPEDE_HOME/test"
. "$STAMPEDE_HOME/test/setup.sh"

MAPREDUCE_PROP="$STAMPEDE_HOME/bin/hadoop/mapreduce-prop"

echo "  specific strings tests:"

msg=$($MAPREDUCE_PROP -D foo.bar=baz --print-keys foo.bar)
[[ $msg =~ foo\.bar ]] || die "Missing foo.bar key? msg = <$msg>"

msg=$($MAPREDUCE_PROP -D foo.bar=baz --print-values foo.bar)
[[ $msg =~ baz ]] || die "Missing value for foo.bar (expecting baz)? msg = <$msg>"

msg=$($MAPREDUCE_PROP -D foo.bar=baz foo.bar)
[[ $msg =~ foo\.bar=baz ]] || die "Missing foo.bar=baz? msg = <$msg>"

msg=$($MAPREDUCE_PROP -D foo.bar=baz --regex='^foo.*' | grep 'foo.bar')
[[ $msg =~ foo\.bar=baz ]] || die "Missing foo.bar=baz? msg = <$msg>"

echo "  options tests:"

$MAPREDUCE_PROP -D foo.bar=baz --all | grep 'foo.bar' | ( read line
[[ $line =~ foo\.bar=baz ]] || die "Missing foo.bar=baz? msg = <$msg>" )

$MAPREDUCE_PROP 2>&1 | ( read line
[[ $line =~ ERROR:.Must.specify.one.or.more.names,.regular.expressions,.or.--all ]] || die "Expected error message: msg = <$line>" )

$MAPREDUCE_PROP -x 2>&1 | ( read line
[[ $line =~ ERROR:.Unrecognized.argument.\"-x\" ]] || die "Expected bad argument message: msg = <$line>" )

$MAPREDUCE_PROP -x > /dev/null 2>&1 
[ $? -eq 0 ] && die "Failed to return error status for invalid -x option!"

exit 0