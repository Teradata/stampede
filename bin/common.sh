# Common functions, etc. used by the other scripts.

# Pull in environment variable definitions. 
# ASSUMES that STAMPEDE_HOME is defined.
. $STAMPEDE_HOME/bin/env.sh

# Override for tests.
: ${DIE:=die}
export DIE=die

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


function log_file {
	echo "$STAMPEDE_LOG_DIR/$STAMPEDE_LOG_FILE"
}

function to_log_level {
	case $1 in
		1)  echo "DEBUG"   ;;
		2)  echo "INFO"    ;;
		3)  echo "WARNING" ;;
		4)  echo "ERROR"   ;;
		5)  echo "FATAL"   ;;
		*)  $DIE 1 "Unrecognized log level $1!" ;;
	esac
}

function init_log_file {
	mkdir -p $STAMPEDE_LOG_DIR
	touch $(log_file)
}

function log {
	let level=$1
	if [ $level -ge $STAMPEDE_LOG_LEVEL ]
	then
		level_str=$(to_log_level $level)
		shift
		if [ -z "$STAMPEDE_LOG_TIME_FORMAT" ]
		then
			d=$(date)
		else
			d=$(date "$STAMPEDE_LOG_TIME_FORMAT")
		fi
		init_log_file
		args="$@"
		printf "%s %-7s %-10s %s\n" "$d" $level_str "$(basename $0):" "$args" | tee -a $(log_file)
	fi
}
function debug {
	log 1 "$@"
}
function info {
	log 2 "$@"
}
function warn {
	log 3 "$@"
}
function warning {  # alias for warn
	warn "$@"
}
# It doesn't exit...
function error {
	log 4 "$@"
}
# It doesn't exit...
function fatal {
	log 5 "$@"
}

: ${EXIT:=kill -TERM $$}  # overrideable for testing

function die {
	let status=$1
	shift
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
	$DIE   $status "Exiting..."
}

trap "handle_signal" SIGHUP SIGINT 

function check_failure {
	let status=$1
	name=$2
	if [ $status != 0 ]
	then
		$DIE $status "$name failed!"
	else
		info "$name succeeded!"
	fi
}

function waiting {
	tries=$1
	message=$2

	if [ $tries -le 5 -o $(expr $tries % 5) = 0 ]
	then
		info "$message (waiting $tries minutes so far)"
	fi
	sleep 60
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

# Helper used for verbose output. For example:
#   info '  X succeeded?  $(succeeded $? "yes" "no")'
function succeeded {
	if [ $1 -ne 0 ]
	then
		echo $3
	else
		echo $2
	fi
}

# Test for the existence of a file or directory, in local or HDFS,
# based on whether or not "$using_local" is defined or not.
# function test_file {
# 		if [ "$using_local" = "" ]
# 		then
# 				test "$verbose" -gt 1 && info "existence test: hadoop dfs -test $@"
# 				hadoop dfs -test "$@"
# 		else
# 				test "$verbose" -gt 1 && info "existence test: test $@"
# 				test "$@"
# 		fi
# }
