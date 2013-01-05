#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-pig-prop.sh - Tests of the pig-prop script.

TEST_DIR="$STAMPEDE_HOME/test"
. "$STAMPEDE_HOME/test/setup.sh"

PIG_PROP="$STAMPEDE_HOME/bin/hadoop/pig-prop"

echo "  strings tests:"

opts="-x local -propertyFile $TEST_DIR/hadoop/pig.properties"

msg=$("$PIG_PROP" --print-keys $opts log4jconf)
[[ $msg =~ log4jconf ]] || die "Missing log4jconf? msg = <$msg>"

msg=$("$PIG_PROP" --print-values $opts log4jconf)
[[ $msg =~ \./conf/log4j\.properties ]] || die "Missing ./conf/log4j.properties? msg = <$msg>"

echo "  regular expressions tests:"

msg=$("$PIG_PROP" --print-keys $opts --regex=^log4j)
[[ $msg =~ log4jconf ]] || die "Missing log4jconf? msg = <$msg>"

msg=$("$PIG_PROP" --print-values $opts --regex=^log4j)
[[ $msg =~ \./conf/log4j\.properties ]] || die "Missing ./conf/log4j.properties? msg = <$msg>"

echo "  options tests:"

"$PIG_PROP" --print-keys $opts --all | grep log4jconf | ( read line
[[ $line =~ log4jconf ]] || die "Missing log4jconf? msg = <$msg>" )

"$PIG_PROP" 2>&1 | ( read line
[[ $line =~ ERROR:.Must.specify.one.or.more.names,.--regex=re,.or.--all ]] || die "Expected error message: msg = <$line>" )

"$PIG_PROP" -z 2>&1 | ( read line
[[ $line =~ ERROR:.Unrecognized.or.disallowed.pig.shell.argument:.\"-z\" ]] || die "Expected bad argument message: msg = <$line>" )

"$PIG_PROP" -z > /dev/null
[ $? -eq 0 ] && die "Failed to return error status for invalid -x option!"

exit 0