#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# mail-mock.sh - Mocks the mail program for testing.
# It writes the subject and email address on a line to stdout,
# followed by each line of the input message.
# usage:
#   mail-mock.sh -s subject address < message_lines

minus_s=$1
shift
if [ "$minus_s" != "-s" ]
then
  echo "First argument must be -s"
  exit 1
fi
subject=$1
shift
email_address=$1
shift

echo "$subject" "$email_address"
while read line; do echo $line; done
 
