SHELL:=/bin/bash

base-rev-version:=${file <VERSION}
base-rev-hash:=${file <VERSION.hash}

ifneq (,$(findstring s,${MAKEFLAGS}))
silence:=-s
endif

# Guard against weirdness by only running self-update if we're in a directory
# called "build". It's "dist" in buildlib's source-control and users can
# disable self-update by _not_ renaming the release tarball to "build".
live-dir:=${shell basename $(realpath .)}
ifneq "${live-dir}" "build"
$(error "self-update is disabled unless the containing directory is called 'build'")
endif

# TODO(tmckee): pick a better directory for this; right now we'd clobber any
# host-project's "update" directory.
update-tmpdir:=../update

# TODO(tmckee): stubbing upstream tarball fetch until we figure out release
# strategy.
upstream_url:=file://$(abspath ./../../buildlib-v0.0.1.tar.gz)
self-update: no-local-changes |${update-tmpdir}
	curl ${silence} -L ${upstream_url} -o ${update-tmpdir}/buildlib-upstream.tar.gz
	tar -C ${update-tmpdir} -xf ${update-tmpdir}/buildlib-upstream.tar.gz
	tar -O -x -f ${update-tmpdir}/buildlib-upstream.tar.gz --wildcards '*/VERSION' > ${update-tmpdir}/VERSION.upstream
	# Only 'promote' the tarball if the upstream version is greater-than the
	# local version.
	if cat ./VERSION ${update-tmpdir}/VERSION.upstream | sort -Vuc &>/dev/null; then \
		cd ../ && \
		rm -rf build.old && \
		mv ./build build.old && \
		mv update/buildlib-v${file <${update-tmpdir}/VERSION.upstream} build ; \
	else \
		echo "no update needed" ; \
	fi

include hash.mk
no-local-changes: |local.hash
	# To make sure we don't clobber changes made to a-copy-of a release, check
	# file contents against a hash value included in the distribution.
	@diff -q local.hash VERSION.hash || { echo ' !! detected local modifications; refusing to update' ; false ; }

.PHONY: no-local-changes

${update-tmpdir}:
	mkdir -p $@
