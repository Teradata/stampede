#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-find-tool.sh - Tests of the find-tool script.

TEST_DIR="$STAMPEDE_HOME/test"
. "$STAMPEDE_HOME/test/setup.sh"

FIND_TOOL="$STAMPEDE_HOME/bin/find-tool"

echo "  options tests:"

"$FIND_TOOL" -v --dir=foo/bar:baz --dir=/tmp/toss:/tmp/toss2 find-tool 2>&1 | grep 'search directories' | ( read line
 [[ $line =~ foo/bar\ baz\ /tmp/toss\ /tmp/toss2 ]] || die "Missing search directories? line = <$line>" )

echo "  success tests:"

"$FIND_TOOL" find-tool | ( read line
 [[ $line =~ find-tool$ ]] || die "Unsuccessful? line = <$line>" )
[ ${PIPESTATUS[0]} -ne 0 ] && die "Wrong status for success"

echo "  failure tests:"

"$FIND_TOOL" nonexistent-tool 2>&1 | ( read line
 [[ $line =~ \"nonexistent-tool\"\ was\ not\ found ]] || die "Failure? line = <$line>" )
[ ${PIPESTATUS[0]} -eq 0 ] && die "Wrong status for failure"

exit 0