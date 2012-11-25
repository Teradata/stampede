#!/usr/bin/env bash
#---------------------------------
# test-dates.sh - Tests of bin/dates.

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

# Dates is fairly complicated. This test is not as comprehensive as it could be.

DATES=$TEST_DIR/../bin/dates

echo "  range tests:"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%Y-%m-%d %H:%M:%S" -1:-1 d)
[ "$results" = "2012-11-19 01:02:03" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%Y-%m-%d %H:%M:%S" -2:-1 d)
[ "$results" = "2012-11-18 01:02:03 2012-11-19 01:02:03" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%Y-%m-%d %H:%M:%S" 0:0 d)
[ "$results" = "2012-11-20 01:02:03" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%Y-%m-%d %H:%M:%S" 1:2 d)
[ "$results" = "2012-11-21 01:02:03 2012-11-22 01:02:03" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%Y-%m-%d %H:%M:%S")
[ "$results" = "2012-11-20 01:02:03" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%d" -2:)
[ "$results" = "18 19 20" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%d" :2)
[ "$results" = "20 21 22" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%d" :-2)
[ "$results" = "20 19 18" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%d" 2:)
[ "$results" = "22 21 20" ] || die "failed! returned <$results>"

echo "  separator tests:"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%d" --sep '|' 2:)
[ "$results" = "22|21|20" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%d" --sep '' 2:)
[ "$results" = "222120" ] || die "failed! returned <$results>"

# Handles \n as a separator?
expected=$(for i in {22..20}; do echo $i; done)
results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%d" --sep '\n' 2:)
[ "$results" = "$expected" ] || die "failed! returned <$results>, expected = <$expected>"

echo "  time delta tests:"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%Y" -1:1 y)
[ "$results" = "2011 2012 2013" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%m" -1:1 m)
[ "$results" = "10 11 12" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%d" -1:1 w)
[ "$results" = "13 20 27" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%d" -1:1 d)
[ "$results" = "19 20 21" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%H" -1:1 H)
[ "$results" = "00 01 02" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%M" -1:1 M)
[ "$results" = "01 02 03" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%S" -1:1 S)
[ "$results" = "02 03 04" ] || die "failed! returned <$results>"

results=$($DATES --date "2012-11-20 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%s" -1:1 S)
[ "$results" = "1353394922 1353394923 1353394924" ] || die "failed! returned <$results>"


echo "  leap year tests:"

results=$($DATES --date "2011-02-28 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%d" -2:2 d)
[ "$results" = "26 27 28 01 02" ] || die "failed! returned <$results>"
results=$($DATES --date "2012-02-28 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%d" -2:2 d)
[ "$results" = "26 27 28 29 01" ] || die "failed! returned <$results>"

echo "  daylight savings tests:"

results=$($DATES --date "2012-03-11 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%H" -1:2 H)
[ "$results" = "00 01 03 04" ] || die "failed! returned <$results>"
results=$($DATES --date "2012-11-04 01:02:03" --informat "%Y-%m-%d %H:%M:%S" --format "%H" -1:2 H)
[ "$results" = "00 01 01 02" ] || die "failed! returned <$results>"

exit 0