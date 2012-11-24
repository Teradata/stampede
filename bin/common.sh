# Common functions, etc. used by the other scripts.
# Notes:
#  1) Variables like DIE and EXIT are used so it's easy to replace calls
#     "die" and "exit" with test substitutes. See, e.g., test/test-common.sh

# Pull in environment variable definitions. 
# ASSUMES that STAMPEDE_HOME is defined.
thisdir=$(dirname $BASH_SOURCE)
. $thisdir/env.sh
. $thisdir/log.sh
export PATH=$thisdir:$PATH


function die {
	alert "die called:" "$@"
	if [ $STAMPEDE_DISABLE_ALERT_EMAILS -eq 0 ]
	then
		info "Sending email to $STAMPEDE_ALERT_EMAIL_ADDRESS" 
		$STAMPEDE_HOME/bin/send-email "ALERT" \
			"$STAMPEDE_ALERT_EMAIL_ADDRESS" \
			"$0 did not complete successfully." <<EOF
Error message: $@.
See $(log-file) for details.
EOF
	fi
  $EXIT
}

function handle_signal {
	let status=$?
	trap "" SIGHUP SIGINT 
	status_name=$(kill -l $status >& /dev/null || echo "<unknown>")
	alert "******* $0 failed, signal ($status - ) received."
	alert "  See Log file $(log-file) for more in_formation."
	alert "  (Current directory: $PWD)"
	$DIE   "Exiting..."
}

trap "handle_signal" SIGHUP SIGINT 

# Helper for try-for* and try_until*.
function _do_try {
	name=$1
	shift
	let end=$1
	shift
	let retry_every=$(to-seconds $1)
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

# Helper for the try-for*.
function _do_try_for {
  let should_die=$1
  shift
  let wait_time=$(to-seconds $1)
  shift
  retry_every=$1
  shift
  let now=$(date +"%s")
  let end=$($STAMPEDE_HOME/bin/dates --date "$now" --informat "%s" --format "%s" 1:1 $wait_time S)
  name=try-for
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
