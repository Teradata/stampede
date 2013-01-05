# README for Pig Configuration

`PigPropertiesUDF` is a small Pig UDF that returns all the properties defined through the `UDFContext` object in a bag. It is used by the helper Pig script `$STAMPEDE_HOME/bin/hadoop/config.pig`, which flattens the bag and dumps them. That Pig script is called by the shell script `$STAMPEDE_HOME/bin/hadoop/pig-prop` to do final filtering and other processing. 

## Building the Code

This code is already built and installed as `$STAMPEDE_HOME/bin/hadoop/pig-config.jar`. It was built using Pig v0.9.1, Hadoop v1.0.3, and Java 1.6. It should work with "similar" Hadoop and more recent Pig releases, too. However, if you want to build it yourself, perhaps to support a different, incompatible versions of Hadoop and Pig, you can build it from the top-level `$STAMPEDE_HOME` directory using `make`:

    make java

Note that this command will overwrite `$STAMPEDE_HOME/bin/hadoop/pig-config.jar` with the one just built.

Alternatively, you can just build the jar without installing it by running `ant` with no arguments in this directory:

    ant

Either way, the build expects `$HADOOP_HOME` and `$PIG_HOME` to be defined. It will use those directories to find the Pig jar needed to resolve dependencies.

There are no tests in this directory. Instead, see `$STAMPEDE_HOME/test/hadoop/test-pig-prop.sh`.
