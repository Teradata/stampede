#!/usr/bin/env bash
#----------------------------------
# date.sh - Mac/Linux date formatting and calculation tool.
# usage:  date.sh [--help] options
# This script wraps the different date tools on Mac and Linux.
# TODO: support Cygwin's version of date.

function help {
		cat <<EOF
usage: date.sh [--help] [--today | --date date [--informat fmt]] [--format fmt] [--sep separator] [M:N [units]]"
where:"
  --help          This message.
  --today         Use today's date as the starting date.
  --date date     Use date as the starting date. MUST use the same format as the format option.
  --informat fmt  Format the --date date using fmt (ignored if --today is used,
                  required unless --format is used and the input date uses the same format).
                  Useful when the input date has a different format than desired.
                  Omit the "+" at the beginning of the string, which the date command would require.
  --format fmt    Format the output date(s) using fmt.
  --sep separator Separate output dates by "separator" (default: " ").
  M:N             Calculate one or more "units" (default unit: 1 day), based on this interpretation of M:N:
    M:N             Return a range of dates from M days to N days FROM the starting date. 
                    Prefix M or N with a "-" to use days AGO. 
    :N            Start with the starting date, inclusive, i.e., M=0.
    M:            End with the starting date, inclusive, i.e., N=0.
                  Because the M and N are inclusive, the number of dates returned is abs(N-M)+1.
                  Also, if the N < M, the results "count down".
  units           How to interpret the the M:N range. An optional number (default: 1),
                  followed by one of the characters in ymwdHMS.
  If "M:N units" are omitted, the script just reformats the input or today's date.
EOF
}

function die {
	echo "$0: $@"
	help
	kill -QUIT $$
}
separator=" "
date_range="0:0"
let delta=1
units="d"
while [ $# -ne 0 ]
do
	case $1 in 
		-h|--help)
			help
			exit 0
			;;
		-t|--today)
			;;
		-d|--date)
			shift
			start_date=$1
			;;
		-i|--informat)
			shift
			informat=$1
			;;
		-o|--format)
			shift
			out_format=$1
			;;
		-s|--sep*)
			shift
			separator=$1
			;;
		*:*)
			date_range=$1
			;;
		0*|1*|2*|3*|4*|5*|6*|7*|8*|9*)
			let delta=$1
			;;
		y|m|w|d|H|M|S)
			units=$1
			;;
		*)
			die "unrecongized argument: $1"
			;;
	esac
	shift
done

test -n "$informat" || informat=$out_format

if [ ! -n "$start_date" ]
then
	if [ -n "$out_format" ]
	then
		start_date=$(date +$out_format)
		informat=$out_format   # now using same format for both input and output!
	else
		start_date=$(date)
	fi
fi

case $date_range in
	*:*)  ;;
	*)
		die "Must specify M:N, for the range of dates to return."
		;;
esac


function mac_date {
	start_date=$1
	delta=$2
	units=$3
	informat=$4
	outformat=$5

	if [ ! -n "$informat" ]
	then
		die "For Mac, must specify an input or output format."
	fi
	if [ -n "$outformat" ]
	then
		# echo date -j -v${delta}${units} -f "$informat" "$start_date" +"$outformat" 1>&2
		date -j -v${delta}${units} -f "$informat" "$start_date" +"$outformat"
	else
		date -j -v${delta}${units} -f "$informat" "$start_date"
	fi
}

function linux_date {
	start_date=$1
	delta=$2
	units=$3
	informat=$4
	outformat=$5
	
	case $units in
		y) units="year ago"   ;;
		m) units="month ago"  ;;
		d) units="day ago"    ;;
		H) units="hour ago"   ;;
		M) units="minute ago" ;;
		S) units="second ago" ;;
	esac

	if [ -n $out_format ]
	then
		date --date="$start_date $delta $units" +"$out_format"
	else
		date --date="$start_date $delta $units"
	fi
}

# Determine which date command we're using.
# TODO: Cygwin??
function mac_or_linux_date {
	case $(uname) in
		Darwin)
			mac_date "$@"
			;;
		*)
			linux_date "$@"
			;;
	esac				
}


start=${date_range%:*}
end=${date_range#*:}
test -n "$start" || start=0
test -n "$end"   || end=0

set=
for delta2 in $(eval "echo {$start..$end}")
do 
	let delta3=$delta2*$delta
	case $delta3 in
		-*)
			;;
		*)
			delta3="+$delta3"
			;;
	esac
	echo -n "$sep$(mac_or_linux_date "$start_date" "$delta3" $units "$informat" "$out_format")"
	sep=$separator
done
echo ""
