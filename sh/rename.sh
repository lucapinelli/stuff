#!/usr/bin/env bash

HELP="
NAME
  rename.sh - renames a file using a regular expression

USAGE
  rename [OPTIONS] <filename> <find-regex> <replace-with>

OPTIONS
  -n, --nono
    No action: print names of files to be renamed, but don't rename.

EXAMPLES
  find -type f -name '*.jpeg' -exec rename.sh {} '\.jpeg$' '.jpg' \;
  fd --type file .png$ -x rename.sh {} 'G00' 'GOH'
"

if (( $# != 3 && $# != 4 )); then
  echo "$HELP"
  exit
fi

if (( $# == 4 )); then
  if [[ "$1" != "-n" ]] && [[ "$1" != "--nono" ]]; then
    >&2 echo "Invalid option: \"$1\""
    exit 1
  fi
  nono=true
  filename="$2"
  find_regex="$3"
  replace_with="$4"
else
  filename="$1"
  find_regex="$2"
  replace_with="$3"
fi

dir="$(dirname "$filename")"
name="$(basename "$filename")"
new_name="${dir}/$(echo "$name" | sd "$find_regex" "$replace_with")"

if [ "$filename" == "$new_name" ]; then
  echo "skipping '$filename': the filename is not changed"
elif [ "$nono" = true ]; then
  echo "no action '$filename' -> '$new_name'"
else
  mv -iv "$filename" "$new_name"
fi
