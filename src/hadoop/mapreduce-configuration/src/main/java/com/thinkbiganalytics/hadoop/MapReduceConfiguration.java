package com.thinkbiganalytics.hadoop;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.mapred.JobClient;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.util.GenericOptionsParser;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

/**
 * A small MR program that just prints out user-requested configuration
 * properties.
 */
public class MapReduceConfiguration extends Configured implements Tool {

	private static boolean printKeysOnly   = false;
	private static boolean printValuesOnly = false;
	private static ArrayList<String> strings      = new ArrayList<String>();
	private static ArrayList<String> regexStrings = new ArrayList<String>();

	public static void usage(String message) {
		if (message.length() > 0)
			System.err.println(message);
		System.err.println("Usage: hadoop jar .../mr-config.jar [generic_options] \\ ");
		System.err.println("       [-h | --help] [--print-keys | --print-values] \\ ");
		System.err.println("       --all | [--regex=re1 [--regex=re2] string1 [string2] ...]");
		System.err.println("");
		System.err.println("Where:");
		System.err.println("");
		System.err.println("  -h | --help    Show this message.");
		System.err.println("  --print-keys   Print all matching keys in the \"key=value\" pairs");
		System.err.println("                 (default: print the full \"key=value\").");
		System.err.println("  --print-values Print only the values for the matching keys.");
		System.err.println("                 (Confusing for multiple matches!)");
		System.err.println("  --all          Show ALL variables.");
		System.err.println("  --regex=re     Match this regular expression. It must match the WHOLE string.");
		System.err.println("  string         Match this WHOLE name.");
		System.err.println("");
		System.err.println("Generic Hadoop Options:");
		System.err.println("");

		ToolRunner.printGenericCommandUsage(System.err);
	}

	public static void main(String[] args) throws Exception {
		int exitCode = 0;

		JobConf conf = new JobConf(MapReduceConfiguration.class);
		conf.setJobName("Simple Word Count");

		GenericOptionsParser optionsParser = new GenericOptionsParser(conf, args);
		
		boolean printAll  = false;
		
		String[] remainingArgs = optionsParser.getRemainingArgs();
		for (String arg : remainingArgs) {
			if (arg.matches("--?h.*")) {
				usage("");
				System.exit(exitCode);
			} else if (arg.matches("--print-k.*")) {
				printKeysOnly = true;
			} else if (arg.matches("--print-v.*")) {
				printValuesOnly = true;
			} else if (arg.equals("--all")) {
				printAll = true;
			} else if (arg.equals("--all")) {
				printAll = true;
			} else if (arg.startsWith("--regex=")) {
				regexStrings.add(arg.substring("--regex=".length()));
			} else if (arg.startsWith("-")) {
				usage("MapReduceConfiguration: ERROR: Unrecognized argument \""+arg+"\".");
				System.exit(1);
			} else {
				strings.add(arg);
			}
		}

		if (strings.size() == 0 && regexStrings.size() == 0) {
			usage("MapReduceConfiguration: ERROR: Must specify one or more names, regular expressions, or --all");
			System.exit(1);
		}
		
		Iterator<Map.Entry<String,String>> iter = conf.iterator();
		while (iter.hasNext()) {
			Entry<String, String> kv = iter.next();
			String key = kv.getKey();
			String value = kv.getValue();
			if (printAll) {
				printKeyValue(key, value);
			} else {
				printMatches(key, value);
			}
		}
		
		System.exit(exitCode);
	}

	private static void printMatches(String key, String value) {
		for (String s: strings) {
			if (key.equals(s)) {
				printKeyValue(key, value);
				return;
			}
		}
		for (String re: regexStrings) {
//			System.out.format("%s, %s\n", key, re);
			if (key.matches(re)) {
				printKeyValue(key, value);
				return;
			}
		}
	}

	private static void printKeyValue(String key, String value) {
		if (printKeysOnly) {
			System.out.println(key);
		} else if (printValuesOnly) {
			System.out.println(value);
		} else {
			System.out.format("%s=%s\n", key, value);
		}
	}

	// Unused.
	@Override
	public int run(String[] arg0) throws Exception {
		return 1;
	}
}
