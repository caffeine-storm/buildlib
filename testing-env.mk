# recipes for running tests

include build/rejectfiles.mk

.PHONY: test \
	test-verbose \
	test-racy \
	test-racy-with-cache \
	test-spec \
	test-nocache \
	test-fresh \
	test-dlv \
	test-and-trace \
	view-trace

# Makefiles that include this file can set 'testdeps' to a list of targets that
# each testing target should depend on.
testdeps?=

# By default, run all the tests. Which tests to run can still be overridden via
# command-line.
testrunpackages?=./...

# By passing 'testrun=TestPatternToRun', users can choose which tests to run by
# name.
ifneq "${testrun}" ""
testrunargs+=-run ${testrun}
endif

# Some testing commands only work on one package at a time. If so, you can pick
# which package with the 'pkg' variable.
ifeq "${pkg}" ""
	pkg=--set-'pkg'-to-a-package/dir
else
	# Get a relative path by removing the absolute path of $CWD from the absolute
	# path of the given 'pkg' value. Need 'override' because 'pkg' was passed on
	# the command line so plain definitions are ignored.
	override pkg:=$(subst $(abspath .)/,./,$(abspath ${pkg}))
	# Trim a trailing slash if it's there
	override pkg:=$(pkg:%/=%)
endif

# Can use these buildflags variables to tweak what flags get passed to
# underlying go tooling.
testbuildflags?=
dlvbuildflags?=--build-flags="${testbuildflags}"
# Replace each -$elem of 'testrunargs' with '-test.$elem'
newtestrunargs:=$(subst -,-test.,${testrunargs})

# By default, the Xvfb instance will create a new Xauthority file in
# /tmp/xvfb-run.PID/Xauthority for access control.
# To interact with the Xvfb instance, you can set your XAUTHORITY and DISPLAY
# environment vars accordingly.
testing_with_xvfb=xvfb-run --server-args="-screen 0 1024x750x24" --auto-servernum

ifeq "${testing_env}" ""
testing_env:=${testing_with_xvfb}
else
testing_env:=${testing_env} ${testing_with_xvfb}
endif

test: ${testdeps}
	${testing_env} go test ${testctlflags} ${testbuildflags} ${testrunargs} ${testrunpackages}

# test-verbose is test but also pass '-v' for more output
test-verbose: testctlflags+=-v
test-verbose: test

# test-racy is test but with data-race detection enabled. Cache-busting is also
# used here to make sure the tests actually run for the detection to occur.
test-racy: testctlflags+=-count=1
test-racy: test-racy-with-cache

# test-racy-with-cache is test-racy but without the cache-busting.
test-racy-with-cache: testctlflags+=-race
test-racy-with-cache: test

# test-spec is test but only run spec-tests
test-spec: testctlflags+=-run ".*Specs"
test-spec: test

# test-nocache is test but with cache-busting to force tests to actually run.
test-nocache: testctlflags+=-count=1
test-nocache: test

# test-fresh is test-nocache but remove any reject files that might be
# lingering from previous runs.
test-fresh: |clean_rejects
test-fresh: test-nocache

test-dlv: ${testdeps}
# delve wants exactly one package at a time so "testrunpackages" isn't what we
# want here. We use a var specifically for pointing at a single directory.
	[ -d ${pkg} ] && \
	${testing_env} dlv test ${pkg} ${dlvbuildflags} -- ${newtestrunargs}

trace_output_ext?=tracefile
trace_output_file=${pkg}/test.${trace_output_ext}

# never remove a tracefile; they're useful even if the command that generates
# them happens to fail
.PRECIOUS: %/test.${trace_output_ext}

# test-and-trace is test but with tracing enabled
test-and-trace: testbuildflags+=-trace ${pkg}/test.${trace_output_ext}
test-and-trace: testrunpackages=${pkg}
test-and-trace: test

%/test.tracefile:
# We need to be sneaky here; we invoke a sub-make and ignore any errors it
# returns. This way, if we get a trace during a failed test run, we can still
# view it.
	-$(MAKE) test-and-trace pkg="${pkg}"

# Note that we declare an 'order-only dependency' on the trace output so that
# if a tracefile exists from past runs, we don't clobber it.
view-trace: |${trace_output_file}
	go tool trace $|
