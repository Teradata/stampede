# README for MapReduceConfiguration Source Code

*MapReduceConfiguration* is a small Hadoop MR job that's used to determine configuration properties that a "generic" Hadoop job would see. It simply instantiates a `JobConf` object and uses it to return the properties requested by the user. It behaves analogously to `hive-prop` and `pig-prop` in `$STAMPEDE_HOME/bin/hadoop`. In fact, there is a corresponding driver script `mapreduce-prop` in that directory that drivers this code.

## Building the Code

This code is already built and installed as `$STAMPEDE_HOME/bin/hadoop/mr-config.jar`. It was built using Hadoop v1.0.3. However, if you want to build it yourself, perhaps to support a different, incompatible version of Hadoop, you can build it from the top-level `$STAMPEDE_HOME` directory using `make`:

    make java

Note that this command will overwrite `$STAMPEDE_HOME/bin/hadoop/mr-config.jar` with the one just built.

Alternatively, you can just build the jar without installing it by running `ant` with no arguments in this directory:

    ant

Either way, the build expects `$HADOOP_HOME` to be defined. It will use that directory to find the Hadoop jars needed to resolve dependencies.

There are no tests in this directory. Instead, see `$STAMPEDE_HOME/test/hadoop/test-mapreduce-prop.sh`.
