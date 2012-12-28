# Stampede README

Dean Wampler<br/>
[dean.wampler@thinkbiganalytics.com](mailto:dean.wampler@thinkbiganalytics.com)<br/>
December 30, 2012

*Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.*

Welcome to *Stampede*, the workflow tool that works as [Cthulhu](http://en.wikipedia.org/wiki/Cthulhu) intended for *nix systems, using `make` for dependency management and task seqeuencing, `bash` for scripting, and `cron` for scheduling.

*Stampede* originated as an alternative workflow tool for [Hadoop](http://hadoop.apache.org), but it is not limited to Hadoop scenarios.

## Installation

First, clone this repo or expand the distribution archive somewhere useful, e.g., `$HOME/stampede`. 

Since *Stampede* uses `make` and `bash` as its weapon's of choice, run this `make` command to test *Stampede* on your system and then install it:

    make test install

The `tests` target is not required, but we recommend it as a sanity check for your environment. The `install` target will ask you for details like the target installation directory (the default is `/usr/local/stampede`).

If you **don't** have `syslog` on your system, run this command instead, which will skip the `syslog`-related tests:

    make test-core install

Finally, the `test` target does *not* test the "extras" included with *Stampede*, currently limited to [Hadoop-specific](http://hadoop.apache.org) tools. To test these tools, first ensure that `$HADOOP_HOME` is defined, then run this command: 

    make test-extras install

The `install` target installs everything, whether you want to use `syslog` and the "extras" or not. They are small and harmless, if left alone in a cold, dark room... ;^)

Next, assuming you installed in `/usr/local/stampede/`, which we'll call `$STAMPEDE_HOME` from now on, add `$STAMPEDE_HOME/bin` to the `PATH` for any user who plans to use *Stampede*. Also, the installation will include *nix `man` pages, so add `$STAMPEDE_HOME/man` to the `MANPATH`.

As part of the installation, the installer will ask you if you want a global `stampederc` file installed in `/etc`, `/etc/sysconfig`, or somewhere else. All statements in this file are commented out. If you want to make global changes to *Stampede's* environment variables, edit this file appropriately. Note these "rc" files won't contain all the possible variables you can define, see `$STAMPEDE_HOME/bin/env.sh` for the complete list of variables, their default values, and comments that describe them.

Similarly, if you told the installer to copy `stampederc` file to `$HOME/.stampederc`, edit that file for your personal tasks.

Whenever you create a new *Stampede* project, it will also get its own `$PROJECT_HOME/.stampederc` file, as we discuss next.

### Building Java Components

As of this release, there is a small Hadoop application written in Java, in `src/hadop/mapreduce-configuration`. It is used by the `bin/hadoop/mapreduce-prop` command. For your convenience, a pre-built jar file is already provided. However, it is built with Java 1.6 (for maximum portability) and Hadoop v1.0.3. So, you may need to rebuild it if you use a different version of Hadoop or you want to use a newer version of Java. See `src/hadop/mapreduce-configuration/README.md` for details.

## Usage

An individual workflow definition is called a *stampede*. 

To create a stampede, run the following command:

    stampede create

It will prompt you for properties such as the name of the stampede and the project's working directory.

Edit the `.stampederc` and `makefile` created in the project directory to define your workflow. See the `$STAMPEDE_HOME/examples` for ideas. Note that `$STAMPEDE_HOME/bin` contains helper scripts to ease the development of workflows.

Once a stampede has been created, you can invoke it using this command:

    stampede -f /path/to/makefile [options] [make_targets]

For help on the `stampede` options:

    stampede --help

## Required Tools

* `bash` v3+ - Because OS X ships with an older bash version, all the scripts supplied are v3 compatible. You can use newer constructs if your version of bash supports them.
* GNU `make` v3.8+ - The `Makefile` in this directory that's used to test and install *Stampede* requires Gnu `make` v3.8+, as do the `examples`. However, you can adapt your project `Makefiles` to use any version of `make` you prefer.
* `cron` - If you plan to use `cron` for scheduling workflows. In fact, *Stampede* doesn't really do anything with `cron` itself; we just recommend that you use it first, before adopting something more heavyweight and proprietary. *Stampede* projects will work fine with any scheduling tool that can invoke shell commands.
* `syslog` - If you plan to use the *nix logging facility `syslog`. See also the Installation section above.
* [Hadoop](http://hadoop.apache.org) - *Stampede* was originally designed as a flyweight replacement for [Oozie](http://oozie.apache.org). However, it is not restricted to Hadoop scenarios. All of the Hadoop support consists of helper scripts in `$STAMPEDE_HOME/bin/hadoop` (and corresponding tests and `man` pages). 

*Stampede* is mostly agnostic to tool versions. For any particular tool, including its own scripts, Stampede relies on finding the tool in the user's `PATH`.
 
## Supported Platforms

* **Linux** - All recent Linux distributions with `bash` v3+. However, we have not tested all possible Linux variants!
* **Mac OS X** - All recent OS X versions.

### Planned Support

Currently, `cygwin` and similar "Unix on Windows" toolkits are not supported, but only because we haven't tried them. We have tried to avoid any assumptions that would preclude this support. We welcome patches!

Note that as of this writing, support for running Hadoop in Windows environments was [just recently announced](https://www.hadooponazure.com/).

## Manifest

The top-level directory contains the following files, in addition to directories that will be described next:

* `README.md` - This file, as well as an HTML version of it.
* `LICENSE` - The copyright and license (Apache 2.0).
* `FAQs.md` - Frequently-asked Questions.
* `Makefile` - The `makefile` used to test and install *Stampede*.
* `VERSION` - The version number, used by the `Makefile` for building releases.
* `bin` - See the following section.
* `src` - The directory for tools implemented with Java. The corresponding jars are prebuilt and included in the distribution, but if you want to build them yourself, see the `README.md` files in the corresponding directories under `src`.
* `man` - *nix `man` pages for all the tools.
* `test` - Tests for the tools.

### Bin Directory

*Stampede* supplies helper `bash` scripts in the `bin` directory and "extras" for specific applications (e.g., [Hadoop](http://hadoop.apache.org)) in subdirectories. All the scripts that end with `.sh` are used internally by *Stampede*. The files without this extension are user-callable utilities for building workflows.

*NOTE:* All of these tools assume that `$STAMPEDE_HOME` is defined. This is true when they are called in a *stampede* workflow, e.g., a `Makefile`.

#### `bin` Utilities

Briefly, here are the utilities in the `bin` directory. All support a `--help` option for more information:

* `stampede` - The "stampede" (workflow) driver script. It can be invoked manually or by `cron`. It has several options to configure behavior. Run `stampede --help` for details.
* `install` - Called by `make install` to install *Stampede*.
* `abs-path` - Return the absolute value for the specified paths.
* `create-project` - Called by the `stampede` script to create new projects.
* `dates` - Format dates and perform date arithmetic in a platform-portable way.
* `from-log-level` and `to-log-level` - Convert from a log-level string, e.g., `DEBUG` to the corresponding `syslog`-compatible number and back again.
* `format-log-message` - Format messages that are logged. If you want to customize the format beyond what's possible by editing the environment variables `STAMPEDE_LOG_TIME_FORMAT` and `STAMPEDE_LOG_MESSAGE_FORMAT_STRING` (see `env.sh`), you can create your own version of this script and drop it in `$STAMPEDE_HOME/custom`, which is on the `PATH` BEFORE `$STAMPEDE_HOME/bin`. See the *Custom* section below for more details.
* `install` - Install *Stampede* on your system.
* `log-file` - Return the name of the log file used by *stampede* or `SYSLOG` if `syslog` is being used.
* `send-email` - Use the *nux `mail` command (if configured) to send alerts.
* `split-string` - Split a string on a delimiter and return an array or echo the elements to `stdout`.
* `stampede-log` - Write your own messages to the log file (or `syslog`) configured for *Stampede*.
* `success-or-failure` - Return one of two strings depending on a "success" flag.
* `true-or-false` - Return one of two strings depending on a whether a variable is empty or not.
* `to-seconds` - Return the number of seconds specified for an input number of seconds, minutes, or hours.
* `to-time-interval` - Like `to-seconds`, but returns a nicely formatted string.
* `try-for` - Repeated attempt an operation for a specified duration of time, until success or timeout.
* `try-until` - Like `try-for`, but tries until a user-specified timestamp.
* `waiting` - A `sleep(1)` wrapper with logging for use in loops, like the one in the `try-*` scripts.
* `ymd` - Return the year, month, and day for the workflow's start time, which defaults to today's date.
* `yesterday-ymd` - Return the year, month, and day for the day before the workflow's start time, i.e., yesterday's date, by default. For example, if you need to process yesterday's data, this is a convenient way to compute the correct date.

The following "helper" files are used by these scripts:

* `env.sh` - Defines global shell variables. Start here to find variables you can set in `rc` files to configure behavior.
* `common.sh` - Many "common" `bash` functions used in several scripts.
* `log.sh` - Support functions for logging.

#### `bin/hadoop` Utilities

[Hadoop-specific](http://hadoop.apache.org) helper tools are in the `bin/hadoop` directory.  As for the `bin` scripts, use `--help` for more information on each tool.

* `mapreduce-prop` - Return one or more property definitions for Hadoop MapReduce jobs.
* `hive-prop` - Return one or more property definitions for [Hive](http://hive.apache.org).
* `pig-prop` - Return one or more property definitions for [Pig](http://pig.apache.org).

**Note:** While the `*-prop` utilities behave similarly and take similar arguments, there are some differences
in the results they produce that reflect differences in how they were implemented. See their `*-prop --help` messages or `man` pages for details.

### Custom and Contrib Directories

If you want to override the behavior of any particular script, drop a new version in the `custom` directory (or a subdirectory), which are added to the `PATH` first.

We intend for `contrib` to be a place where unsupported, community-contributed tools will go. This directory and any subdirectories will also be added to the path, after `custom` and `bin`.

### Example Directory

The `example` directory contains example *stampedes* that you can adapt for your purposes as well as a sample configuration file.

* `crontab` - A sample `crontab` file.
* `stampederc` - A sample file that overrides environment variable definitions to customize the environment or a particular project. See `bin/env.sh` for recommendations on where to install one or more of these `rc` files and for the complete list of variables available.
* `hadoop` - An example sequencing several Hadoop jobs into a typical ETL and analytics workflow.
 
### Test Directory

Tests of *Stampede* itself are in the `test` directory. The tests provide good examples of the individual tools in action. To execute the tests, run `make test`. This `make` target won't run the "extras" tests, e.g., for Hadoop. To run *all* tests, run `make test-with-extras`.

## Notes

* The `bin/send-email` script requires the *nix mail service to be running on the server hosting the stampede.
* Supporting both Linux and Mac `date` commands added some complexity to the code.

## TODO

* More examples.
* Add Makefile tips to this file.
* Test email support with the *nix `mail` command.
* More tests, especially of command options.
 
