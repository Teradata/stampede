#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# Makefile for Stampede itself. 
# Running make builds the "all" target, by default, which builds "clean", "tests", 
# and "release". By default, "all" does not test any features in subdirectories 
# of STAMPEDE_HOME/bin, e.g., "hadoop", which are considered "extras". 
# If you want to test those features, build "all-with-extras". Or, build
# "test-<feature>", where "<feature>" is a particular feature you plan to use. 
# Note that "release" will include all the features in the final archive, whether
# they are tested or not!
# To install the release, build "install".
# Notes:
#   1) Some *nix-like systems may not have syslog (e.g., Cygwin?). In this case,
#      run "make clean test-core release" to skip the syslog tests.

STAMPEDE_HOME = ${PWD}
VERSION       = $(shell cat VERSION)
RELEASE_NAME  = stampede-v${VERSION}
RELEASE_FILE  = ${RELEASE_NAME}.tar.gz
RELEASE_FILE_CONTENTS = *.md *.html LICENSE VERSION FAQs.md Makefile bin src custom contrib man examples test

TESTS_LOGGING = format-log-message to-log-level from-log-level log
TESTS_CORE1   = $(wildcard test/test-*.sh)
TESTS_CORE    = $(TESTS_CORE1:test/test-%.sh=%)
TESTS_HADOOP1 = $(wildcard test/hadoop/test-*.sh)
TESTS_HADOOP  = $(TESTS_HADOOP1:test/hadoop/test-%.sh=%)
TESTS_SYSLOG  = syslog

TESTS         = ${TESTS_CORE} ${TESTS_SYSLOG} 
TESTS_EXTRAS  = ${TESTS_HADOOP}

JAVA_CLASS_DIRECTORIES = $(wildcard src/*/*/bin)
JAVA_BUILT_JARS = $(wildcard src/*/*/*.jar)

all: clean test release

test: clean-tests test-core test-syslog 

all-with-extras: clean _all-with-extras
_all-with-extras: test test-extras release

test-extras: test-hadoop

distribution: java-release _all-with-extras

install:
	bin/install

clean: clean-release clean-tests clean-logs clean-build-products
	
release: clean-logs ${RELEASE_FILE}

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
test-core: ${TESTS_CORE:%=test-%}
	@echo "$@: Successful!!"

test-hadoop: ${TESTS_HADOOP:%=hadoop/test-%}
	@echo "$@: Successful!!"

test-syslog:
	@echo '' 1>&2
	@echo "NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE" 1>&2
	@echo "You'll see 'emergency message' printed to all your terminals! It's harmless." 1>&2
	@echo "NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE" 1>&2
	@echo '' 1>&2
	@cd test; \
	echo "Running test-log with syslog enabled:"; \
	STAMPEDE_HOME=${STAMPEDE_HOME} STAMPEDE_LOG_USE_SYSLOG=0 ./test-log.sh; \
	if [ $$? -ne 0 ]; then \
	  echo "test-log with syslog enabled failed!"; \
	  exit 1; \
	fi
	@echo "$@: Successful!!"

list-tests:
	@echo "Core tests:   ${TESTS_CORE}"
	@echo "Syslog tests: ${TESTS_SYSLOG}"
	@echo "Extras tests: ${TESTS_EXTRAS}"

clean-tests: clean-logs

clean-logs:
	rm -rf test/logs bin/logs bin/hadoop/logs bin/hadoop/pig-prop.pig.substituted

${TESTS_CORE:%=test-%} ${TESTS_HADOOP:%=hadoop/test-%}:
	@cd test; \
	echo "Running $@:"; \
	STAMPEDE_HOME=${STAMPEDE_HOME} $$PWD/$@.sh; \
	if [ $$? -ne 0 ]; then \
	  echo "$@ failed!"; \
	  exit 1; \
	fi


# We do the -z test because these variables will be "" when there are 
# no contents, e.g., for a fresh git clone or in a release archive!
clean-build-products:
	@[ -z "${JAVA_CLASS_DIRECTORIES}" ] || rm -rf ${JAVA_CLASS_DIRECTORIES}
	@[ -z "${JAVA_BUILT_JARS}" ] || rm -rf ${JAVA_BUILT_JARS}

# Compile the Java source apps, build the jars, and put them where they belong.
# Use the "java-release" target when building code for distributions of Stampede.

java-release: check-java-6 java

check-java-6:
	@java -version 2>&1 | grep -q 'java version "1.6'; \
	if [ $$? -ne 0 ]; then echo "Please use Java 6 for building portable releases."; \
	exit 1; fi

java: mapreduce-prop pig-prop

mapreduce-prop: clean-mapreduce-jar make-mapreduce-jar copy-mapreduce-jar

pig-prop: clean-pig-jar make-pig-jar copy-pig-jar

clean-mapreduce-jar: 
	rm -f src/hadoop/mapreduce-configuration/mapreduce-config.jar

make-mapreduce-jar: 
	cd src/hadoop/mapreduce-configuration; ant

copy-mapreduce-jar:
	cp src/hadoop/mapreduce-configuration/mapreduce-config.jar bin/hadoop

clean-pig-jar:
	rm -f src/hadoop/pig-configuration/pig-config.jar

make-pig-jar:
	cd src/hadoop/pig-configuration; ant

copy-pig-jar:
	cp src/hadoop/pig-configuration/pig-config.jar bin/hadoop
	
