# Makefile used in testing the "stampede" script itself.

# Not used in the tests.
all: timestamp force-rerun tries

timestamp:
	@echo "test-stampede output: ${YEAR}-${MONTH}-${DAY} ${HOUR}:${MINUTE}:${SECOND}"

force-rerun: ${STAMPEDE_HOME}/test/Makefile

${STAMPEDE_HOME}/test/Makefile:
	@echo "test-stampede output: remaking ${STAMPEDE_HOME}/test/Makefile"

tries:
	exit 1