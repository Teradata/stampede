# Example Makefile for a Stampede project for a Hadoop workflow.
# 
# See the README in this directory for details.

# e.g., 2012-01-01 and 2011-12-31, respectively:
YMD           = $(shell ymd '-')
YESTERDAY_YMD = $(shell yesterday-ymd '-')

DROP_ZONE    = /var/ftp/drop-zone
HDFS_FTP_YYMD_DIR = /ftp/${YESTERDAY_YMD}
HDFS_ORDERS  = /orders/${YESTERDAY_YMD}

BM_FILE      = bargain-monster-orders-${YESTERDAY_YMD}.gzip
EH_FILE      = electronics-hut-orders-${YESTERDAY_YMD}.gzip
BM_FTP_FILE  = ${DROP_ZONE}/${BM_FILE}
EH_FTP_FILE  = ${DROP_ZONE}/${EH_FILE}

RECOMMENDER_DATA_DIR = /recommendation-engine/clicks-orders

# Hack to determine the location for Hive's internal/managed tables,
# given by the property: "hive.metastore.warehouse.dir".
# The default value for Apache distributions is "/user/hive/warehouse"
HIVE_WAREHOUSE_DIR = $(shell hive -e 'set;' | grep hive.metastore.warehouse | set -e 's/[^=]*=//')

foo: foo-xx bar-xx
	@echo try-for 2s 1s 'ls foo'
foo-xx bar-xx:
	@echo "$@ -> ${@:-xx=}"

all: etl analysis export
	@echo Hadoop stampede finished!

etl: ingest cleanse

ingest: from-production-db from-ftp-drop-zone

# Use Sqoop to ingest yesterday's clickstream data from the production database.
from-production-db:
	@echo "Ingesting clickstream data for yesterday: ${YESTERDAY_YMD} (today: ${YMD})
	sqoop import \
	  --connect jdbc:mysql://db-server:3306/clickstream-prod \ 
	  --username some_user -P \
	  --table adclicks \
	  --query "select * from adclicks where ymd = '${YESTERDAY_YMD}'" \ 
	  --num-mappers 5	\ 
	  --hive-import

from-ftp-drop-zone: ${HDFS_FTP_YYMD_DIR} ${BM-FTP-FILE} ${EH-FTP-FILE}

${HDFS_FTP_YYMD_DIR}:
	hadoop fs -mkdir ${HDFS_FTP_YYMD_DIR}

# Wait up to 4 hours, checking every 10 minutes, for yesterday's data from 
# "BargainMonster.com" and "ElectronicsHut.com" of orders that originated
# as ad clicks. Once each arrives, put it in HDFS.
${BM-FTP-FILE} ${EH-FTP-FILE}:
	try-for 4h 20m 'test -f $@'
	hadoop fs -put $@ ${HDFS_FTP_YYMD_DIR}

# Pass in parameters that tell the "cleanse-orders.pig"
cleanse:
	pig \
		-param INPUT_DIR=${HDFS_FTP_YYMD_DIR} \
		-param OUTPUT_DIR=${HDFS_ORDERS} \
		-f cleanse-orders.pig 
 
analysis: reports-analysis recommendations-analysis

# Treat the output directory of the Pig script,
# "${HDFS_ORDERS}" as the location of a partition
# for a Hive external "orders" table. The script
# will use ALTER TABLE to add this partition, so
# we pass in the location as an $ORDERS_DIR defined
# variable. The other variable we'll define is "YMD"
# which will be used for processing; we set it to
# yesterday's date.
# We'll also have the internal "adclicks" table 
# created by Sqoop.
reports-analysis:
	@hive \
		--define ORDERS_DIR=${HDFS_ORDERS} \
		--define YMD=${YESTERDAY_YMD} \
		-f clicks-orders-report.hql 

# A custom Hadoop job that updates the data for a
# recommendation engine. We assume the Hive clicks data
# is in the Hive "warehouse" location, inside a "finance"
# database (in a subdirectory named "finance.db"), and a
# an "adclicks" subdirectory for the table data.
recommendations-analysis:
	@hadoop \
		jar /usr/local/mycompany/clicks-orders-recommendations.jar \
		--clicks=${HIVE_WAREHOUSE_DIR}/finance.db/adclicks \
		--orders=${HDFS_ORDERS} \
		--ymd=${YESTERDAY_YMD} \
		--output=${RECOMMENDER_DATA_DIR}

# Export the results of both analysis steps back to tables in
# another database.

export: reports-analysis-export recommendations-analysis-export

reports-analysis-export:
	sqoop export \
 	  --connect jdbc:mysql://db-server:3306/orders-warehouse \ 
	  --username uname -P
	  --table clicks_orders \
	  --num-mappers 5	\ 
	  --export-dir ${HIVE_WAREHOUSE_DIR}/finance.db/clicks_orders_analysis

recommendations-analysis-export:
	sqoop export \
 	  --connect jdbc:mysql://db-server:3306/recommendations-prod \ 
	  --username uname -P
	  --table clicks_orders_recommendations \
	  --num-mappers 5	\ 
	  --export-dir ${RECOMMENDER_DATA_DIR}
