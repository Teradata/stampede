#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-env.sh - Tests of the environment variables.

TEST_DIR=$(dirname ${BASH_SOURCE[0]})
. $TEST_DIR/setup.sh

echo "  YEAR, MONTH, etc. tests:"

[ "$YEAR"   = "2012" ] || die "YEAR: expected <2012> != actual <$YEAR>"
[ "$MONTH"  = "11"   ] || die "MONTH: expected <11> != actual <$MONTH>"
[ "$DAY"    = "20"   ] || die "DAY: expected <20> != actual <$DAY>"
[ "$HOUR"   = "01"   ] || die "HOUR: expected <01> != actual <$HOUR>"
[ "$MINUTE" = "02"   ] || die "MINUTE: expected <02> != actual <$MINUTE>"
[ "$SECOND" = "03"   ] || die "SECOND: expected <03> != actual <$SECOND>"
[ "$YEAR_MINUS_1_DAY"  = "2012" ] || die "YEAR_MINUS_1_DAY: expected <2012> != actual <$YEAR_MINUS_1_DAY>"
[ "$MONTH_MINUS_1_DAY" = "11"   ] || die "MONTH_MINUS_1_DAY: expected <11> != actual <$MONTH_MINUS_1_DAY>"
[ "$DAY_MINUS_1_DAY"   = "19"   ] || die "DAY_MINUS_1_DAY: expected <19> != actual <$DAY_MINUS_1_DAY>"
# Because of issue where we have to use the same timezone as the
# current machine, we can't assume a particular value of the
# epoch seconds, so we calculate it here:
es=$($STAMPEDE_HOME/bin/dates --date="$STAMPEDE_START_TIME" --informat="$STAMPEDE_TIME_FORMAT" --format="%s")
[ "$EPOCH_SECOND" = "$es" ] || die "EPOCH_SECOND: expected <$es> != actual <$EPOCH_SECOND>"

echo "  DAY_OF_WEEK* tests:"
[ "$DAY_OF_WEEK_NUMBER" = "2"    ] || die "DAY_OF_WEEK_NUMBER: expected <2> != actual <$DAY_OF_WEEK_NUMBER>"
[ "$DAY_OF_WEEK_ABBREV" = "Tue"  ] || die "DAY_OF_WEEK_ABBREV: expected <Tue> != actual <$DAY_OF_WEEK_ABBREV>"
[ "$DAY_OF_WEEK" = "Tuesday"     ] || die "DAY_OF_WEEK: expected <Tuesday> != actual <$DAY_OF_WEEK>"

echo "  time_fields test:"
actual=$(time_fields %s)
expected=$($STAMPEDE_HOME/bin/dates --date="$STAMPEDE_START_TIME" --informat="$STAMPEDE_TIME_FORMAT" --format="%s")
[ "$actual" = "$expected" ] || die "time_fields: expected <$expected> != actual <$actual>"


echo "  calling a script outside the context of 'stampede' test:"
( e=$STAMPEDE_HOME/bin/env.sh; STAMPEDE_HOME= bash $e) | ( read line
  [[ $line =~ STAMPEDE_HOME.is.not.defined ]] || die "env.sh should have died when STAMPEDE_HOME is not defined! line = <$line>" )
