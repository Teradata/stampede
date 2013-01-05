-- Pig script used by pig-prop
-- Only invoke this script through $STAMPEDE_HOME/bin/hadoop/pig-prop.
-- Due to Pig's inflexibility, it requires a stupid hack to work. The UDF that
-- returns the properties doesn't need any file input, as it just works with
-- in-memory property data. However, the only way to make the UDF work is to
-- load SOME file, then throw it away. Also, you apparently can't use variables
-- in the "register" paths, so we use yet another hack.

register /tmp/pig-config.jar

define properties com.thinkbiganalytics.hadoop.PigPropertiesUDF();

inpt = LOAD '$dummyfile' USING TextLoader AS (line);
inpt1 = limit inpt 1;
propsbag = foreach inpt1 generate properties(1) as props;
props = foreach propsbag generate flatten(props);
dump props; 
