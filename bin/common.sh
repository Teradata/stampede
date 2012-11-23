# Common functions, etc. used by the other scripts.
# Notes:
#  1) Variables like DIE and EXIT are used so it's easy to replace calls
#     "die" and "exit" with test substitutes. See, e.g., test/test-common.sh

# Pull in environment variable definitions. 
# ASSUMES that STAMPEDE_HOME is defined.
. $STAMPEDE_HOME/bin/env.sh
. $STAMPEDE_HOME/bin/log.sh

# If a delimiter isn't specified, you'll get "YYYYMMDD".
function ymd { 
	delimiter=$1
	echo $YEAR$delimiter$MONTH$delimiter$DAY;     
}

# Computing the day before ymd.
# If a delimiter isn't specified, you'll get "YYYYMMDD".
function yesterday_ymd { 
	delimiter=$1
	fmt=""%Y$delimiter%m$delimiter%d""
	$STAMPEDE_HOME/bin/date.sh --date $(ymd $delimiter) \
		--informat "$fmt" --format "$fmt" -1:-1 d
}

function die {
	fatal "die called:" "$@"
	if [ "$STAMPEDE_DISABLE_ALERT_EMAILS" = "" ]
	then
		info "Sending email to $STAMPEDE_ALERT_EMAIL_ADDRESS" 
		$STAMPEDE_HOME/bin/send-email.sh "FATAL" \
			"$STAMPEDE_ALERT_EMAIL_ADDRESS" \
			"$0 did not complete successfully." \
			"Error message: $@." \
      "See $(log_file) for details."
	fi
  $EXIT
}

function handle_signal {
	let status=$?
	trap "" SIGHUP SIGINT 
	status_name=$(kill -l $status >& /dev/null || echo "<unknown>")
	fatal "******* $0 failed, signal ($status - ) received."
	fatal "  See Log file $(log_file) for more in_formation."
	fatal "  (Current directory: $PWD)"
	$DIE   "Exiting..."
}

trap "handle_signal" SIGHUP SIGINT 

function check_failure {
	let status=$?
	if [ $status != 0 ]
	then
		$DIE "$@ failed! (status = $status)"
	else
		info "$@ succeeded!"
	fi
}

# Accepts an argument such as "20x", where "x" is one of hms, with "s" as the 
# default and returns the corresponding number of seconds.
# Note: We don't support days, months, and years, because then you would have 
# to specify a date to know the context!
function to_seconds {
	nn=$(echo $1 | sed -e 's/[^0-9]\+//')
	units=$(echo $1 | sed -e 's/[0-9]\+//')
	if [ -z "$nn" ]
	then
		let n=0
	else
		let n=$nn
	fi
	if [ -z "$units" -o "$units" = "s" ]
	then
		echo $n
	else
		case $units in
			m)  
				let n2=$n*60
				echo $n2
				;;
			h)  
				let n2=$n*3600
				echo $n2
				;;
			*)
				die "Unsupported units for to_seconds: $units"
				;;
		esac
	fi
}

function waiting {
	tries=$1
	shift
	sleep_interval=$1
	shift

	if [ $tries -le 5 -o $(expr $tries % 5) = 0 ]
	then
		let seconds=$tries*$sleep_interval
		info "$@ (waiting $seconds seconds so far)"
	fi
	sleep $sleep_interval
}

# Helper used for verbose output. For example:
#   info '  X is on?  $(true_or_false "$x_flag" "on" "off")'
# will log "on" if $x_flag is not empty, otherwise "off".
function true_or_false {
	if [ "$1" = "" ]
	then
		echo $3
	else
		echo $2
	fi
}

# Helper for try_for and try_until.
function _do_try {
	name=$1
	shift
	let end=$1
	shift
	let retry_every=$(to_seconds $1)
	shift
	let die_on_timeout=$1
	shift
	start=$(date +"$STAMPEDE_TIME_FORMAT")

	# Compute the times in epoch seconds
	eval "$@"
	while [ $? -ne 0 ]
	do
		let now=$(date +"%s")
		if [ $now -gt $end ]
		then
			[ "$die_on_timeout" -ne 0 ] && $DIE "$name(): Waiting timed out!"
			return 1
		fi
		sleep $retry_every 
		eval "$@"
	done
}

# Helper for the try_for*.
function _do_try_for {
	let should_die=$1
	shift
	let wait_time=$(to_seconds $1)
	shift
	retry_every=$1
	shift
	let now=$(date +"%s")
	let end=$($STAMPEDE_HOME/bin/date.sh --date "$now" --informat "%s" --format "%s" 1:1 $wait_time S)
	name=try_for
	[ $should_die -eq 1 ] && name=${name}_or_die
	_do_try $name $end $retry_every $should_die "$@"
}

# Helper for the try_until*.
function _do_try_until {
	let should_die=$1
	shift
	let end=$1
	shift
	retry_every=$1
	shift
	name=try_until
	[ $should_die -eq 1 ] && name=${name}_or_die
	_do_try $name $end $retry_every $should_die "$@"
}

# Wait for an expression to succeed for a specified time period from now.
# The first argument is the amount of time to wait in seconds, or append one of 
# the characters 'h', 'm', or 's' to interpret the number as hours, minutes, or
# seconds.
# The second argument is how long to wait between attempts in seconds or "Nx", 
# where x is one of hms.
# The remaining arguments are the bash expression to try on every iteration. 
# It must return a status of 0 when evaluated to indicate success and nonzero for
# failure. For example, "ls foo" returns 1 unless "foo" exists, in which case
# it returns 0.
# If the wait times out 1 is returned.
# NOTE: The process will sleep between attempts.
# See also the other try_* functions.
function try_for {
	_do_try_for 0 "$@"
}

# Like "try_for", but will die if the waiting times out.
function try_for_or_die {
	_do_try_for 1 "$@"
}

# Wait for an expression to succeed until a specified time.
# The first argument is the point in time when waiting will stop,
# specified in epoch seconds. 
# The second argument is how long to wait between attempts in seconds or "Nx", 
# where x is one of hms.
# The remaining arguments are the bash expression to try on every iteration. 
# It must return a status of 0 when evaluated to indicate success and nonzero for
# failure. For example, "ls foo" returns 1 unless "foo" exists, in which case
# it returns 0.
# If the wait times out 1 is returned.
# NOTE: The process will sleep between attempts.
# See also the other try_* functions.
function try_until {
	_do_try_until 0 "$@"
}

# Like "try_until", but will die if the waiting times out.
function try_until_or_die {
	_do_try_until 1 "$@"
}
