#!/usr/bin/env bash
#---------------------------------
# test-common.sh - Tests of common.sh and other support scripts.

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

save_exit="$EXIT"
EXIT=fake-exit
echo "  die test:"
msg=$(die 'LINE 1' 'LINE 2' 2>&1)
EXIT="$save_exit"
case "$msg" in
	*ALERT*test-common.sh:?die?called:?LINE?1?LINE?2)
		;;
	*)
	  die "die test failed! (msg = <$msg>)"
	  ;;
esac

echo "  true-or-false test:"
for x in "t" ""
do
		answer=$(true-or-false $x "true" "false")
		case $answer in
				true)
						[ "$x" != "t" ] && die "true-or-false test with true failed! Answer was $answer"
						;;
				false)
						[ "$x" != "" ] && die "true-or-false test with false failed! Answer was $answer"
						;;
		esac
done

echo "  success-or-failure test:"
for x in 0 1
do
		answer=$(success-or-failure $x "yes" "no")
		case $answer in
				yes)
						[ $x -ne 0 ] && die "success-or-failure test with 0 failed! Answer was $answer"
						;;
				no)
						[ $x -ne 1 ] && die "success-or-failure test with 1 failed! Answer was $answer"
						;;
		esac
done

echo "  ymd test:"
ymd1=$(ymd)
[ "$ymd1" = "20121120"   ] || die "$ymd1 != 20121120!"
ymd2=$(ymd -)
[ "$ymd2" = "2012-11-20" ] || die "$ymd2 != 2012-11-20!"

echo "  yesterday-ymd test:"
ymd1=$(yesterday-ymd)
[ "$ymd1" = "20121119"   ] || die "<$ymd1> != 20121119!"
ymd2=$(yesterday-ymd -)
[ "$ymd2" = "2012-11-19" ] || die "$ymd2 != 2012-11-19!"

echo "  log-file test:"
logfile=$(log-file)
expected="./logs/test-$YEAR$MONTH$DAY-$HOUR$MINUTE$SECOND.log"
[ "$logfile" = "$expected" ] || die "$logfile != $expected"

echo "  to-seconds test:"
to_seconds_strings=('' 0 0s 0m 0h 1 1s 1m 1h 20 20s 20m 20h)
to_seconds_ns=(0 0 0 0 0 1 1 60 3600 20 20 1200 72000)
for i in {0..12}
do
	let answer=$(to-seconds ${to_seconds_strings[$i]})
	let expected=${to_seconds_ns[$i]}
	[ $answer -eq $expected ] || die "to-seconds test failed: <$answer> != <$expected> for string ${to_seconds_strings[$i]}."
done

echo "  to-time-interval test:"
to_time_interval_strings=('' 0 0s 0m 0h 1 1s 1m 1h 20 20s 20m 20h)
to_time_interval_ns=('0 seconds' '0 seconds' '0 seconds' '0 minutes' '0 hours' 
	'1 second' '1 second' '1 minute' '1 hour'
	'20 seconds' '20 seconds' '20 minutes' '20 hours')
for i in {0..12}
do
	answer=$(to-time-interval ${to_time_interval_strings[$i]})
	expected=${to_time_interval_ns[$i]}
	[ "$answer" = "$expected" ] || die "to-time-interval test failed: <$answer> != <$expected> for string ${to_time_interval_strings[$i]}."
done

msg=$(EXIT=: to-seconds 1d 2>&1)
case $msg in
	*Unsupported?units?for?to-seconds:?d)
		;;
	*)
		die "Failed to return expected error message. (msg = $msg)"
		;;
esac

echo "  waiting test:"
for i in {1..2}
do
	let seconds=$i*2
	# extract just what we want to check:
	msg=$(STAMPEDE_LOG_LEVEL=$(from-log-level INFO) waiting $i 2 "waiting test" 2>&1 | cut -d \( -f 2 | sed -e 's/)//')
	[ "$msg" = "waiting $seconds seconds so far" ] ||	die "waiting test failed! (msg = $msg)"
done

for cmd in "try-for" "try-for-or-die"
do
	echo "  $cmd test:"
	for s in "" s m h
	do
		msg=$(eval $cmd 2 1$s "ls $0 &> /dev/null")
		[ $? -eq 0 ] || die "$cmd failed for arguments "2 1$s"! (msg = $msg)"
	done
done
try-for 2 1 "ls foobar &> /dev/null"
[ $? -ne 0 ] || die "try-for returned 0 even though it should have failed."
DIE=fake-die try-for-or-die 2 1 "ls foobar &> /dev/null" &> /dev/null
[ $? -ne 0 ] || die "try-for-or-die returned 0 even though it should have failed."

let end=$(dates --format "%s" 1:1 5 S)
for cmd in "try-until" "try-until-or-die"
do
	echo "  $cmd test:"
	msg=$(eval $cmd $end 2s "ls $0 &> /dev/null")
	[ $? -eq 0 ] || die "$cmd failed for arguments \"$end 1s\"! (msg = $msg)"
done
try-until $end 1 "ls foobar &> /dev/null"
[ $? -ne 0 ] || die "try-until returned 0 even though it should have failed."
DIE=fake-die try-until-or-die $end 1 "ls foobar &> /dev/null" &> /dev/null
[ $? -ne 0 ] || die "try-until-or-die returned 0 even though it should have failed."

STAMPEDE_LOG_LEVEL=$save_level
