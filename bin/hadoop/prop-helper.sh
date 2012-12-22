#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
#------------------------------------------------------------------------------
# prop-helper.sh - Helper functions for the *-prop utilities

function echo_kv {
  key="$1"
  shift
  value="$1"
  shift
  if [ $print_kv -eq 0 ] 
  then
    echo "$key=$value"
  elif [ $print_kv -eq -1 ]   # just the keys!
  then
    echo $key
  else
    echo $value
  fi  
}

function each_line {
  sed -e 's/=/ /' | while read key value
  do
    if [ $all -eq 0 ]
    then 
      echo_kv "$key" "$value"
    else
      # Hack: Use "--" as a marker between the strings and the regexs.
      let marker=0
      for s in "${strings[@]}" "--" "${regexs[@]}"
      do
        if [ "$s" = "--" ]
        then
          let marker=1
        elif [ $marker -eq 0 -a "$key" = "$s" ]
        then 
          echo_kv "$key" "$value"
          break
        elif [[ $marker -eq 1 && $key =~ $s ]]
        then 
          echo_kv "$key" "$value"
          break
        fi
      done
    fi
  done
}