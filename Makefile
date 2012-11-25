# Makefile for Stampede itself

STAMPEDE_HOME = ${PWD}
VERSION       = 0.1
RELEASE_NAME  = stampede-v${VERSION}
RELEASE_FILE  = ${RELEASE_NAME}.tar.gz
RELEASE_FILE_CONTENTS = README.md README.html LICENSE Makefile bin examples test
TESTS_NO_SYSLOG = test-env test-dates test-log test-common test-waiting-try test-send-email
TESTS           = ${TESTS_NO_SYSLOG} test-syslog

all: clean tests release

all-no-syslog: clean tests-no-syslog release

install: all
	@echo "install is TODO"
	@exit 1

install-no-syslog: all-no-syslog
	@echo "install-no-syslog is TODO"
	@exit 1

clean: clean-release clean-tests clean-logs
	
release: ${RELEASE_FILE}

${RELEASE_FILE}: clean-release create-release-dir stage-release-file-contents
	tar czf ${RELEASE_FILE} $$(find ${RELEASE_NAME})
	ls -l ${RELEASE_FILE}

clean-release:
	rm -rf ${RELEASE_NAME} ${RELEASE_FILE}

create-release-dir:
	mkdir -p ${RELEASE_NAME}

stage-release-file-contents:
	for f in ${RELEASE_FILE_CONTENTS}; do cp -r $$f ${RELEASE_NAME}/$$f; done

# Run the tests in this order, as the later tests
# assume the features tested by the previous tests 
# are valid!
tests: clean-tests ${TESTS}
	@echo "Successful!!"

tests-no-syslog: clean-tests ${TESTS_NO_SYSLOG}
	@echo "Successful!!"

clean-tests:
	rm -rf test/logs

${TESTS_NO_SYSLOG}:
	@cd test; \
	echo "Running $@:"; \
	STAMPEDE_HOME=${STAMPEDE_HOME} ./$@.sh; \
	if [ $$? -ne 0 ]; then \
	  echo "$@ failed!"; \
	  exit 1; \
	fi

test-syslog:
	@echo '' 1>&2
	@echo "NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE" 1>&2
	@echo "You'll see 'emergency message' printed to all your terminals! It's harmless."  1>&2
	@echo "NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE" 1>&2
	@echo '' 1>&2
	@cd test; \
	echo "Running test-log with syslog enabled:"; \
	STAMPEDE_HOME=${STAMPEDE_HOME} STAMPEDE_LOG_USE_SYSLOG=0 ./test-log.sh; \
	if [ $$? -ne 0 ]; then \
	  echo "test-log with syslog enabled failed!"; \
	  exit 1; \
	fi

clean-logs:
	rm -rf logs

