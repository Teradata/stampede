# Announcing "Stampede"

Dean Wampler<br/>
[dean.wampler@thinkbiganalytics.com](mailto:dean.wampler@thinkbiganalytics.com)<br/>
[@thinkBigA](https://twitter.com/thinkBigA/)<br/>
January 9, 2013

When you're building nontrivial workflows, you need a tool that lets you express the dependencies between tasks, schedule their execution, detect failures and attempt retries, etc. You also want that tool to be concise, easy to use, yet powerful.

Welcome to *Stampede*, the workflow tool that works as [Cthulhu](http://en.wikipedia.org/wiki/Cthulhu) intended for *nix systems, using `make` for dependency management and task seqeuencing, `bash` for scripting, and `cron` for scheduling.

*Stampede* originated as an alternative workflow tool for [Hadoop](http://hadoop.apache.org), but it is not limited to Hadoop scenarios.

## Embracing the Unix Philosophy

*Stampede* was born out of frustration with heavyweight "enterprisey" tools that are hard and frustrating to use. We have a ~40-year tradition, *the Unix Philosophy*, of flyweight, flexible tools that compose together to build sophisticated applications.

How can you specify dependencies between tasks? `Make` does this concisely and flexibly. How do you script the tasks themselves? One of the powerful Unix shells, such as `bash`, is platform portable and supports the concise expression of complex tasks. How do you schedule when a workflow should start? `Cron` and its sibling `at` make this easy.

*Stampede* won't appeal to you unless you know `make` and `bash`. It doesn't provide a GUI (at least not yet).  It's a tool for [polygot programmers](http://polyglotprogramming.com), developers who use a diverse set of languages and tools, adopting the most appropriate tool for a given job. If the word [DevOps](http://devops.com/) means anything to you, then *Stampede* is the tool for you.

## How Does It Work?

In fact, *Stampede* is less than meets the eye. Really. Most of its power comes from `make`, `bash`, and other *nix command-line tools, like `date`, `mkdir`, and their friends. However, those tools by themselves aren't quite enough for convenient development of workflows, which we call *stampedes*.

So, *Stampede* adds lots of helper tools, mostly `bash` scripts, to make it easier to do common IT tasks, like specify yesterday's date for an ETL process, watch for a file to appear in a drop zone from an FTP process and then start processing it, retry a failed workflow every hour until it succeeds, etc. *Stampede* also includes a driver script, called `stampede` that does various environment setup steps before calling `make`. Your actual workflows (*stampedes*) are defined in `Makefiles`.

In principle, *Stampede* can support any *nix environment, but currently we only support Linux and Mac OSX. So, we require `bash` for scripts and [Gnu Make](http://www.gnu.org/software/make/), since these are the standard tools distributed with Linux, Mac OSX, and also Cygwin. Cygwin support should be possible and we welcome patches if anyone wants to take it on. Any Unix system with
`bash` and Gnu `make` installed should also be able to run *Stampede* out of the box. Patches are welcome if you encounter problems.

Here is an example `Makefile` for a fictitious Hadoop workflow, taken from the distribution's Hadoop example. We'll use the environment variable `$STAMPEDE_HOME` to reference where you installed *Stampede*. (It's value is set by the `stampede` driver script when you run a workflow.) The `Makefile` comments describe what's going on:

    # Example Makefile for a Stampede project for a Hadoop workflow.
    # For more details, see $STAMPEDE_HOME/examples/hadoop/README.md.

    # Call the "ymd" and "yesterday-ymd" tools (bash scripts that 
    # are part of Stampede) to get the YYYY-MM-DD for today and 
    # yesterday, respectively, e.g., 2013-01-01 and 2012-12-31:
    YMD           = $(shell ymd '-')
    YESTERDAY_YMD = $(shell yesterday-ymd '-')

    # Local (as opposed to HDFS) file system location where FTP'ed incoming
    # files are dropped. 
    DROP_ZONE = /var/ftp/drop-zone

    # Locations in HDFS for the ingested files for yesterday.
    HDFS_FTP_YYMD_DIR = /ftp/${YESTERDAY_YMD}
    HDFS_ORDERS       = /orders/${YESTERDAY_YMD}

    # Data from our "partners", BargainMonsters.com and ElectronicsHut.com
    BM_FILE      = bargain-monster-orders-${YESTERDAY_YMD}.gzip
    EH_FILE      = electronics-hut-orders-${YESTERDAY_YMD}.gzip
    BM_FTP_FILE  = ${DROP_ZONE}/${BM_FILE}
    EH_FTP_FILE  = ${DROP_ZONE}/${EH_FILE}

    # Data used by our recommendation engine that analyzes click streams and orders.
    RECOMMENDER_DATA_DIR = /recommendation-engine/clicks-orders

    # The location for Hive's internal/managed tables, given by the property:
    #   hive.metastore.warehouse.dir
    HIVE_WAREHOUSE_DIR = $(shell hive-prop --print-value hive.metastore.warehouse.dir)

    # URL for the NameNode.
    HADOOP_NAMENODE = $(shell mapreduce-prop --print-value )

    HADOOP = hadoop
    PIG    = pig
    HIVE   = hive
    SQOOP  = sqoop

    all: etl analysis export
      @echo Hadoop stampede finished!

    etl: ingest cleanse

    ingest: from-production-db from-ftp-drop-zone

    # Use Sqoop to ingest yesterday's click stream data from the production database.
    from-production-db:
      @echo "Ingesting clickstream data for yesterday: ${YESTERDAY_YMD} (today: ${YMD})
      ${SQOOP} import \
        --connect jdbc:mysql://db-server:3306/clickstream-prod \
        --username some_user -P \
        --table adclicks \
        --query "select * from adclicks where ymd = '${YESTERDAY_YMD}';" \
        --num-mappers 5 \
        --hive-import

    from-ftp-drop-zone: ${BM_FTP_FILE} ${EH_FTP_FILE}

    # Wait up to 4 hours, checking every 10 minutes, for yesterday's data from 
    # BargainMonster.com and ElectronicsHut.com of orders that originated
    # as ad clicks. Once each arrives, put it in HDFS.
    ${BM_FTP_FILE} ${EH_FTP_FILE}: ${HDFS_FTP_YYMD_DIR}
      @try-for 4h 10m 'test -f $@'
      ${HADOOP} fs -put $@ ${HDFS_FTP_YYMD_DIR} 

    ${HDFS_FTP_YYMD_DIR}:
      ${HADOOP} fs -mkdir ${HDFS_FTP_YYMD_DIR}

    # Use Pig for data cleansing. Pass in parameters that tell the "cleanse-orders.pig"
    # script the location of the input and where to write the output (both in HDFS).
    cleanse:
      ${PIG} \
        -param INPUT_DIR=${HDFS_FTP_YYMD_DIR} \
        -param OUTPUT_DIR=${HDFS_ORDERS} \
        -f cleanse-orders.pig 
     
    analysis: reports-analysis recommendations-analysis

    # Treat the output directory of the Pig script, "${HDFS_ORDERS}" as the
    # location of a partition for a Hive external "orders" table. The Hive script
    # "clicks-orders-report.hql" will use ALTER TABLE to add this partition, so
    # we pass in the location as an $ORDERS_DIR defined variable. The other 
    # variable we'll define is "YMD" which will be used for processing; we set it 
    # to yesterday's date. The script will also use the internal "adclicks" table 
    # created by the previous Sqoop task in the workflow.
    reports-analysis:
      ${HIVE} \
        --define ORDERS_DIR=${HDFS_ORDERS} \
        --define YMD=${YESTERDAY_YMD} \
        -f clicks-orders-report.hql 

    # A custom Hadoop job that updates the data for a recommendation engine. 
    # We assume the Hive clicks data is in the Hive "warehouse" location, inside
    # a "finance" database (in a subdirectory named "finance.db"), and an
    # "adclicks" subdirectory for the table data.
    recommendations-analysis:
      ${HADOOP} \
        jar /usr/local/mycompany/clicks-orders-recommendations.jar \
        --clicks=${HIVE_WAREHOUSE_DIR}/finance.db/adclicks \
        --orders=${HDFS_ORDERS} \
        --ymd=${YESTERDAY_YMD} \
        --output=${RECOMMENDER_DATA_DIR}

    # Using Sqoop, export the results of both analysis steps back to tables in
    # another database.
    export: reports-analysis-export recommendations-analysis-export

    reports-analysis-export:
      ${SQOOP} export \
        --connect jdbc:mysql://db-server:3306/orders-warehouse \
        --username uname -P
        --table clicks_orders \
        --num-mappers 5 \
        --export-dir ${HIVE_WAREHOUSE_DIR}/finance.db/clicks_orders_analysis

    recommendations-analysis-export:
      ${SQOOP} export \
        --connect jdbc:mysql://db-server:3306/recommendations-prod \
        --username uname -P
        --table clicks_orders_recommendations \
        --num-mappers 5 \
        --export-dir ${RECOMMENDER_DATA_DIR}
              

## Hadoop Support

*Stampede* originated as a tool for Hadoop-related projects, although it's not limited to those scenarios.

As you can see from the previous example, because Hadoop tools have command-line interfaces, we simply call them in the `Makefile`.

The additional Hadoop support consists of `bash` scripts and compiled Java code in the `$STAMPEDE_HOME/bin/hadoop` directory. 

Currently, there are three additional tools provided by *Stampede* for determining configuration property settings for *MapReduce*, *Hive*, and *Pig*, by actually running those tools, as opposed to reading static configuration files. More Hadoop-specific tools are planned, e.g., basic integration with the *JobTracker*, *NameNode*, and *HCatalog*.

## Where to Go from Here

Download a release or clone the [Stampede GitHub repo](https://github.com/ThinkBigAnalytics/stampede) and follow the instuctions in the [README](https://github.com/ThinkBigAnalytics/stampede) for installing *Stampede* and using it. You'll also find the Hadoop example we discussed above in `$STAMPEDE_HOME/examples/hadoop`. See also our [GitHub Wiki](https://github.com/ThinkBigAnalytics/stampede/wiki).

We hope you find *Stampede* useful. Consider joining our Google Group, [stampede-users](https://groups.google.com/forum/#!forum/stampede-users).
