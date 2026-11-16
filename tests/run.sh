#!/bin/sh
# Run the test suite headlessly, by default in both Vim and Neovim.
# Usage: tests/run.sh [vim] [nvim]
set -u
cd "$(dirname "$0")" || exit 1
[ $# -gt 0 ] || set -- vim nvim
results=$(mktemp)
trap 'rm -f "$results"' EXIT
status=0
for editor in "$@"; do
  echo "== $editor"
  case $editor in
    *nvim*) set -- --headless -u NONE -i NONE -n ;;
    *) set -- -N -u NONE -i NONE -n -es ;;
  esac
  : > "$results"
  FORMATPRGS_RESULTS=$results "$editor" "$@" -S test_formatprgs.vim < /dev/null || status=1
  cat "$results"
  [ -s "$results" ] || { echo "no results"; status=1; }
done
exit "$status"
