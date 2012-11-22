# Setup the tests, such as overriding variables...

export TEST_DIR=$(dirname $BASH_SOURCE)
export PROJECT_DIR=$TEST_DIR
export STAMPEDE_DISABLE_ALERT_EMAILS=true
export STAMPEDE_LOG_DIR=$TEST_DIR/logs
mkdir -p STAMPEDE_LOG_DIR

export STAMPEDE_START_TIME="2012-11-20 01:02:03"

. $STAMPEDE_HOME/bin/common.sh

function verify_success {
    echo "1: $1"
    echo "@: $@"
    if [ "$1" -ne 0 ]
    then
        shift
        echo "Test failed! $@"
        kill -QUIT $$
    fi
}
