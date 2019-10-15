#!/usr/bin/env bash

function help {
  echo ""
  echo "  NAME"
  echo "    rename.sh - renames a file using a regular expression (use the syntax of the 'sed' command)"
  echo ""
  echo "  USAGE"
  echo "    rename FILE_NAME REGEX"
  echo ""
  echo "  EXAMPLE"
  echo "    find -type f -name '*.jpeg' -exec rename.sh "{}" 's/.jpeg$\.jpg' \;"
  echo ""
}

if (( $# != 2 )); then
  help
  exit
fi

mv "$1" "$(echo $1 | sed $2)"
