# Common environment variables that drive a stampede. 
# Some are designed to be overridden on the command line for testing, etc.
# Copyright (c) 2011-2012, Think Big Analytics. See the LICENSE.txt file
# included with this distribution.
#------------------------------------------------------------------------------
# bin/env.sh -
# Environment variable definitions used by Stampede.
# You can also override any values you choose in a configuration file.
# Stampede searches for the following files, in the order shown: 
#   /etc/stampederc
#   /etc/sysconfig/stampede
#   $HOME/.stampederc
#   /my/project/home/.stampederc 
# The different /etc directories and file name conventions listed are intended
# to support the conventions of different Linux distributions, OSX, and Cygwin.
# If two or more of these files define the same variable, the last definition 
# will be used. Note that the project-specific definitions should go in the last
# file, "$(dirname $0)/.stampederc", which will be in the same directory as the 
# driver stampede.sh script.
# There are some variables that SHOULD be defined in one of these files,
# because they are unique to each environment. See the example definitions in
# $STAMPEDE_HOME/examples/stampederc. Defaults will be used here.
# This file is included automatically in $STAMPEDE_HOME/bin/common.sh.
# NOTES: 
#   1. All environment variables are tested first to see if they already
#      exist. This is useful for cases where you need to provide custom definitions
#      before the defaults are defined here. Just be sure to define and export those
#      settings before common.sh is sources.

# This Stampede Project (workflow). Typically the same as the project root
# directory name, defined as PROJECT_DIR in the "stampede" driver script from
# the directory containing the specified makefile, e.g., "myproject" for
# "/home/me/myproject/Makefile". We first test for PROJECT_DIR="", which will 
# happen when a support script is run independently. In this case we use $PWD.
# You can define a particular value in an appropriate .stampederc file if you 
# prefer. 
[ -z "$PROJECT_DIR" ] && PROJECT_DIR=$PWD
if [ -z "$STAMPEDE_PROJECT" ]
then
  STAMPEDE_PROJECT=$(basename $PROJECT_DIR)
  [ "$STAMPEDE_PROJECT" = "." ] && STAMPEDE_PROJECT=$(basename $PWD)
fi
export STAMPEDE_PROJECT

# Verify that STAMPEDE_HOME is defined. It is if this script is sourced from
# the stampede driver script, but not from other support scripts.
if [ -z "$STAMPEDE_HOME" ]
then
  _sdir=$(dirname $0)
  [ "$_sdir" = '.' ] && _sdir=$PWD
  STAMPEDE_HOME=$(dirname $_sdir)
  [ "$STAMPEDE_HOME" = '.' ] && STAMPEDE_HOME=$PWD
fi
export STAMPEDE_HOME

for f in /etc/stampederc /etc/sysconfig/stampede $HOME/.stampederc $STAMPEDE_PROJECT/.stampederc
do
  [ -f "$f" ] && . "$f"
done

this_dir=$(dirname $BASH_SOURCE)

# -- Date/time variables:

# Override for testing:
export DATE=date

# The linux date command accepts limited formats when doing arithmetic. So, this is
# what we use for all calls to the "bin/dates" script.
# NOTE: Unfortunately, this format does NOT sort lexicographically!
: ${STAMPEDE_RFC_3999_TIME_FORMAT:="%a %b %d %H:%M:%S %Z %Y"}

# Time string format: mostly used internally. Contrast with STAMPEDE_LOG_TIME_FORMAT.
: ${STAMPEDE_TIME_FORMAT:="$STAMPEDE_RFC_3999_TIME_FORMAT"}
export STAMPEDE_TIME_FORMAT

# Time string format for log file entries. Actually, this "format" can be any option(s)
# for the date command that affect the output format, e.g., -u for UTC format. So, if you
# specify a standard format string, you must include the "+" at the front of it.
# If you want to use date's default format, leave this definition empty.
# NOTE: it's STRONGLY recommended to use a format that sorts lexicographically!
: ${STAMPEDE_LOG_TIME_FORMAT:=+"%Y-%m-%d %H:%M:%S%z"}
export STAMPEDE_LOG_TIME_FORMAT

# It would make more sense in some ways to use the EPOCH_SECONDS as the
# start time, as integer comparisons are most reliable. However, this 
# doesn't work so well with the linux date command, e.g., it doesn't
# understand "--date='1234567890 + 1 day", unfortunately, while 
# "--date='2012-11-20 01:02:03 + 1 day" works fine. :(
: ${STAMPEDE_START_TIME:=$(date +"$STAMPEDE_TIME_FORMAT")}
export STAMPEDE_START_TIME

# The time this script started in epoch seconds (defaults to NOW).
if [ -z "$EPOCH_SECOND" ]
then
  let EPOCH_SECOND=$($STAMPEDE_HOME/bin/dates --date="$STAMPEDE_START_TIME" \
    --informat="$STAMPEDE_TIME_FORMAT" --format="%s")
fi
export EPOCH_SECOND

function start_time {
  echo "$STAMPEDE_START_TIME"
}

# Helper function to extract date fields from STAMPEDE_START_TIME.
function time_fields {
  fields=$1
  $this_dir/dates --date="$STAMPEDE_START_TIME" --informat="$STAMPEDE_TIME_FORMAT" --format="$fields"
}

# Year (YYYY) of STAMPEDE_START_TIME.
: ${YEAR:=$(time_fields "%Y")}
export YEAR

# Month (MM) of STAMPEDE_START_TIME.
: ${MONTH:=$(time_fields "%m")}
export MONTH

# Day (DD) of STAMPEDE_START_TIME.
: ${DAY:=$(time_fields "%d")}
export DAY

# Hour (HH) of STAMPEDE_START_TIME.
: ${HOUR:=$(time_fields "%H")}
export HOUR

# Minute (MM) of STAMPEDE_START_TIME.
: ${MINUTE:=$(time_fields "%M")}
export MINUTE

# Second (SS) of STAMPEDE_START_TIME.
: ${SECOND:=$(time_fields "%S")}
export SECOND

# Number (N) for the day of the week from STAMPEDE_START_TIME,
# where Sunday = 0 and Saturday = 6
: ${DAY_OF_WEEK_NUMBER:=$(time_fields "%w")}

# Three-letter abbreviation for the day of the week from STAMPEDE_START_TIME,
# e.g., "Thu".
: ${DAY_OF_WEEK_ABBREV:=$(time_fields "%a")}

# Full name of the day of the week from STAMPEDE_START_TIME,
# e.g., "Thursday".
: ${DAY_OF_WEEK:=$(time_fields "%A")}

# Timezone (e.g., "-0600") and name (e.g., "CST").
: ${TIMEZONE=$(time_fields "%z")}
export TIMEZONE

: ${TIMEZONE_NAME=$(time_fields "%Z")}
export TIMEZONE_NAME

# -- Logging variables:

# The names and levels of the SYSLOG-compatible log levels.
export STAMPEDE_LOG_LEVEL_NAMES=(EMERGENCY ALERT CRITICAL ERROR WARNING NOTICE INFO DEBUG)
export STAMPEDE_LOG_LEVELS=(0 1 2 3 4 5 6 7)


let STAMPEDE_MIN_LOG_LEVEL=${STAMPEDE_LOG_LEVELS[0]}
let STAMPEDE_MAX_LOG_LEVEL=${STAMPEDE_LOG_LEVELS[${#STAMPEDE_LOG_LEVELS[@]}-1]}
export STAMPEDE_MIN_LOG_LEVEL
export STAMPEDE_MAX_LOG_LEVEL

# Log files location.
# On *nix systems, a more standard option is /var/logs/stampede.
: ${STAMPEDE_LOG_DIR:=$STAMPEDE_HOME/logs}
export STAMPEDE_LOG_DIR

# Log file for this run.
# (Note: we can't use the ymd function defined in common.sh, because it 
# hasn't been defined at this point in the execution!)
: ${STAMPEDE_LOG_FILE:=$STAMPEDE_PROJECT-$YEAR$MONTH$DAY-$HOUR$MINUTE$SECOND.log}
export STAMPEDE_LOG_FILE

# Default logging level. See a description of the options in bin/log.sh.
[ -z "$STAMPEDE_LOG_LEVEL" ] && let STAMPEDE_LOG_LEVEL=5

# A format string used with printf to format the log message string. 
# It should have four "%s" elements, for the date, severity level name, 
# name of the application, and a %s into which all the remaining message
# arguments will be formatted.
# If you need more flexible formatting, define your own formatting function
# "format-log-message" and drop it in the "custom" directory.
: ${STAMPEDE_LOG_MESSAGE_FORMAT_STRING:="%s %-9s (stampede:%s): %s"}
export STAMPEDE_LOG_MESSAGE_FORMAT_STRING

# Set to 0 if you want to use SYSLOG for logging.
if [ -z "$STAMPEDE_LOG_USE_SYSLOG" ] 
then
  let STAMPEDE_LOG_USE_SYSLOG=1
fi
export STAMPEDE_LOG_USE_SYSLOG

# Options to pass to logger(1) for syslog calls.
: ${STAMPEDE_LOG_SYSLOG_OPTIONS:=}
export STAMPEDE_LOG_SYSLOG_OPTIONS

# What to-log-level should return if an invalid argument is specified
# and no default argument is also specified. See "to-log-level --help"
# for details.
: ${STAMPEDE_LOG_DEFAULT_TO_LOG_LEVEL_VALUE:=ERROR}

# What from-log-level should return if an invalid argument is specified
# and no default argument is also specified. See "from-log-level --help"
# for details.
: ${STAMPEDE_LOG_DEFAULT_FROM_LOG_LEVEL_VALUE:=3}

# -- Miscellaneous variables:

# Set to 0 when you want to disable email alerts, e.g., for testing.
# Use any other integer to enable them.
# Assumes that the *nix "mail" command is configured on the server.
if [ -z "$STAMPEDE_DISABLE_ALERT_EMAILS" ]
then
  let STAMPEDE_DISABLE_ALERT_EMAILS=1
fi
export STAMPEDE_DISABLE_ALERT_EMAILS

#The email address to which alerts are sent.
# Assumes that the *nix "mail" command is configured on the server.
: ${STAMPEDE_ALERT_EMAIL_ADDRESS:=root@localhost}
export STAMPEDE_ALERT_EMAIL_ADDRESS


# How long to sleep a process while waiting for something, e.g., before
# trying a step again.
: ${STAMPEDE_DEFAULT_SLEEP_INTERVAL:=60s}
export STAMPEDE_DEFAULT_SLEEP_INTERVAL

# How many attempts to make for the workflow before giving up.
: ${STAMPEDE_NUMBER_OF_TRIES:=5}
export STAMPEDE_NUMBER_OF_TRIES

# Options that are always passed to make. 
#   --jobs    Run as many build tasks in parallel as possible. It's faster,
#             but you have to be more careful about defining dependencies!
# See "man make" for details.
: ${STAMPEDE_MAKE_OPTIONS:=--jobs}
export STAMPEDE_MAKE_OPTIONS

# -- Definitions designed to be overridden in tests.

: ${DIE:=die}
export DIE

: ${EXIT:=kill -TERM $$}
export EXIT

: ${STAMPEDE_LOG_DATE:=date}
export STAMPEDE_LOG_DATE
