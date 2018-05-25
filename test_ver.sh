#!/bin/bash

if [ "$1" = "1" ]; then
    { ver=$($2|head -1|sed -r -e 's#.* ([0-9]+\.[0-9a-z]+(\.[0-9a-z]+)?).*#\1#'); } &>/dev/null
    [ "x${ver}" = "x" ] && ver="0.0.0"
elif [ "$1" = "2" ]; then
    true
fi

if [ "$(printf '%s\n' "$3" "$ver" | sort -V | head -n1)" = "$3" ]; then echo OK; else echo FAIL; fi
