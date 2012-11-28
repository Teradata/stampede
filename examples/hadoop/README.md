# README for Hadoop Workflow Example

*Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.*

In this example, we demonstrate a Hadoop workflow with several steps:

* *Extract, transform, and load*, where data sources are ingested (in part using [Sqoop](https://sqoop.apache.org)), cleaned, and transformed using [Pig](https://pig.apache.org).
* Batch-mode analysis of the data:
    * A [Hive](https://hive.apache.org) script to do analysis easily performed by *Hive*.
    * A custom [Hadoop](https://hadoop.apache.org) job for special, ad-hoc analysis (e.g., *Machine Learning* algorithms.
* The analysis results are exported back to another database using [Sqoop](https://sqoop.apache.org).

The two "batch-mode" analysis steps are independent, so they can be run in parallel. By default, `STAMPEDE_MAKE_OPTIONS` definition includes the `--jobs` flag that tells `make` to run tasks in parallel, when possible. Similarly, the data ingestion steps can proceed in parallel.

In more detail, we show how two (fictitious) data sources are ingested. One source is a database where [Sqoop](https://sqoop.apache.org) is used to extract the data of interest. The second source is a set of files staged daily to an FTP "drop zone". For the FTP files, we demonstrate the scenario where the FTP process is outside the control of our workflow and we can't be certain when they will actually show up. 

Of course, the data for this stampede is fictious and the scripts we include and use are skeletons to give you ideas. However, you can see what it would do by running the following commands, which use the `--no-exec` flag to just print the commands required without actually attempting to run anything. We assume that "stampede" 
is on your path, per the installation instructions. We'll assume that that this directory is `/usr/local/stampede/examples/hadoop`.

## Run the Workflow with the Default Settings

    stampede --no-exec /usr/local/stampede/examples/hadoop/Makefile all

## Rerun the Workflow for 2012-11-01, which processes 2012-10-30

Assuming it is still 2012:

    stampede --no-exec --month=10 --day=30 /usr/local/stampede/examples/hadoop/Makefile all

## Rerun the "export" part of Today's Workflow 

    stampede --no-exec /usr/local/stampede/examples/hadoop/Makefile export


