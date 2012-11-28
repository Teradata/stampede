-- click-orders-report.hql
-- Stub to perform analytics on Hive tables.

-- Start by adding the new partition of the
-- external "orders" table for the new data,
-- but in case we've already added it, use a
-- IF NOT EXISTS clause.

ALTER TABLE orders ADD IF NOT EXISTS 
  PARTITION(ymd = ${YMD}) 
  LOCATION '${ORDERS_DIR}';

-- Now run queries...
