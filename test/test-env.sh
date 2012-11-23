#!/usr/bin/env bash
#---------------------------------
# test-env.sh - Tests of the env.sh file

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

echo "  YEAR, MONTH, etc. tests:"
export STAMPEDE_START_TIME="2012-11-20 01:02:03"
[ "$YEAR"   = "2012" ] || die YEAR
[ "$MONTH"  = "11"   ] || die MONTH
[ "$DAY"    = "20"   ] || die DAY
[ "$HOUR"   = "01"   ] || die HOUR
[ "$MINUTE" = "02"   ] || die MINUTE
[ "$SECOND" = "03"   ] || die SECOND
[ "$EPOCH_SECOND" = "1353394923" ] || die EPOCH_SECOND

echo "  DAY_OF_WEEK* tests:"
[ "$DAY_OF_WEEK_NUMBER" = "2"    ] || die DAY_OF_WEEK_NUMBER
[ "$DAY_OF_WEEK_ABBREV" = "Tue"  ] || die DAY_OF_WEEK_ABBREV
[ "$DAY_OF_WEEK" = "Tuesday"     ] || die DAY_OF_WEEK

echo "  time_fields test:"
msg=$(time_fields %s)
[ "$msg" = "1353394923" ] || die "$msg"