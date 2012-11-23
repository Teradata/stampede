# Stampede README

Dean Wampler<br/>
[dean.wampler@thinkbiganalytics.com](mailto:dean.wampler@thinkbiganalytics.com)<br/>
November 21, 2012

Welcome to *Stampede*, the Hadoop-aware workflow tool that works as [Cthulhu](http://en.wikipedia.org/wiki/Cthulhu) intended for *nix systems, using `make` for dependency management, `bash` for scripting, and `cron` for scheduling.

## Installation

1. Clone this repo or untar the distribution somewhere useful, e.g., `/usr/local/stampede`. 
2. Add `/usr/local/stampede/bin` (or whatever directory you used) to the `PATH` for any user who plans to use *Stampede*.
3. Copy `/usr/local/stampede/examples/stampederc` to one of the following locations, choosing one of the first two options appropriate for your operating system or for individual use, to the `$HOME` directory.
    * `/etc/stampederc`.
    * `/etc/sysconfig/stampede`.
    * `$HOME/.stampederc`.
4. Edit the properties in the copied `rc` file as appropriate for your environment.

## Usage

An individual workflow definition is called a *stampede*. 

For users who wish to customize all their stampedes, copy `/usr/local/stampede/examples/stampederc` to `$HOME/.stampederc` and edit to taste.

To create a stampede, run the following command:

    stampede create

It will prompt you for properties such as the name of the stampede and the project's working directory.

Edit the `.stampederc` and `makefile` created in the project directory to define your workflow. See the `$STAMPEDE_HOME/examples` for ideas. Note that `$STAMPEDE_HOME/bin` contains helper scripts to ease the development of workflows.

Once a stampede has been created, you can invoke it using this command:

    stampede [options] /path/to/makefile [make_targets]

For help on the `stampede` options:

    stampede --help

## Required Tools

* `bash` v3+ - Because OS X ships with an older bash version, all the scripts supplied are v3 compatible. You can use newer constructs if your version of bash supports them.
* GNU `make` v3.8+ - The template `makefile` generated by `stampede create` assumes GNU `make` syntax. You can adapt the `makefile` to any version of `make` you prefer.
* *Hadoop* - Recent versions of Hadoop and other tools you might use, such as Hive and Pig, are required, but *Stampede* is mostly agnostic to versions. For each tool, Stampede relies on finding the tool in the `PATH` in order to determine installation directories, such as when it needs to find property definitions, invoke the tool, etc. If a tool isn't found on the `PATH`, *Stampede* will attempt to use the corresponding `$TOOL_HOME` environment variable. If neither appropriate works, *Stampede* will exit with an error message.
 
## Supported Platforms

* **Linux** - All recent Linux distributions with `bash` v3+.
* **Mac OS X** - All recent OS X versions.

### Planned Support

Currently, `cygwin` and similar "Unix on Windows" toolkits are not supported, but only because we haven't tested them. We have tried to avoid any assumptions that would preclude this support. We welcome patches!

Note that as of this writing, support for running Hadoop in Windows environments was just [recently announced](https://www.hadooponazure.com/).

## Manifest

The top-level directory contains this `README.md`. The rest of *Stampede* is in subdirectories.

### Bin Directory

*Stampede* supplies helper `bash` scripts in the `bin` directory. 

Briefly, here are the files in the `bin` directory:

* `stampede` - The "stampede" (workflow) driver script. It can be invoked manually or by `cron`. It has several options to configure behavior. Run `stampede --help` for details.
* `env.sh` - Defines global shell variables. Start here for configuring behavior.
* `common.sh` - Common `bash` functions used in several scripts.
* `date.sh` - A helper script to format dates and perform date arithmetic.

### Example Directory

The `example` directory contains several example *stampedes* that you can adapt for your purposes as well as a sample configuration file.

* `Makefile` - A sample `makefile`.
* `crontab` - A sample `crontab` file.
* `stampederc` - A sample file that overrides environment variable definitions to customize the environment or a particular project. See `bin/env.sh` for recommendations on where to install one or more of these `rc` files and for the complete list of variables available.
* `hadoop-example` - A small example using a typical Hadoop job.
* `pig-example` - A small example using a typical Pig job.
* `hive-example` - A small example using a typical Hive job.
* `big-example` - A larger, more realistic example of a workflow joining several different tools and steps.
 
### Test Directory

Tests of *Stampede* itself are in the `test` directory.

## TODO

* Copyright notices.
* License file.
* Use the `syslog` logging levels.