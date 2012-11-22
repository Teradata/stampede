#!/usr/bin/env bash
#---------------------------------
# test-common.sh - Tests of the common.sh file

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

. $STAMPEDE_HOME/bin/common.sh

save_exit="$EXIT"
export EXIT=echo
echo "  Starting die test:"
die 5 'LINE 1' 'LINE 2' > $STAMPEDE_LOG_DIR/die.log
grep -q 'FATAL.*test-common.*LINE [12]' $STAMPEDE_LOG_DIR/die.log
status=$?
if [ $status -ne 0 ]
then
  echo "die test failed! Here is the output:"
	cat $STAMPEDE_LOG_DIR/die.log
	rm $STAMPEDE_LOG_DIR/die.log
	exit 1
fi
rm $STAMPEDE_LOG_DIR/die.log
export EXIT="$save_exit"

echo "  Starting true_or_false test:"
for x in "t" ""
do
		answer=$(true_or_false $x "true" "false")
		case $answer in
				true)
						[ "$x" != "t" ] && die 1 "true_or_false test with true failed! Answer was $answer"
						;;
				false)
						[ "$x" != "" ] && die 1 "true_or_false test with false failed! Answer was $answer"
						;;
		esac
done

echo "  Starting ymd test:"
ymd1=$(ymd)
[ "$ymd1" = "20121120"   ] || die 1 "$ymd1 != 20121120!"
ymd2=$(ymd -)
[ "$ymd2" = "2012-11-20" ] || die 1 "$ymd2 != 2012-11-20!"

echo "  Starting yesterday_ymd test:"
ymd1=$(yesterday_ymd)
[ "$ymd1" = "20121119"   ] || die 1 "<$ymd1> != 20121119!"
ymd2=$(yesterday_ymd -)
[ "$ymd2" = "2012-11-19" ] || die 1 "$ymd2 != 2012-11-19!"

echo "  Starting log_file test:"
logfile=$(log_file)
expected="./logs/test-$YEAR$MONTH$DAY-$HOUR$MINUTE$SECOND.log"
[ "$logfile" = "$expected" ] || die 1 "$logfile != $expected"

echo "  Starting to_log_level test:"
save_dir=$DIE
export DIE=echo
for i in -1 0 6
do
	if [ "$(to_log_level $i)" != "1 Unrecognized log level $i!" ]
	then
		export DIE=$save_dir
		die 1 "to_log_level failed for -1"
	fi
done
names=(DEBUG INFO WARNING ERROR FATAL)
for i in {0..4}
do 
	let ii=i+1
	if [ "$(to_log_level $ii)" != "${names[$i]}" ]
	then
		export DIE=$save_dir
		die "to_log_level failed for $ii. Expected ${names[$i]}" 
	fi
done
export DIE=$save_dir
