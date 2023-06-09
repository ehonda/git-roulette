#!/bin/bash

set -euo pipefail

# Get the short commit SHA for the current commit
get_short_commit_sha() {
  git rev-parse --short HEAD
}

# Make a commit to create a commit SHA
create_commit() {
  local regex="$1"
  # TODO: Customizable commit message
  git commit --allow-empty --message "Randomize commit SHA to match $regex" --quiet
}

commit_sha_matches() {
  local regex=$1
  local commit_sha=$2
  # Use machine locale for consistent grepping
  LC_ALL=C echo -n "$commit_sha" | grep -qE "$regex"
  echo $? # Return the exit code of grep
}

# Make commits until the commit SHA matches the given regex
randomize_commit_sha() {
  local regex="$1"
  local commit_sha
  commit_sha="$(get_short_commit_sha)"
  echo "$commit_sha"

  # TODO: Reevaluate, maybe we do want to use =~
  # Use grep instead of =~ for a more sane regex experience
  while [[ $(commit_sha_matches "$regex" "$commit_sha") -ne 0 ]]; do
    create_commit "$regex"
    commit_sha="$(get_short_commit_sha)"
    echo "$commit_sha"
  done
}

# TODO: Add functionality to list all predefined patterns
# TODO: Add functionality to differentiate between input of a predefined pattern and an actual regex
from_predefined_pattern_or_user_input() {
  local user_input="$1"
  # switch case over provided user input do determine whether to transform it or take it literally
  case "$user_input" in
    "natural number (only digits)" | "nat digits" | n | 0 )
      echo "^[0-9]+$"
      ;;
    
    "natural number (optional e notation)" | "nat e" | ne | 0e0 )
      echo "^[0-9]+e{0,1}[0-9]+$"
      ;;

    * )
      echo "$user_input"
      ;;
  esac
}

main() {
  local pattern
  pattern=$(from_predefined_pattern_or_user_input "$1")

  # TODO: Add rainbow pattern to output characters
  echo "Spinning to find pattern: $pattern"
  randomize_commit_sha "$pattern"
}

main "$@"
