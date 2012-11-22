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

# This Stampede Project (workflow). Typically the same as the project root directory. 
# Define this in an appropriate .stampederc file! Here we just use the
# name of the directory where the Makefile was found (effectively...).
if [ -z "$STAMPEDE_PROJECT" ]
then
  STAMPEDE_PROJECT=$(basename $PROJECT_DIR)
  [ "$STAMPEDE_PROJECT" = "." ] && STAMPEDE_PROJECT=$(basename $PWD)
fi
export STAMPEDE_PROJECT

for f in /etc/stampederc /etc/sysconfig/stampede $HOME/.stampederc $STAMPEDE_PROJECT/.stampederc
do
  [ -f "$f" ] && . "$f"
done

this_dir=$(dirname $BASH_SOURCE)

# The operating system name.
: ${OS_NAME:=$(uname -s 2> /dev/null | /usr/bin/tr "[:upper:]" "[:lower:]" 2> /dev/null)}
export OS_NAME

# Time string format for log file entries. Actually, this "format" can be any option(s)
# for the date command that affect the output format, e.g., -u for UTC format. So, if you
# specify a standard format string, you must include the "+" at the front of it.
# If you want to use date's default format, leave this definition empty.
: ${STAMPEDE_LOG_TIME_FORMAT:=""}
export STAMPEDE_LOG_TIME_FORMAT

# Time string format: mostly used internally.
: ${STAMPEDE_TIME_FORMAT:="%Y-%m-%d %H:%M:%S"}
export STAMPEDE_TIME_FORMAT

# The time this script started (defaults to NOW).
: ${STAMPEDE_START_TIME:=$(date +"$STAMPEDE_TIME_FORMAT")}
export STAMPEDE_START_TIME


# Helper function to extract date fields from STAMPEDE_START_TIME.
function time_fields {
  fields=$1
  echo $($this_dir/date.sh --date "$STAMPEDE_START_TIME" --informat "$STAMPEDE_TIME_FORMAT" --format "$fields")
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

# Second (1234567890) of STAMPEDE_START_TIME.
: ${SUBSECOND:=$(time_fields "%s")}
export SUBSECOND

# Number (N) for the day of the week from STAMPEDE_START_TIME,
# where Sunday = 0 and Saturday = 6
: ${DAY_OF_WEEK_NUMBER:=$(time_fields "%w")}

# Three-letter abbreviation for the day of the week from STAMPEDE_START_TIME,
# e.g., "Thu".
: ${DAY_OF_WEEK_ABBREV:=$(time_fields "%a")}

# Full name of the day of the week from STAMPEDE_START_TIME,
# e.g., "Thursday".
: ${DAY_OF_WEEK:=$(time_fields "%A")}


# Log files location.
# On *nix systems, a more standard option is /var/logs/stampede.
: ${STAMPEDE_LOG_DIR:=$STAMPEDE_HOME/logs}
export STAMPEDE_LOG_DIR

# Log file for this run.
# (Note: we can't use the ymd function defined in common.sh, because it 
# hasn't been defined at this point in the execution!)
: ${STAMPEDE_LOG_FILE:=$STAMPEDE_PROJECT-$YEAR$MONTH$DAY-$HOUR$MINUTE$SECOND.log}
export STAMPEDE_LOG_FILE

# Logging level, 1-5 (debug, info, warning, error, fatal)
[ -z "$STAMPEDE_LOG_LEVEL" ] && let STAMPEDE_LOG_LEVEL=2

# -- Other default values:

# Set to non-empty when you want to disable email alerts, e.g., for testing.
# Assumes that the *nix "mail" command is configured on the server.
: ${STAMPEDE_DISABLE_ALERT_EMAILS:=true}
export STAMPEDE_DISABLE_ALERT_EMAILS

#The email address to which alerts are sent.
# Assumes that the *nix "mail" command is configured on the server.
: ${STAMPEDE_ALERT_EMAIL_ADDRESS:=root@localhost}
export STAMPEDE_ALERT_EMAIL_ADDRESS

# When waiting for a resource to appear (e.g., files) from a process outside
# our control, how many minutes to wait. Specify a number followed by a letter
# to indicate the units, ymdhms.
: ${STAMPEDE_WAIT_FOR_RESOURCE:=8h}
export STAMPEDE_WAIT_FOR_RESOURCE

# How many attempts to make for the workflow before giving up.
: ${STAMPEDE_NUMBER_OF_TRIES:=5}
export STAMPEDE_NUMBER_OF_TRIES

# Default makefile
: ${MAKEFILE:=makefile}

# Options that are always passed to make. 
#   --jobs    Run as many build tasks in parallel as possible. It's faster,
#             but you have to be more careful about defining dependencies!
# See "man make" for details.
: ${STAMPEDE_MAKE_OPTIONS:=--jobs}
export STAMPEDE_MAKE_OPTIONS
