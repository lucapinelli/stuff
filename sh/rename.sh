#!/usr/bin/env bash

HELP="
NAME
  rename.sh - renames a file using a regular expression (use the syntax of the 'sed' command)

USAGE
  rename FILE_NAME REGEX

EXAMPLES
  find -type f -name '*.jpeg' -exec rename.sh {} 's/.jpeg$/\.jpg' \;
  fd --type file .png$ -exec rename.sh {} 's|/G00|/GOH|'
"

if (( $# != 2 )); then
  echo "$HELP"
  exit
fi

mv "$1" "$(echo $1 | sed $2)"

