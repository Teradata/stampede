# Makefile for Stampede itself

STAMPEDE_HOME = ${PWD}
VERSION       = 0.1
RELEASE_NAME  = stampede-v${VERSION}
RELEASE_FILE  = ${RELEASE_NAME}.tar.gz
RELEASE_FILE_CONTENTS = README.md README.html LICENSE bin examples test

all: clean tests release

install:
	@echo "install is TODO"

clean: clean-release clean-tests
	
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
tests: clean-tests test-env test-log test-syslog test-common test-send-email
	@echo "Successful!!"

clean-tests:
	rm -rf test/logs

test-env test-log test-common test-send-email:
	@cd test; \
	echo "Running $@:"; \
	STAMPEDE_HOME=${STAMPEDE_HOME} ./$@.sh; \
	if [ $$? -ne 0 ]; then \
	  echo "$@ failed!"; \
	  exit 1; \
	fi

test-syslog:
	@cd test; \
	echo "Running test-log with syslog enabled:"; \
	STAMPEDE_HOME=${STAMPEDE_HOME} STAMPEDE_LOG_USE_SYSLOG=0 ./test-log.sh; \
	if [ $$? -ne 0 ]; then \
	  echo "test-log with syslog enabled failed!"; \
	  exit 1; \
	fi
