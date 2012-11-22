#!/usr/bin/env bash
#----------------------------------------------------
# send-email.sh - Send alert on errors.
# usage:
#   send-email.sh severity address subject < message_lines
# It reads the lines of the message from stdin.
# The command-line mail program must be configured and enabled.

# Override the following on the command line for testing.
: ${MAIL:=mail}

severity=$1
shift
email_address=$1
shift
subject=$1
shift
subject="$severity: Stampede failure: $subject"

while read line; do echo $line; done | $MAIL -s "$subject" "$email_address" &
 
