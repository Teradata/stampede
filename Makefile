# Makefile for Stampede itself

STAMPEDE_HOME=${PWD}

all: setup tests

setup:

# Run the tests in this order, as the later tests
# assume the features tested by the previous tests 
# are valid!
tests: test-env test-log test-common test-send-email
	@echo "Successful!!"

test-env test-log test-common test-send-email:
	@cd test; \
	echo "Running $@:"; \
	STAMPEDE_HOME=${STAMPEDE_HOME} ./$@.sh; \
	if [ $$? -ne 0 ]; then \
	  echo "$@ failed!"; \
	  exit 1; \
	fi