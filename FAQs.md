# Stampede FAQs

# How do I customize the behavior of Stampede?

* Override an environment variable in a custom `.stampederc` file. See the [README](README.html) for details.
* Create your own version of a `bin` script and put it in `custom`. For example, you can change the way log messages are formatted by creating your own `format-log-message`
# Why do you support Mac OSX, as well as Linux?

Like many other server-side applications, *Stampede* was developed on a Mac for primary use on Linux systems. In principle, it should work with any Unix variant, although we have only tested on Mac OSX and several flavors of Linux.