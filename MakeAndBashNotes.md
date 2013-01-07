# Make and Bash Notes

This document offers some tips on using `bash` and `make` effectively to build stampedes. The `bash` scripts and `Makefiles` that come with *Stampede*, e.g., in the `bin` and `examples` directories, also provide examples.

This is by no means a complete tutorial on either tool. 

## Make Notes

While many of these points apply to all implementations of `make`, we'll focus on GNU `make`, the version of `make` distributed with Linux and Mac OSX and the only `make` supported by *Stampede*. See the [GNU Make Manual](http://www.gnu.org/software/make/manual/) for more information.

### Parallel vs. Sequential Execution

Consider the following `Makefile`:

    all: one two three
        @echo "$@ finished!"

    one two three:
        @echo "building $@..."
        sleep 1
        @echo "$@ finished!"

The `@` before `echo` means "don't print this command to stdout before running it." This reduces output clutter, especially for an `echo` command that itself writes output!

The `$@` variable references the target. For example, when `all` finishes, `@echo "$@ finished!"` will print "all finished!".

If you build the `all` target by just running `make` (which will look for `Makefile` by default), you get this output:

    building one...
    sleep 1
    one finished!
    building two...
    sleep 1
    two finished!
    building three...
    sleep 1
    three finished!
    all finished!

Note that `one`, `two`, and `three` where built sequentially, one at a time, as "suggested" by the dependency list for `all`. Note that for each of the `one`, `two`, and `three` targets, the output for each was the following: 

    building <X>...
    sleep 1
    <X> finished!

However, this sequential ordering is misleading. It only happened this way because `make` runs sequentially by default.

The `Makefile` actually says that `all` depends on the other three targets, but they have no dependencies on each other. You can see this if you run `make --jobs`, which causes `make` to build as many targets concurrently as the dependency tree will allow. Here is the output of one run:

    building two...
    building one...
    sleep 1
    sleep 1
    building three...
    sleep 1
    one finished!
    two finished!
    three finished!
    all finished!

Note that the three output lines for each of `one`, `two`, and `three` are now intertwined. Make recognized that these targets are independent and it built them concurrently. In fact, different runs will show a different ordering of the output, except for the last line.

**By default**, *Stampede* passes the `--jobs` option to `make` to exploit concurrency when possible. This is configurable in your project's `.stampederc` file by setting the `STAMPEDE_MAKE_OPTIONS` environment variable.

All this means two things:

* When your stampedes include long-running or long-waiting tasks, other unrelated work can proceed.
* Be careful that you construct your dependencies correctly and don't rely on the informal, but incorrect, dependencies implied by a dependency list when running in `make`'s default synchronous mode (i.e., when `--jobs` isn't used). 

So, in our `Makefile`, if `three` really depends on `two`, and `two` really depends on `one`, then the `Makefile` should be rewritten as follows:

    all1: three
        @echo "$@ finished!"

    three: two
    two: one

    one two three:
        @echo "building $@..."
        sleep 1
        @echo "$@ finished!"

Actually, we used a useful GNU `make` technique here; we specified `three` and `two` as targets twice, once to specify their dependents and again to specify the common commands used to build `one`, `two`, and `three`.

If you run `make --jobs` with this version of `Makefile`, you'll still get the synchronous output.

# Setting Make Variables with Shell Commands or File "Globs"

In GNU `make`, you can run shell commands and file "globs" as follows:

    EPOCH_SECONDS = $(shell date +%s)
    SH_FILES      = $(wildcard bin/*.sh)

    ...

    show_vars:
        @echo ${EPOCH_SECONDS}
        @echo ${SH_FILES}


At the moment when I ran `make show_vars`, I got the following output:

    1357151251
    bin/common.sh bin/env.sh bin/log.sh

Note that `make` variables must be referenced using the `${...}` syntax, unlike `bash` shell variables, where the `{` and `}` are only required to separate text, e.g., something like `${prefix}name`.

### Multi-line Bash Scripts

Note that each line in the *recipe* for a *rule* to build a target is executed in a separate shell invocation. This means multi-command `bash` scripts require care. For example, if you set a variable that will be used in subsequent commands or multi-line constructs like `for` loops. Consider the following sequence of `bash` commands you might run at the `bash` command prompt:

    STAGING=$HOME/staging
    for f in $FILES
    do 
      cp $f $STAGING/$f
    done

In a recipe, the have to be written on the same line in order to be executed in the same shell process:

        STAGING=${HOME}/staging; for f in ${FILES}; do cp $$f $$STAGING/$$f; done

Note that we separate each command with a semi-colon, we have to reference `${HOME}` with `{...}`, and we have to use two `$$` when referencing shell variables (as opposed to `make` variables). 

Another way to write this more legibly, like the original non-`make` version, is the following:

        STAGING=${HOME}/staging; \
        for f in ${FILES}; \
        do \
          cp $$f $$STAGING/$$f; \
        done


## Bash Notes

A few advanced bash constructs are used. Some are briefly described here, but more complete information is readily available on the Internet. Recall that the [README](README.html) mentioned that we have restricted ourselves to constructs in `bash` v3.X, which is the current release on Mac OSX. However, you can use `bash` v4.X constructs if you're working exclusively on Linux systems.

### Variables that Are Numbers

    let count=0
    while [ some_condition_is_true ]
    do
      do_something
      let count=$count+1
    done
    echo "Looped $count times"

Here is another example that processes the input command arguments in `$@`, which is a `bash` array. The `$#` variable is the length of the array. `$1` is the first element. (`$0` is the path to the script we're running, by the way.) See below for another example with user-defined arrays:

    while [ $# -gt 0 ]
    do
      case $1 in
        -h|--he*)
          show_help
          exit 0
          ;;
        -f|--file)
          shift  # go to the next command-line option
          file=$1
          ;;
        ...
      esac
      shift
    done

### User-defined Arrays

In this variation of the previous example, we save all `$@` elements we don't immediately process in a user-defined array. Note that `${#args[@]}` is the length of the array and `${args[0]}` is the *first* element.

    args=()  # initialize "args" as an empty array.
    while [ $# -gt 0 ]
    do
      case $1 in
        -h|--he*)
          show_help
          exit 0
          ;;
        -f|--file)
          shift  # go to the next command-line option
          file=$1
          ;;
        *)       # all other command-line options
          args[${#args[@]}]=$1   # funky notation to append to args
          ;;
      esac
      shift
    done

Since `${#args[@]}` is the length of the array, the notation for appending to the array effectively says to write the new element to the position given by `${#args[@]}`, which is one past the current last element!

### Testing the Success or Failure of a Previous Command

By convention, commands return `0` if successful and nonzero if not. Functions in `bash` should use `return N`, unless they really want to exit the whole program!

    my_command
    if [ $? -ne 0 ]
    then
      echo "It failed!"
      exit 1
    fi

The `$?` variable is the exit status of the previously-run command (e.g., `my_command`) and it will be `0` if the command succeeded. Note, you we used `-ne` for the test instead of `!=`, because `$?` is actually a number. In fact, `!=` would have worked, too, but it would have treated `$?` and `0` as strings.

A related scenario is the need to loop forever or at least until a task fails:

    do_something_that_succeeds
    while [ $? -eq 0 ]
    then
      ...
      some_command      
    fi
    echo "It failed!"

A few points to keep in mind. First, the initial test of `$? -eq 0` will fail unless the command just before it, `do_something_that_succeeds` returns `0`. By the way, `let i=0`, to initialize a loop counter, actually returns `1` (failure)! However, `let i=1` or any other integer returns `0` (success)! 

Similarly, your call to `some_command` must be the last command in the loop. If you do something after it, e.g., increment an integer counter, the success of *that* command will be tested, which is probably not what you intended.

### Conditionally Set a Variable

    FLAG=1
    ...
    : ${FLAG:=0}
    
The value of `$FLAG` will be `1`. The 3rd line only assigns `FLAG` if it hasn't already been assigned. (This is different than if FLAG were previously assigned the value of "", the empty string.)  The `:` is required so that bash doesn't try to run the value `$FLAG` as a command. There are other conditional assignment constructs available for `bash`. See `man bash`, for example.

### Get the Parent Directory that Contains a File or Another Directory

    FILE=/a/b/c.txt
    ...
    dirname $FILE  # prints "/a/b"

### Get the Name of a File or Directory

    FILE=/a/b/c.txt
    ...
    basename $FILE  # prints "c.txt"

### Assign the Output of One Command to a Variable

    FILE=/a/b/c.txt
    ...
    BASE=$(basename $FILE)
    echo $BASE      # prints "c.txt"
    
### Remove a Prefix or a Suffix from a String

    FILE=20110601-foo-bar
    ...
    echo ${FILE#*-}   # prints "foo-bar"
    echo ${FILE##*-}  # prints "bar"
    echo ${FILE%-*}   # prints "20110601-foo"
    echo ${FILE%%-*}  # prints "20110601"

