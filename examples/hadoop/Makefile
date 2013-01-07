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
	  --num-mappers 5	\
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
# location of a partition for a Hive "orders" table. The Hive script
# "clicks-orders-report.hql" will use ALTER TABLE to add this partition, so
# we pass in the location as an $ORDERS_DIR defined variable. The other 
# variable we'll define is "YMD" which will be used for processing; we set it 
# to yesterday's date. The script will also use the "adclicks" table created 
# by the previous Sqoop task in the workflow.
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
	  --num-mappers 5	\
	  --export-dir ${HIVE_WAREHOUSE_DIR}/finance.db/clicks_orders_analysis

recommendations-analysis-export:
	${SQOOP} export \
 	  --connect jdbc:mysql://db-server:3306/recommendations-prod \
	  --username uname -P
	  --table clicks_orders_recommendations \
	  --num-mappers 5	\
	  --export-dir ${RECOMMENDER_DATA_DIR}
