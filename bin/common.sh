#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# common.sh - Common functions, etc. used by the other scripts.
# Notes:
#  1) Variables like DIE and EXIT are used so it's easy to replace calls
#     "die" and "exit" with test substitutes. See, e.g., test/test-common.sh

# Prevent rescanning, if that happens...
[ -n "$_STAMPEDE_COMMON_SH_READ" ] && return 0
_STAMPEDE_COMMON_SH_READ=true

# Pull in environment variable definitions. 
# ASSUMES that STAMPEDE_HOME is defined.
thisdir=$(dirname $BASH_SOURCE)
. $thisdir/env.sh
. $thisdir/log.sh

init_log_file

# Like echo, but writes to stderr, instead of stdout.
function echo2 {
  echo "$@" 1>&2
}

# Add custom, bin, and contrib under $STAMPEDE_HOME, plus any of their
# subdirectories, to the PATH. 
function path_elements {
	for d in custom bin contrib 
	do
		if [ -d $STAMPEDE_HOME/$d ]
		then
			find $STAMPEDE_HOME/$d -type d | while read d2
			do
				echo -n "$d2:"
			done
		fi
	done
}

export PATH=$(path_elements)$PATH

function die {
	alert "die called:" "$@"
	if [ $STAMPEDE_DISABLE_ALERT_EMAILS -eq 0 ]
	then
		info "Sending email to $STAMPEDE_ALERT_EMAIL_ADDRESS" 
		send-email "ALERT" "$STAMPEDE_ALERT_EMAIL_ADDRESS" \
			"$0 did not complete successfully." <<EOF
Error message: $@.
See $STAMPEDE_LOG_FILE for details.
EOF
	fi
  $EXIT
}

function handle_signal {
	let status=$?
	trap "" SIGHUP SIGINT 
	status_name=$(kill -l $status >& /dev/null || echo "<unknown>")
	alert "******* $0 failed, signal ($status - ) received."
	alert "  See Log file $STAMPEDE_LOG_FILE for more in_formation."
	alert "  (Current directory: $PWD)"
	$DIE   "Exiting..."
}

trap "handle_signal" SIGHUP SIGINT 

# Helper for try-for and try_until.
function _do_try {
	let end=$1
	shift
	let retry_every=$(to-seconds $1)
	shift
	start=$(date +"$STAMPEDE_TIME_FORMAT")

	# Compute the times in epoch seconds
	eval "$@"
	while [ $? -ne 0 ]
	do
		let now=$(date +"%s")
		[ $now -gt $end ] && return 1
		sleep $retry_every 
		eval "$@"
	done
}
