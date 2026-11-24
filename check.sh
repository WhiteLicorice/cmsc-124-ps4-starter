#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "$0")" && pwd)"
cd "$root"

if ! command -v swipl >/dev/null 2>&1; then
    echo "check.sh: swipl is not on PATH. Complete the Prolog setup in the manual." >&2
    exit 1
fi

exec swipl -q "tests/check_all.pl" "$@"
