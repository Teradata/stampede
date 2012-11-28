#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-split-string.sh - Tests the split-string script.

TEST_DIR=$(dirname $BASH_SOURCE)
. $TEST_DIR/setup.sh

echo2 "  single-line output tests:"

msg=$(split-string "a b c")
[ "$msg" = 'a b c' ] || die "Expected 'a b c', got \"$msg\"."
for eq in ' ' '='
do
  msg=$(split-string --outdelim${eq}: "a b c")
  [ "$msg" = 'a:b:c' ] || die "Expected 'a:b:c', got \"$msg\"."
  msg=$(split-string -o${eq}: "a b c")
  [ "$msg" = 'a:b:c' ] || die "Expected 'a:b:c', got \"$msg\"."

  msg=$(split-string --delim${eq}- --outdelim${eq}: "a-b-c")
  [ "$msg" = 'a:b:c' ] || die "Expected 'a:b:c', got \"$msg\"."
  msg=$(split-string -d${eq}- --outdelim${eq}: "a-b-c")
  [ "$msg" = 'a:b:c' ] || die "Expected 'a:b:c', got \"$msg\"."
done

echo2 "  multi-line output tests:"

expected=(a b c)
for sep in '' ' ' ':'
do 
  let i=0
  split-string --newline --outdelim=${sep} "a b c" | while read line 
  do
    [ "$line" = ${expected[$i]} ] || die "Expected \"${expected[$i]}\", got \"$line\"."
    let i=$i+1
  done
  let i=0
  split-string -n --outdelim=${sep} "a b c" | while read line 
  do
    [ "$line" = ${expected[$i]} ] || die "Expected \"${expected[$i]}\", got \"$line\"."
    let i=$i+1
  done
done

echo2 "  multi-line output with index tests:"

expected=(a b c)
for sep in '' ':'
do 
  let i=0
  expected_sep="$sep"
  args="--newline --index --outdelim=$sep"
  if [ -z "$sep" ]
  then
    args="--newline --index"
    expected_sep=' '
  fi
  split-string $args "a b c" | while read line 
  do
    expected_string="${i}${expected_sep}${expected[$i]}"
    [ "$line" = "$expected_string" ] || die "Expected \"$expected_string\", got \"$line\" (args: $args)."
    let i=$i+1
  done
done

echo2 "  test --index but not also --newline:"
split-string --index "a b c" 2>&1 | while read line
do
  expected="ERROR: Must specify --newline with --index."
  [[ $line =~ $expected ]] || die "Expected \"$expected\", got \"$line\"."
  break # effectively only read the first line.
done
