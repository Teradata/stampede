#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# test-install.sh - Tests of the installer

TEST_DIR=$(dirname ${BASH_SOURCE[0]})
. $TEST_DIR/setup.sh

if [ -w /tmp ]
then
  INSTALL_TEST_BASE=/tmp/install-test
else
  INSTALL_TEST_BASE=$HOME/install-test
fi
INSTALL_TEST_DIR=$INSTALL_TEST_BASE/install
echo "  (using \"$INSTALL_TEST_BASE\" as an installation test directory. It will be deleted if the tests pass.)"
rm -rf "$INSTALL_TEST_BASE"
mkdir -p $INSTALL_TEST_BASE

function do_test {
  echo "" >> $INSTALL_TEST_BASE/test.log
  echo "$0: -- Running test with input from $1:" >> $INSTALL_TEST_BASE/test.log
  eval "$1" | install 2>> $INSTALL_TEST_BASE/test.log
  [ ${PIPESTATUS[1]} -ne 0 ] && die "Installation test failed for \"$1\"! See the messages in $INSTALL_TEST_BASE/test.log and the output in $INSTALL_TEST_BASE"
  rm -rf "$INSTALL_TEST_DIR"
}

echo "  test installation where it is left in the unarchived directory:"
function install_test_archive_dir_input {
  cat <<EOF
n
4
$INSTALL_TEST_BASE
5
EOF
}
do_test "install_test_archive_dir_input"

echo "       ... and no stampederc file is created:"
function install_test_archive_dir_input_norc {
  cat <<EOF
N
5
EOF
}
do_test "install_test_archive_dir_input_norc"

echo "  test installation in a user-specified and owned directory:"
function install_test_user_dir {
  cat <<EOF
Y
$INSTALL_TEST_DIR
4
$INSTALL_TEST_BASE
5
EOF
}
do_test "install_test_user_dir"

echo "  test installation in a user-specified and owned directory that already exists:"
mkdir -p $INSTALL_TEST_DIR/foo
function install_test_user_dir_already_exists {
  cat <<EOF
Y
$INSTALL_TEST_DIR
Y
4
$INSTALL_TEST_BASE
5
EOF
}
do_test "install_test_user_dir_already_exists"


echo "  options tests:"
line=$(install --help)
[[ $line =~ Install.Stampede.*prompt.*information ]] || die "Unexpected --help message: <$line>"
 
# echo "contents of  $INSTALL_TEST_BASE/test.log:"
# cat $INSTALL_TEST_BASE/test.log
rm -rf "$INSTALL_TEST_BASE"

exit 0