#!/bin/bash

set -e

here=$(dirname $0)
root=$(realpath --relative-to=. $here/..)

make -C "$root" release version=-for-test

FAIL() {
	echo >&2 "$1"
	exit 1
}

PASS() {
	echo >&2 "ALL TESTS PASSED"
	exit 0
}

tarball=buildlib-v-for-test.tar.gz
if [[ ! -f "$root/$tarball" ]]; then
	FAIL "can't find release tarball (expecting $tarball)"
fi

mv "$root/$tarball" "$here/"

filelist=$(tar -tf "$here/$tarball")
if [[ $(echo "$filelist" | grep -v '^buildlib-v-for-test' | wc -l) != 0 ]]; then
	FAIL "some tar members weren't in the right directory"
fi

PASS
