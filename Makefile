# Makefile for Stampede itself

STAMPEDE_HOME=${PWD}

all: setup tests

setup:

tests:
	@cd test; for f in test-*.sh; \
	  do echo "Running $$f:"; \
	  STAMPEDE_HOME=${STAMPEDE_HOME} ./$$f; \
	  if [ $$? -ne 0 ]; then \
	    echo "$$f failed!"; \
	    kill -TERM $$$$; \
	  fi; \
	done 
	@echo "Successful!!"