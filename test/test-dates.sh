#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-dates.sh - Tests of bin/dates.

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

# Dates is fairly complicated. This test is not as comprehensive as it could be.

DATES=$TEST_DIR/../bin/dates
INDATE="$STAMPEDE_START_TIME"  # as hard-coded in setup.sh
INFORMAT="%a %b %d %H:%M:%S %Z %Y"
OUTFORMAT="%Y-%m-%d %H:%M:%S%z"

echo "  format tests:"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="$OUTFORMAT")
[ "$results" = "2012-11-20 01:02:03$TIMEZONE" ] || die "\"$INFORMAT\" format failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat=rfc-3999 --format=rfc-3999)
[ "$results" = "$INDATE" ] || die "rfc-3999 format failed! returned <$results>"

# We don't cover all possibilities in what follows...

results=$($DATES --date="$INDATE" --informat=rfc-3999 --format='%Y')
[ "$results" = "2012" ] || die "%Y failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat=rfc-3999 --format='%m')
[ "$results" = "11" ] || die "%m failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat=rfc-3999 --format='%d')
[ "$results" = "20" ] || die "%d failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat=rfc-3999 --format='%H')
[ "$results" = "01" ] || die "%H failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat=rfc-3999 --format='%M')
[ "$results" = "02" ] || die "%M failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat=rfc-3999 --format='%S')
[ "$results" = "03" ] || die "%S failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat=rfc-3999 --format='%s')
[ "$results" = "$EPOCH_SECOND" ] || die "%s failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat=rfc-3999 --format='%w')
[ "$results" = "2" ] || die "%w failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat=rfc-3999 --format='%Z')
[ "$results" = "$TIMEZONE_NAME" ] || die "%Z failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat=rfc-3999 --format='%z')
[ "$results" = "$TIMEZONE" ] || die "%z failed! returned <$results>"

echo "  range tests:"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="$OUTFORMAT" -1:-1 d)
[ "$results" = "2012-11-19 01:02:03$TIMEZONE" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="$OUTFORMAT" -2:-1 d)
[ "$results" = "2012-11-18 01:02:03$TIMEZONE 2012-11-19 01:02:03$TIMEZONE" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="$OUTFORMAT" 0:0 d)
[ "$results" = "2012-11-20 01:02:03$TIMEZONE" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="$OUTFORMAT" 1:2 d)
[ "$results" = "2012-11-21 01:02:03$TIMEZONE 2012-11-22 01:02:03$TIMEZONE" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="$OUTFORMAT")
[ "$results" = "2012-11-20 01:02:03$TIMEZONE" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%d" -2:)
[ "$results" = "18 19 20" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%d" :2)
[ "$results" = "20 21 22" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%d" :-2)
[ "$results" = "20 19 18" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%d" 2:)
[ "$results" = "22 21 20" ] || die "failed! returned <$results>"

echo "  separator tests:"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%d" --sep='|' 2:)
[ "$results" = "22|21|20" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%d" --sep='' 2:)
[ "$results" = "222120" ] || die "failed! returned <$results>"

# Handles \n as a separator?
expected=$(for i in {22..20}; do echo $i; done)
results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%d" --sep='\n' 2:)
[ "$results" = "$expected" ] || die "failed! returned <$results>, expected = <$expected>"

echo "  time delta tests:"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%Y" -1:1 y)
[ "$results" = "2011 2012 2013" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%m" -1:1 m)
[ "$results" = "10 11 12" ] || die "failed! returned <$results>"

if [ $(uname) = "Darwin" ]
then
  results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%d" -1:1 w)
  [ "$results" = "13 20 27" ] || die "failed! returned <$results>"
fi

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%d" -1:1 d)
[ "$results" = "19 20 21" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%H" -1:1 H)
[ "$results" = "00 01 02" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%M" -1:1 M)
[ "$results" = "01 02 03" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%S" -1:1 S)
[ "$results" = "02 03 04" ] || die "failed! returned <$results>"

results=$($DATES --date="$INDATE" --informat="$INFORMAT" --format="%s" -1:1 S)
let sm1=$EPOCH_SECOND-1
let s0=$EPOCH_SECOND
let sp1=$EPOCH_SECOND+1
[ "$results" = "$sm1 $s0 $sp1" ] || die "failed! returned <$results>"


echo "  leap year tests:"

results=$($DATES --date="Sun Feb 28 01:02:03 $TIMEZONE_NAME 2100" --informat="$INFORMAT" --format="%d" -2:2 d)
[ "$results" = "26 27 28 01 02" ] || die "failed! returned <$results>"
results=$($DATES --date="Mon Feb 28 01:02:03 $TIMEZONE_NAME 2012" --informat="$INFORMAT" --format="%d" -2:2 d)
[ "$results" = "26 27 28 29 01" ] || die "failed! returned <$results>"

echo "  daylight savings tests:"

# You have to calculate the timezone very carefully for the input!
tz=$($DATES --date="2012-03-11" --informat="%Y-%m-%d" --format="%Z")
results=$($DATES --date="Sun Mar 11 01:02:03 $tz 2012" --informat="$INFORMAT" --format="%H" -1:2 H)
[ "$results" = "00 01 03 04" ] || die "failed! returned <$results>"

tz=$($DATES --date="2012-11-04" --informat="%Y-%m-%d" --format="%Z")
results=$($DATES --date="Sun Nov 04 01:02:03 $tz 2012" --informat="$INFORMAT" --format="%H" -1:2 H)
[ "$results" = "00 01 01 02" ] || die "failed! returned <$results>"

exit 0