# Stampede FAQs

# How do I customize the behavior of *Stampede*?

* Pass arguments to `$STAMPEDE_HOME/bin/stampede`. See `stampede --help` for details.
* Override an environment variable in a custom `.stampederc` file. See the [README](README.html) for details.
* Create your own version of a `bin` script and put it in `$STAMPEDE_HOME/custom`. For example, you can change the way log messages are formatted by creating your own `format-log-message` script.

# How can I contribute back to *Stampede*?

Patches are welcome, of course. For larger contributions, we intend the `$STAMPEDE_HOME/contrib` directory to be location for contributions that are "as-is" and not appropriate to roll into the main code base.

# Why does *Stampede* support Mac OSX, as well as Linux?

Like many other server-side applications, *Stampede* was developed on a Mac for use primarily on Linux systems. In principle, it should work with any Unix variant, including Cygwin for Windows, although we have only tested on Mac OSX and several flavors of Linux.
