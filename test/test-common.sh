#!/usr/bin/env bash
#---------------------------------
# test-common.sh - Tests of the common.sh file

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

save_exit="$EXIT"
EXIT=fake_exit
echo "  die test:"
msg=$(die 'LINE 1' 'LINE 2' 2>&1)
EXIT="$save_exit"
if [ "$msg" != " FATAL test-common.sh: die called: LINE 1 LINE 2" ]
then
	  die "die test failed! (msg = <$msg>)"
fi

echo "  true_or_false test:"
for x in "t" ""
do
		answer=$(true_or_false $x "true" "false")
		case $answer in
				true)
						[ "$x" != "t" ] && die "true_or_false test with true failed! Answer was $answer"
						;;
				false)
						[ "$x" != "" ] && die "true_or_false test with false failed! Answer was $answer"
						;;
		esac
done

echo "  ymd test:"
ymd1=$(ymd)
[ "$ymd1" = "20121120"   ] || die "$ymd1 != 20121120!"
ymd2=$(ymd -)
[ "$ymd2" = "2012-11-20" ] || die "$ymd2 != 2012-11-20!"

echo "  yesterday_ymd test:"
ymd1=$(yesterday_ymd)
[ "$ymd1" = "20121119"   ] || die "<$ymd1> != 20121119!"
ymd2=$(yesterday_ymd -)
[ "$ymd2" = "2012-11-19" ] || die "$ymd2 != 2012-11-19!"

echo "  log_file test:"
logfile=$(log_file)
expected="./logs/test-$YEAR$MONTH$DAY-$HOUR$MINUTE$SECOND.log"
[ "$logfile" = "$expected" ] || die "$logfile != $expected"

echo "  check_failure test:"
ls $0 >& /dev/null
check_failure "check_failure test should pass" >& /dev/null

save_die=$DIE
DIE=fake_die
ls foobar >& /dev/null
msg=$(check_failure "check_failure test should fail" 2>&1)
if [ "$msg" != "check_failure test should fail failed! (status = 1)" ]
then
	DIE=$save_die
	die "check_failure test should fail, but didn't. (msg = $msg)"
fi
DIE=$save_die

echo "  to_seconds test:"
strings=('' 0 0s 0h 1 1s 1m 1h 20 20s 20m 20h)
ns=(0 0 0 0 1 1 60 3600 20 20 1200 72000)
for i in {0..11}
do
	let answer=$(to_seconds ${strings[$i]})
	let expected=${ns[$i]}
	[ $answer -eq $expected ] || die "to_seconds test failed: <$answer> != <$expected> for string ${strings[$i]}."
done

save_exit=$EXIT
EXIT=":"
msg=$(to_seconds 1d 2>&1)
case $msg in
	*Unsupported?units?for?to_seconds:?d)
		;;
	*)
		EXIT=$save_exit
		die "Failed to return expected error message. (msg = $msg)"
		;;
esac
EXIT=$save_exit

echo "  waiting test:"
for i in {1..2}
do
	let seconds=$i*2
	# extract just what we want to check:
	msg=$(waiting $i 2 "waiting test" 2>&1 | cut -d \( -f 2 | sed -e 's/)//')
	[ "$msg" = "waiting $seconds seconds so far" ] ||	die "waiting test failed! (msg = $msg)"
done

for cmd in try_for try_for_or_die
do
	echo "  $cmd test:"
	for s in "" s m h
	do
		msg=$(eval $cmd 2 1$s "ls $0 &> /dev/null")
		[ $? -eq 0 ] || die "$cmd failed for arguments "2 1$s"! (msg = $msg)"
	done
done
try_for 2 1 "ls foobar &> /dev/null"
[ $? -ne 0 ] || die "try_for returned 0 even though it should have failed."
DIE=fake_die try_for_or_die 2 1 "ls foobar &> /dev/null" &> /dev/null
[ $? -ne 0 ] || die "try_for returned 0 even though it should have failed."

let end=$($STAMPEDE_HOME/bin/date.sh --format "%s" 1:1 5 S)
for cmd in try_until try_until_or_die
do
	echo "  $cmd test:"
	msg=$(eval $cmd $end 2s "ls $0 &> /dev/null")
	[ $? -eq 0 ] || die "$cmd failed for arguments \"$end 1s\"! (msg = $msg)"
done
try_until $end 1 "ls foobar &> /dev/null"
[ $? -ne 0 ] || die "try_until returned 0 even though it should have failed."
DIE=fake_die try_until_or_die $end 1 "ls foobar &> /dev/null" &> /dev/null
[ $? -ne 0 ] || die "try_until returned 0 even though it should have failed."
