-- Pig script to cleanse the order data.

input = load '$INPUT_DIR' as (...);

-- Clean the data...

cleansed_data = ...;

store cleansed_data into '$OUTPUT_DIR';
