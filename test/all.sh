#!/bin/bash

set -eu

here=$(dirname $0)
root=$(realpath --relative-to=. $here/..)

echo "You can pass '--debug' to this script for more logs"
silence="-s"
for argv ; do
	if [[ "$argv" == "--debug" ]]; then
		silence=""
		set -x
		break
	fi
done

ERRMSGN() {
	echo -n >&2 "$1"
}

ERRMSG() {
	echo >&2 "$1"
}

FAIL() {
	ERRMSG "$1"
	exit 1
}

PASS() {
	ERRMSG "ALL TESTS PASSED"
	exit 0
}

workingcopy=buildlib-v-for-test
tarball="$workingcopy.tar.gz"

# Before trying much of anything, try to cleanup in case a previous test run
# bailed out and left artifacts for inspection; they're stale now so they can
# go.
cleanup() {
	rm -rf $workingcopy build.old $tarball
}
cleanup

# Ensure that we can make a release tarball
make ${silence} -C "$root" "$tarball" version=-for-test
if [[ ! -f "$root/$tarball" ]]; then
	FAIL "can't find release tarball (expecting $tarball)"
fi

# Put the generated tarball under the test/ directory for the rest of these
# tests.
mv "$root/$tarball" "$here/"
cd "$here"
root=".."

# Make sure we didn't accidentally create a tar-bomb.
if [[ $(tar -tf "$tarball" | grep -v '^buildlib-v-for-test' | wc -l) != 0 ]]; then
	FAIL "some tar members weren't in the right directory"
fi

# -- start of self-update tests

# Start from a clean slate but we need to rename the 'deployed' directory to
# 'build' so that we can test self-updates.
rm -rf build
tar -xf "$tarball"
mv $workingcopy build
workingcopy=build

oldhash=$(md5sum $workingcopy/testing-env.mk)

# TODO(tmckee): prefer to dupe a canned clean slate for each individual test
# but don't forget to assert-clean-slate at the end to verify the update went
# through.
assert_clean_slate() {
	ERRMSGN " --- assert-clean-slate ($1)... "
	ret=0

	if [[ -f $workingcopy/stalefile.mk ]]; then
		ERRMSG "test pre-conditions violated; stalefile.mk should not exist"
		ret=$((ret + 1))
	fi

	if [[ ! -f $workingcopy/rejectfiles.mk ]]; then
		ERRMSG "test pre-conditions violated; rejectfiles.mk should exist"
		ret=$((ret + 2))
	fi

	if [[ $(md5sum $workingcopy/testing-env.mk) != $oldhash ]]; then
		ERRMSG "test pre-conditions violated; testing-env.mk had modifications"
		ret=$((ret + 4))
	fi

	workingcopyversion=$(cat $workingcopy/VERSION)
	if ! diff $workingcopy/VERSION $root/dist/VERSION; then
		ERRMSG "test pre-conditions violated; wrong VERSION file contents"
		ret=$((ret + 8))
	fi

	if [[ $ret != 0 ]]; then
		exit $ret
	fi

	ERRMSG "PASS"
}

expect_self_update() {
	ERRMSG " --- $1 ..."
	make ${silence} -C $workingcopy -f self-update.mk
	ERRMSG " --- $1 PASS"
}

expect_no_self_update() {
	ERRMSG " --- $1 ..."
	set +e
	make ${silence} -C $workingcopy -f self-update.mk && FAIL " --- $1 FAIL"
	set -e
	ERRMSG " --- $1 PASS"
}

assert_clean_slate 0

expect_self_update "clean slate should 'just work'"

# Test the update helpers by tweaking the tests' copy of the buildlib to
# simulate local edits and/or "stale" versions.
simulate_v_0_0_0() {
	echo "0.0.0" > $workingcopy/VERSION
	rm -rf $workingcopy/build.old
	# Rewrite the VERSION.hash file to be consistent with whatever happens to be
	# in the working copy right now.
	make ${silence} -C $workingcopy -f self-update.mk VERSION.hash
}

#  1. files that have been culled upstream get removed locally
assert_clean_slate 1
touch $workingcopy/stalefile.mk
expect_no_self_update "self-update should bail out if there are local modifications"
simulate_v_0_0_0
expect_self_update "self-update should cull files that were removed upstream"

#  2. files that have appeared upstream show up locally
assert_clean_slate 2
rm $workingcopy/rejectfiles.mk
expect_no_self_update "self-update should bail out if there are local modifications"
simulate_v_0_0_0
expect_self_update "self-update should add new files"

assert_clean_slate 3

cleanup

# -- end of self-update tests

ERRMSGN "building a release tarball should work ... "
make ${silence} -C ../ release-ball
ERRMSG "PASS"

# Make sure that "make release-ball" doesn't rebuild the tarball unnecessarily.
ERRMSGN "re-building a release tarball should be a no-op ... "
make ${silence} -q -C ../ release-ball || FAIL "shouldn't have to make the thing we just made!"
ERRMSG "PASS"

PASS
