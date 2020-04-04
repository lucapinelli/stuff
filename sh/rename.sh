#!/usr/bin/env bash

HELP="
NAME
  rename.sh - renames a file using a regular expression (use the syntax of the 'sed' command)

USAGE
  rename FILE_NAME REGEX

EXAMPLE
  find -type f -name '*.jpeg' -exec rename.sh {} 's/.jpeg$\.jpg' \;
"

if (( $# != 2 )); then
  echo "$HELP"
  exit
fi

mv "$1" "$(echo $1 | sed $2)"
